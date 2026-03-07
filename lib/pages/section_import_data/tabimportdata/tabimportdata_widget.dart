import 'dart:convert';
//import 'dart:typed_data';

import '/backend/forecast/forecast_models.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/section_authentication/auth2/auth2_widget.dart';
import '/pages/section_import_data/forecast_processing/forecast_processing_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:excel/excel.dart' as xls;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
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
  static const List<String> _allowedExtensions = ['xls', 'xlsx'];

  late TabimportdataModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<String, PlatformFile?> _filesByYear = {
    '2017': null,
    '2018': null,
    '2019': null,
  };

  bool _isSubmitting = false;

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

  String get _supportedExtensionsLabel =>
      _allowedExtensions.map((extension) => '.$extension').join(', ');

  Future<void> _pickFileForYear(String year) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw const FormatException('Πρέπει να κάνεις sign in πριν το upload.');
      }
      final userId = user.uid;
      final uploadId = const Uuid().v4();

      final storage = FirebaseStorage.instance;
        final selectedOrder = ['2017', '2018', '2019'];
        final selectedEntries = _filesByYear.entries
          .where((entry) => entry.value?.bytes != null)
          .toList(growable: false);
        final fallbackFile = selectedEntries.isNotEmpty ? selectedEntries.first.value : null;

      int filesUploaded = 0;
      final uploadedFiles = <Map<String, dynamic>>[];
      final selectedNames = selectedEntries
          .map((entry) => entry.value?.name)
          .whereType<String>()
          .where((name) => name.trim().isNotEmpty)
          .toList(growable: false);

      if (fallbackFile == null || fallbackFile.bytes == null) {
        throw const FormatException('Please select at least one Excel file.');
      }

      for (final year in selectedOrder) {
        final selected = _filesByYear[year] ?? fallbackFile;
        final mappedFile = _prepareMappedFile(year, selected);

        final filePath = 'staging/$userId/$uploadId/${mappedFile.fileName}';
        final ref = storage.ref().child(filePath);

        final metadata = SettableMetadata(
          contentType:
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          customMetadata: {
            'year': year,
            'originalName': selected.name,
            'uploadId': uploadId,
            'mapped': 'true',
            'demoFilled': (_filesByYear[year] == null).toString(),
          },
        );

        await ref.putData(Uint8List.fromList(mappedFile.bytes), metadata);
        filesUploaded++;
        uploadedFiles.add({
          'year': year,
          'originalName': selected.name,
          'mappedName': mappedFile.fileName,
          'originalExtension': (selected.extension ?? '').toLowerCase().trim(),
          'demoFilled': _filesByYear[year] == null,
        });
      }

      final readyPayload = jsonEncode({
        'userId': userId,
        'uploadId': uploadId,
        'filesUploaded': filesUploaded,
        'files': uploadedFiles,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'mapped': true,
        'expectedColumns': const ['shipped', 'product_id', 'ordered_qty'],
      });
      final readyRef =
          storage.ref().child('ready/$userId/$uploadId/READY.json');
      await readyRef.putData(
        Uint8List.fromList(utf8.encode(readyPayload)),
        SettableMetadata(
          contentType: 'application/json',
          customMetadata: {
            'uploadId': uploadId,
            'mapped': 'true',
          },
        ),
      );

      if (mounted) {
        context.pushNamed(
          ForecastProcessingWidget.routeName,
          extra: {
            'uploadId': uploadId,
            'sourceLabel': selectedNames.join(', '),
          },
        );

        safeSetState(() {
          _filesByYear.updateAll((_, __) => null);
        });
      }
    } on FormatException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.orange),
        );
        if (FirebaseAuth.instance.currentUser == null) {
          context.goNamedAuth(Auth2Widget.routeName, context.mounted);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Upload failed: $e'), backgroundColor: Colors.red),
        );
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
    if (extension != 'xlsx' && extension != 'xls') {
      throw FormatException(
        'Για το demo επιτρέπονται μόνο Excel αρχεία ($_supportedExtensionsLabel).',
      );
    }
    final rows = _readSpreadsheetRows(bytes);
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
      fileName: 'sales$year.xlsx',
      bytes: encoded,
    );
  }

  List<List<dynamic>> _readSpreadsheetRows(List<int> bytes) {
    final workbook = xls.Excel.decodeBytes(bytes);
    if (workbook.tables.isEmpty) {
      throw const FormatException('Το Excel αρχείο δεν περιέχει worksheet.');
    }

    final firstSheetName = workbook.tables.keys.first;
    final sheet = workbook.tables[firstSheetName];
    if (sheet == null || sheet.rows.isEmpty) {
      throw const FormatException('Το Excel αρχείο είναι κενό.');
    }

    return sheet.rows
        .map(
          (row) => row
              .map((cell) => cell?.value?.toString().trim() ?? '')
              .toList(growable: false),
        )
        .toList(growable: false);
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

  Widget _buildHintCard({
    required String title,
    required String content,
    double? width,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F4),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFDADCE0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: FlutterFlowTheme.of(context).titleSmall.override(
                    font: GoogleFonts.interTight(
                      fontWeight:
                          FlutterFlowTheme.of(context).titleSmall.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).titleSmall.fontStyle,
                    ),
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).titleSmall.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).titleSmall.fontStyle,
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              content,
              style: GoogleFonts.robotoMono(
                color: FlutterFlowTheme.of(context).primaryText,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            const SizedBox(height: 6.0),
            Text(
              'Allowed: $_supportedExtensionsLabel',
              style: FlutterFlowTheme.of(context).bodySmall,
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                FFButtonWidget(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                        await _pickFileForYear(year);
                        },
                  text: selectedFile == null
                      ? 'Select Excel'
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
                  onPressed: selectedFile == null || _isSubmitting
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
                  'Demo mode: upload 1, 2, or 3 of the specific yearly Excel files. If only 1 file is selected, it will be reused for the missing years to keep the backend flow unchanged.',
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
                const SizedBox(height: 12.0),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final useRowLayout = constraints.maxWidth >= 900.0;
                    final cardWidth = useRowLayout
                        ? (constraints.maxWidth - 24.0) / 3
                        : double.infinity;

                    return Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      children: [
                        _buildHintCard(
                          width: cardWidth,
                          title: 'Supported file types',
                          content: '.xls\n.xlsx',
                        ),
                        _buildHintCard(
                          width: cardWidth,
                          title: 'Expected columns and sample values',
                          content:
                              'shipped | product_id | ordered_qty\n2025-01-15 | BIC-1001 | 42\n2025-02-01 | HALCOR-77 | 17\n2025-03-11 | ELVAL-2020 | 63',
                        ),
                        _buildHintCard(
                          width: cardWidth,
                          title: 'Demo note',
                          content:
                              'Keep the three upload slots as 2017 / 2018 / 2019.\nFor a quick demo, selecting just one Excel file is enough.\nThe app will duplicate it into sales2017.xlsx, sales2018.xlsx and sales2019.xlsx before sending the request.',
                        ),
                      ],
                    );
                  },
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isSubmitting
                      ? Padding(
                          key: const ValueKey('forecast-progress'),
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Uploading demo files and preparing forecast request...',
                                style: FlutterFlowTheme.of(context).bodySmall,
                              ),
                              const SizedBox(height: 8.0),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999.0),
                                child: const LinearProgressIndicator(
                                  minHeight: 8.0,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('forecast-idle')),
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
                  text: _isSubmitting
                      ? 'Uploading & Preparing...'
                      : 'Start Forecast Processing',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 50.0,
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    iconPadding:
                        const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    color: _isSubmitting
                        ? FlutterFlowTheme.of(context).secondary
                        : FlutterFlowTheme.of(context).primary,
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
