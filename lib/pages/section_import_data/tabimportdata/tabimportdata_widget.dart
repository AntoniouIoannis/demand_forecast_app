import 'dart:convert';

import '/backend/forecast/forecast_api_service.dart';
import '/backend/forecast/forecast_models.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/section_import_data/forecast_results/forecast_results_widget.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as xls;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tabimportdata_model.dart';
export 'tabimportdata_model.dart';

class TabimportdataWidget extends StatefulWidget {
  const TabimportdataWidget({super.key});

  static String routeName = 'tabimportdata';
  static String routePath = 'tabimportdata';

  @override
  State<TabimportdataWidget> createState() => _TabimportdataWidgetState();
}

class _TabimportdataWidgetState extends State<TabimportdataWidget> {
  late TabimportdataModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<String, PlatformFile?> _filesByYear = {
    '2017': null,
    '2018': null,
    '2019': null,
  };

  bool _isSubmitting = false;

  final ForecastApiService _apiService = ForecastApiService(
    baseUrl: 'https://demand-forecast-api-1072203670086.europe-west1.run.app',
  );

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TabimportdataModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  bool get _hasAtLeastOneFileSelected =>
      _filesByYear.values.any((file) => file?.bytes != null);

  Future<void> _pickFileForYear(String year) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xlsx', 'xls', 'csv'],
      withData: true,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    safeSetState(() {
      _filesByYear[year] = result.files.first;
    });
  }

  void _clearFileForYear(String year) {
    safeSetState(() {
      _filesByYear[year] = null;
    });
  }

  Future<void> _submitForecast() async {
    if (!_hasAtLeastOneFileSelected || _isSubmitting) {
      return;
    }

    safeSetState(() {
      _isSubmitting = true;
    });

    try {
      final preparedFiles = <ForecastInputFile>[];
      final selectedOrder = ['2017', '2018', '2019'];
      for (final year in selectedOrder) {
        final selected = _filesByYear[year];
        if (selected?.bytes != null) {
          preparedFiles.add(_prepareMappedFile(year, selected!));
        }
      }

      if (preparedFiles.isEmpty) {
        throw const FormatException('Please select at least one file.');
      }

      final requiredFields = ['sales2017', 'sales2018', 'sales2019'];
      final requestFiles = <ForecastInputFile>[];
      for (var i = 0; i < requiredFields.length; i++) {
        final source = preparedFiles[
            i < preparedFiles.length ? i : preparedFiles.length - 1];
        requestFiles.add(
          ForecastInputFile(
            fieldName: requiredFields[i],
            fileName: '${requiredFields[i]}.xlsx',
            bytes: source.bytes,
          ),
        );
      }

      final selectedNames = selectedOrder
          .map((year) => _filesByYear[year]?.name)
          .whereType<String>()
          .where((name) => name.trim().isNotEmpty)
          .toList(growable: false);

      final results = await _apiService.runForecast(files: requestFiles);

      if (!mounted) {
        return;
      }

      context.pushNamed(
        ForecastResultsWidget.routeName,
        extra: {
          'results':
              results.map((entry) => entry.toMap()).toList(growable: false),
          'sourceLabel': selectedNames.join(', '),
        },
      );
    } on ForecastApiException catch (e) {
      if (mounted) {
        showSnackbar(context, e.message);
      }
    } on FormatException catch (e) {
      if (mounted) {
        showSnackbar(context, e.message);
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(context, 'Failed to process files: $e');
      }
    } finally {
      if (mounted) {
        safeSetState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  ForecastInputFile _prepareMappedFile(String year, PlatformFile selectedFile) {
    final bytes = selectedFile.bytes;
    if (bytes == null || bytes.isEmpty) {
      throw const FormatException('Selected file is empty.');
    }

    final extension = selectedFile.extension?.toLowerCase() ?? '';

    if (extension == 'xlsx' || extension == 'xls') {
      return ForecastInputFile(
        fieldName: 'sales$year',
        fileName: 'sales_$year.xlsx',
        bytes: bytes,
      );
    }

    final rows = _readCsvRows(bytes);
    if (rows.length < 2) {
      throw FormatException(
        'Το αρχείο ${selectedFile.name} δεν έχει επαρκή δεδομένα (header + rows).',
      );
    }

    final headers = rows.first.map((cell) => cell.toString().trim()).toList();
    final normalizedIndexByHeader = <String, int>{
      for (var i = 0; i < headers.length; i++) _normalizeHeader(headers[i]): i,
    };

    final mapping = {
      'shipped': _findColumnIndex(normalizedIndexByHeader, const [
        'shipped',
        'shippeddate',
        'shipdate',
        'date',
        'orderdate',
        'monthyear',
      ]),
      'product_id': _findColumnIndex(normalizedIndexByHeader, const [
        'productid',
        'product_id',
        'itemid',
        'item',
        'sku',
        'product',
      ]),
      'ordered_qty': _findColumnIndex(normalizedIndexByHeader, const [
        'orderedqty',
        'ordered_qty',
        'qty',
        'quantity',
        'orderedquantity',
      ]),
    };

    final missingTargets = mapping.entries
        .where((entry) => entry.value == null)
        .map((entry) => entry.key)
        .toList(growable: false);

    if (missingTargets.isNotEmpty) {
      throw FormatException(
        'Δεν βρέθηκε mapping για ${missingTargets.join(', ')} στο ${selectedFile.name}. Headers: ${headers.join(', ')}',
      );
    }

    final mappedRows = <List<dynamic>>[
      const ['shipped', 'product_id', 'ordered_qty'],
    ];

    for (final row in rows.skip(1)) {
      if (_isRowCompletelyEmpty(row)) {
        continue;
      }

      mappedRows.add([
        _cellAt(row, mapping['shipped']!),
        _cellAt(row, mapping['product_id']!),
        _cellAt(row, mapping['ordered_qty']!),
      ]);
    }

    if (mappedRows.length <= 1) {
      throw FormatException(
          'Το αρχείο ${selectedFile.name} δεν περιέχει έγκυρες γραμμές δεδομένων.');
    }

    final workbook = xls.Excel.createExcel();
    final sheetName = workbook.getDefaultSheet() ?? 'Sheet1';
    final sheet = workbook[sheetName];

    for (final row in mappedRows) {
      sheet.appendRow(
          row.map((cell) => xls.TextCellValue(cell.toString())).toList());
    }

    final encoded = workbook.encode();
    if (encoded == null || encoded.isEmpty) {
      throw FormatException(
          'Αποτυχία δημιουργίας mapped Excel για ${selectedFile.name}.');
    }

    return ForecastInputFile(
      fieldName: 'sales$year',
      fileName: 'sales_$year.xlsx',
      bytes: encoded,
    );
  }

  List<List<dynamic>> _readCsvRows(List<int> bytes) {
    final csvText = utf8.decode(bytes, allowMalformed: true);
    return const CsvToListConverter(shouldParseNumbers: false).convert(csvText);
  }

  String _normalizeHeader(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  int? _findColumnIndex(
    Map<String, int> normalizedIndexByHeader,
    List<String> candidates,
  ) {
    for (final candidate in candidates) {
      final idx = normalizedIndexByHeader[_normalizeHeader(candidate)];
      if (idx != null) {
        return idx;
      }
    }
    return null;
  }

  String _cellAt(List<dynamic> row, int index) {
    if (index < 0 || index >= row.length) {
      return '';
    }
    return row[index].toString().trim();
  }

  bool _isRowCompletelyEmpty(List<dynamic> row) =>
      row.every((cell) => cell.toString().trim().isEmpty);

  Widget _fileCard(String year) {
    final selectedFile = _filesByYear[year];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload File',
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    font: GoogleFonts.interTight(
                      fontWeight:
                          FlutterFlowTheme.of(context).titleMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).titleMedium.fontStyle,
                    ),
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).titleMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).titleMedium.fontStyle,
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              selectedFile?.name ?? 'No file selected',
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                FFButtonWidget(
                  onPressed: () async {
                    await _pickFileForYear(year);
                  },
                  text: selectedFile == null
                      ? 'Select Excel/CSV'
                      : 'Replace File',
                  options: FFButtonOptions(
                    height: 40.0,
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                    iconPadding:
                        const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).info,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                    elevation: 1.0,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                const SizedBox(width: 8.0),
                FFButtonWidget(
                  onPressed: selectedFile == null
                      ? null
                      : () {
                          _clearFileForYear(year);
                        },
                  text: 'Delete',
                  options: FFButtonOptions(
                    height: 40.0,
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                    iconPadding:
                        const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    color: FlutterFlowTheme.of(context).secondary,
                    textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).info,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                    elevation: 1.0,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          title: Text(
            'Import Data',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).info,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
          ),
          actions: const [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload up to 3 files excel or csv',
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
                const SizedBox(height: 16.0),
                _fileCard('2017'),
                const SizedBox(height: 12.0),
                _fileCard('2018'),
                const SizedBox(height: 12.0),
                _fileCard('2019'),
                const Spacer(),
                FFButtonWidget(
                  onPressed: (_hasAtLeastOneFileSelected && !_isSubmitting)
                      ? () async {
                          await _submitForecast();
                        }
                      : null,
                  text: _isSubmitting ? 'Processing...' : 'Run Forecast',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 50.0,
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    iconPadding:
                        const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.interTight(
                            fontWeight: FlutterFlowTheme.of(context)
                                .titleSmall
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).info,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .titleSmall
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).titleSmall.fontStyle,
                        ),
                    elevation: 2.0,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
