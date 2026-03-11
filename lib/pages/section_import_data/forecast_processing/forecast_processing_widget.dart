import '/backend/forecast/forecast_models.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class ForecastProcessingWidget extends StatefulWidget {
  const ForecastProcessingWidget({
    super.key,
    this.uploadId,
    this.sourceLabel,
    this.debugMode = false,
  });

  static String routeName = 'forecastProcessing';
  static String routePath = 'forecastProcessing';

  final String? uploadId;
  final String? sourceLabel;
  final bool debugMode;

  @override
  State<ForecastProcessingWidget> createState() =>
      _ForecastProcessingWidgetState();
}

class _ForecastProcessingWidgetState extends State<ForecastProcessingWidget> {
  static const Duration _processingTimeout = Duration(seconds: 45);

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _hasNavigatedToResults = false;
  final List<String> _debugEvents = <String>[];
  String? _lastDebugEvent;
  Timer? _timeoutTimer;
  bool _hasTimedOut = false;

  @override
  void initState() {
    super.initState();
    _timeoutTimer = Timer(_processingTimeout, () {
      if (!mounted || _hasNavigatedToResults) {
        return;
      }
      safeSetState(() {
        _hasTimedOut = true;
      });
      _recordDebugEvent(
          'Processing timeout reached after ${_processingTimeout.inSeconds}s.');
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  String _timestamp() => DateTime.now().toIso8601String().substring(11, 19);

  void _recordDebugEvent(String message) {
    if (_lastDebugEvent == message) {
      return;
    }
    _lastDebugEvent = message;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      safeSetState(() {
        _debugEvents.add('[${_timestamp()}] $message');
      });
    });
  }

  void _openResults(List<ForecastRecord> results, String? sourceLabel) {
    if (_hasNavigatedToResults || !mounted) {
      return;
    }

    _timeoutTimer?.cancel();
    _hasNavigatedToResults = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.goNamedAuth(
        ForecastResultsWidget.routeName,
        context.mounted,
        extra: {
          'results':
              results.map((entry) => entry.toMap()).toList(growable: false),
          'sourceLabel': sourceLabel,
          'debugMode': widget.debugMode,
        },
      );
    });
  }

  Widget _buildDebugPanel({VoidCallback? onContinue}) {
    if (!widget.debugMode) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24.0),
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
            Text(
              'Live debug trace',
              style: FlutterFlowTheme.of(context).titleSmall,
            ),
            const SizedBox(height: 8.0),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _debugEvents
                      .map(
                        (event) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(event,
                              style: FlutterFlowTheme.of(context).bodySmall),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ),
            if (onContinue != null) ...[
              const SizedBox(height: 12.0),
              FFButtonWidget(
                onPressed: onContinue,
                text: 'OK - Continue',
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 44.0,
                  color: FlutterFlowTheme.of(context).secondary,
                  textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).info,
                        letterSpacing: 0.0,
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingBody({
    required String title,
    required String subtitle,
    VoidCallback? onContinue,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FlutterFlowTheme.of(context)
                          .headlineMedium
                          .fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                    ),
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: FlutterFlowTheme.of(context).bodyLarge,
              textAlign: TextAlign.center,
            ),
            _buildDebugPanel(onContinue: onContinue),
          ],
        ),
      ),
    );
  }

  Widget _buildFailedBody(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 44,
              color: FlutterFlowTheme.of(context).error,
            ),
            const SizedBox(height: 16),
            Text(
              'Forecast processing failed',
              style: FlutterFlowTheme.of(context).titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: FlutterFlowTheme.of(context).bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FFButtonWidget(
              onPressed: () =>
                  context.goNamedAuth(Auth2Widget.routeName, context.mounted),
              text: 'Sign up / Login (Auth2)',
              options: FFButtonOptions(
                width: double.infinity,
                height: 44.0,
                color: FlutterFlowTheme.of(context).primary,
                textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).info,
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            const SizedBox(height: 8),
            FFButtonWidget(
              onPressed: () => context.goNamedAuth(
                  ImportDataWidget.routeName, context.mounted),
              text: 'Back to Import Data',
              options: FFButtonOptions(
                width: double.infinity,
                height: 44.0,
                color: FlutterFlowTheme.of(context).secondary,
                textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).info,
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uploadId = widget.uploadId;

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
          automaticallyImplyLeading: true,
          title: Text(
            'Forecast Processing',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).info,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
          ),
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: uploadId == null || uploadId.isEmpty
              ? _buildFailedBody('Missing upload request id.')
              : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('forecasts')
                      .doc(uploadId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      _recordDebugEvent(
                          'Firestore snapshot error: ${snapshot.error}');
                      return _buildFailedBody(
                        'Error while reading processing status: ${snapshot.error}',
                      );
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      _recordDebugEvent(
                          'Waiting for forecasts/${widget.uploadId} document');
                      if (_hasTimedOut) {
                        return _buildFailedBody(
                          'Processing took too long or the forecast document is not accessible yet.',
                        );
                      }
                      return _buildProcessingBody(
                        title: 'Processing forecast in Cloud Run...',
                        subtitle: widget.sourceLabel?.isNotEmpty == true
                            ? 'Source: ${widget.sourceLabel}'
                            : 'Waiting for backend processing to start',
                      );
                    }

                    final data = snapshot.data!.data() ?? {};
                    final status = (data['status'] ?? 'processing')
                        .toString()
                        .toLowerCase();
                    final effectiveSource =
                        (widget.sourceLabel?.isNotEmpty == true)
                            ? widget.sourceLabel
                            : data['source']?.toString();
                    _recordDebugEvent(
                        'Firestore document received. status=$status');

                    if (status == 'failed') {
                      _recordDebugEvent(
                        'Backend reported failure: ${data['error']?.toString() ?? 'Unknown backend error.'}',
                      );
                      return _buildFailedBody(
                        data['error']?.toString() ?? 'Unknown backend error.',
                      );
                    }

                    final rawResults = data['results'];
                    final parsedResults = rawResults is List
                        ? rawResults
                            .whereType<Map>()
                            .map((item) => ForecastRecord.fromMap(
                                  Map<String, dynamic>.from(item),
                                ))
                            .toList(growable: false)
                        : const <ForecastRecord>[];

                    if (status == 'completed' && parsedResults.isNotEmpty) {
                      _recordDebugEvent(
                        'Results ready. ${parsedResults.length} rows received from Firestore.',
                      );
                      if (!widget.debugMode) {
                        _openResults(parsedResults, effectiveSource);
                      }
                      return _buildProcessingBody(
                        title: 'Forecast completed',
                        subtitle: 'Preparing the results page...',
                        onContinue: widget.debugMode
                            ? () => _openResults(parsedResults, effectiveSource)
                            : null,
                      );
                    }

                    return _buildProcessingBody(
                      title: 'Processing forecast in Cloud Run...',
                      subtitle: effectiveSource?.isNotEmpty == true
                          ? 'Source: $effectiveSource'
                          : 'Waiting for backend results',
                    );
                  },
                ),
        ),
      ),
    );
  }
}
