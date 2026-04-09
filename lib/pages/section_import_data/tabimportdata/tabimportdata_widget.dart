import 'dart:convert';
//import 'dart:typed_data';

import '/backend/forecast/forecast_config.dart';
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
  static const List<String> _uploadSlots = [
    'file_slot_1',
    'file_slot_2',
    'file_slot_3',
  ];

  late TabimportdataModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<String, PlatformFile?> _filesBySlot = {
    'file_slot_1': null,
    'file_slot_2': null,
    'file_slot_3': null,
  };

  bool _isSubmitting = false;
  bool _debugMode = true;
  final List<String> _debugLogs = <String>[];

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
      _filesBySlot.values.any((file) => file?.bytes != null);

  String get _supportedExtensionsLabel =>
      _allowedExtensions.map((extension) => '.$extension').join(', ');

  String _timestamp() => DateTime.now().toIso8601String().substring(11, 19);

  void _appendDebugLog(String message) {
    if (!mounted) {
      return;
    }
    safeSetState(() {
      _debugLogs.add('[${_timestamp()}] $message');
    });
  }

  Future<void> _debugCheckpoint(String title, String message) async {
    _appendDebugLog('$title: $message');
    if (!_debugMode || !mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFileForSlot(String slot) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      withData: true,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    safeSetState(() {
      _filesBySlot[slot] = result.files.first;
    });
    _appendDebugLog('File selected for $slot: ${result.files.first.name}');
  }

  void _clearFileForSlot(String slot) {
    safeSetState(() {
      _filesBySlot[slot] = null;
    });
    _appendDebugLog('File cleared for $slot');
  }

  Future<void> _showUploadGuideThenSubmit() async {
    if (!ForecastConfig.forecastingEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(ForecastConfig.forecastingPausedMessage),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (_isSubmitting || !_hasAtLeastOneFileSelected) {
      return;
    }

    final proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Upload Files Guide'),
        content: const Text(
          'You can upload one, two, or three files.\n'
          'File names can be any name.\n'
          'Only the file format and expected columns are required for ML processing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (proceed == true && mounted) {
      await _submitForecast();
    }
  }

  Future<void> _submitForecast() async {
    if (!_hasAtLeastOneFileSelected || _isSubmitting) {
      return;
    }

    safeSetState(() {
      _isSubmitting = true;
    });
    _appendDebugLog('Start Forecast Processing clicked');

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw const FormatException('Πρέπει να κάνεις sign in πριν το upload.');
      }
      await _debugCheckpoint('Auth OK', 'Authenticated user: ${user.uid}');
      final userId = user.uid;
      final uploadId = const Uuid().v4();
      final selectedCountryRaw = FFAppState().selectedMarketCountry;
      final countryCode = _toCountryCode(selectedCountryRaw);
      final selectedMarket =
          (FFAppState().selectedBusinessMarket?.trim().isNotEmpty ?? false)
              ? FFAppState().selectedBusinessMarket!.trim()
              : 'Retail';
      await _debugCheckpoint('Upload ID Created', 'uploadId = $uploadId');
      await _debugCheckpoint(
        'Forecast Context',
        'Country=$countryCode | Market=$selectedMarket',
      );

      final storage = FirebaseStorage.instance;
      final selectedEntries = _filesBySlot.entries
          .where((entry) => entry.value?.bytes != null)
          .toList(growable: false);

      int filesUploaded = 0;
      final uploadedFiles = <Map<String, dynamic>>[];
      final selectedNames = selectedEntries
          .map((entry) => entry.value?.name)
          .whereType<String>()
          .where((name) => name.trim().isNotEmpty)
          .toList(growable: false);

      if (selectedEntries.isEmpty) {
        throw const FormatException('Please select at least one Excel file.');
      }
      await _debugCheckpoint(
        'Input Files Ready',
        'Selected files: ${selectedNames.join(', ')}',
      );

      for (var i = 0; i < selectedEntries.length; i++) {
        final slotEntry = selectedEntries[i];
        final selected = slotEntry.value!;
        final slotKey = slotEntry.key;
        await _debugCheckpoint(
          'Prepare File ${i + 1}',
          'Using ${selected.name} from $slotKey.',
        );
        final mappedFile = _prepareMappedFile(i + 1, selected);

        final filePath = 'staging/$userId/$uploadId/${mappedFile.fileName}';
        final ref = storage.ref().child(filePath);

        final metadata = SettableMetadata(
          contentType:
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          customMetadata: {
            'slotKey': slotKey,
            'originalName': selected.name,
            'uploadId': uploadId,
            'mapped': 'true',
          },
        );

        await ref.putData(Uint8List.fromList(mappedFile.bytes), metadata);
        filesUploaded++;
        await _debugCheckpoint(
          'Upload Success',
          'Uploaded ${mappedFile.fileName} to $filePath',
        );
        uploadedFiles.add({
          'slotKey': slotKey,
          'originalName': selected.name,
          'mappedName': mappedFile.fileName,
          'originalExtension': (selected.extension ?? '').toLowerCase().trim(),
        });
      }

      final readyPayload = jsonEncode({
        'userId': userId,
        'uploadId': uploadId,
        'country_code': countryCode,
        'market': selectedMarket,
        'filesUploaded': filesUploaded,
        'selectedFileCount': selectedEntries.length,
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
      await _debugCheckpoint(
        'READY.json Uploaded',
        'Forecast trigger file uploaded successfully. filesUploaded=$filesUploaded',
      );

      if (mounted) {
        _appendDebugLog('Opening Forecast Processing page');
        FFAppState().update(() {
          FFAppState().forecastReferenceDateIso =
              DateTime.now().toUtc().toIso8601String();
        });
        context.pushNamed(
          ForecastProcessingWidget.routeName,
          extra: {
            'uploadId': uploadId,
            'sourceLabel': selectedNames.join(', '),
            'debugMode': _debugMode,
          },
        );

        safeSetState(() {
          _filesBySlot.updateAll((_, __) => null);
        });
      }
    } on FormatException catch (e) {
      _appendDebugLog('FormatException: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.orange),
        );
        if (FirebaseAuth.instance.currentUser == null) {
          context.goNamedAuth(Auth2Widget.routeName, context.mounted);
        }
      }
    } catch (e) {
      _appendDebugLog('Unhandled error: $e');
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

  ForecastInputFile _prepareMappedFile(
      int fileIndex, PlatformFile selectedFile) {
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

    final sanitizedBaseName = _sanitizeFileBaseName(selectedFile.name);

    return ForecastInputFile(
      fieldName: 'sales$fileIndex',
      fileName: '${sanitizedBaseName}_mapped.xlsx',
      bytes: encoded,
    );
  }

  String _sanitizeFileBaseName(String filename) {
    final dotIndex = filename.lastIndexOf('.');
    final rawBase = dotIndex > 0 ? filename.substring(0, dotIndex) : filename;
    final sanitized = rawBase
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
    return sanitized.isEmpty ? 'uploaded_file' : sanitized;
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

  String _toCountryCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'US';
    }
    final normalized = value.trim().toUpperCase();
    const map = <String, String>{
      'GREECE': 'GR',
      'CYPRUS': 'CY',
      'ITALY': 'IT',
      'GERMANY': 'DE',
      'FRANCE': 'FR',
      'SPAIN': 'ES',
      'UNITED KINGDOM': 'GB',
      'UNITED STATES': 'US',
      'GR': 'GR',
      'CY': 'CY',
      'IT': 'IT',
      'DE': 'DE',
      'FR': 'FR',
      'ES': 'ES',
      'GB': 'GB',
      'US': 'US',
    };
    return map[normalized] ?? normalized;
  }

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

  Widget _buildDebugCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFDADCE0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Debug trace',
                    style: FlutterFlowTheme.of(context).titleSmall,
                  ),
                ),
                Switch.adaptive(
                  value: _debugMode,
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          safeSetState(() {
                            _debugMode = value;
                          });
                        },
                ),
              ],
            ),
            Text(
              _debugMode
                  ? 'Live checkpoints are enabled. An OK dialog will appear at key steps.'
                  : 'Live checkpoints are disabled. Trace messages still appear here.',
              style: FlutterFlowTheme.of(context).bodySmall,
            ),
            if (_debugLogs.isNotEmpty) ...[
              const SizedBox(height: 10.0),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 160.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _debugLogs
                        .map(
                          (log) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              log,
                              style: GoogleFonts.robotoMono(
                                fontSize: 11.0,
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _fileCard(String slot) {
    final selectedFile = _filesBySlot[slot];
    final slotIndex = _uploadSlots.indexOf(slot) + 1;

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
              'Upload File $slotIndex',
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
              selectedFile?.name ?? 'Uploaded file name will appear here',
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
                          await _pickFileForSlot(slot);
                        },
                  text: selectedFile == null ? 'Select Excel' : 'Replace File',
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
                          _clearFileForSlot(slot);
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload one, two, or three Excel files. The app processes only the files you upload.',
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
                if (!ForecastConfig.forecastingEnabled) ...[
                  const SizedBox(height: 10.0),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E5),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: const Color(0xFFFFC107)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        ForecastConfig.forecastingPausedMessage,
                        style: TextStyle(
                          color: Color(0xFF5F370E),
                          fontSize: 13.0,
                        ),
                      ),
                    ),
                  ),
                ],
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
                          title: 'Upload behavior',
                          content:
                              'You can upload 1, 2, or 3 files.\nOnly uploaded files are used for training and forecast processing.\nFile names are dynamic and do not need a fixed naming pattern.',
                        ),
                        _buildHintCard(
                          width: cardWidth,
                          title: 'Local processing indicator',
                          content:
                              'After upload, status messages will appear live, for example:\nProcessing dataset...\nBuilding demand model for ${FFAppState().selectedMarketCountry ?? 'your market'}...',
                        ),
                        _buildHintCard(
                          width: cardWidth,
                          title: 'Data usage policy',
                          content:
                              'We only request data needed to improve prediction.\nWe do not request data identifying the user.\nYour uploaded data is used only for generating forecast models.\nFiles are not shared with third parties and can be deleted at any time.',
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12.0),
                _buildDebugCard(),
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
                                'Uploading selected files and preparing forecast request...',
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
                _fileCard('file_slot_1'),
                const SizedBox(height: 12.0),
                _fileCard('file_slot_2'),
                const SizedBox(height: 12.0),
                _fileCard('file_slot_3'),
                const SizedBox(height: 16.0),
                FFButtonWidget(
                  onPressed: (ForecastConfig.forecastingEnabled &&
                          _hasAtLeastOneFileSelected &&
                          !_isSubmitting)
                      ? () async {
                          await _showUploadGuideThenSubmit();
                        }
                      : null,
                  text: _isSubmitting
                      ? 'Uploading & Preparing...'
                      : (ForecastConfig.forecastingEnabled
                          ? 'Start Forecast Processing'
                          : 'Forecast Processing Disabled'),
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
