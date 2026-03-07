import '/backend/forecast/forecast_models.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForecastProcessingWidget extends StatefulWidget {
  const ForecastProcessingWidget({
    super.key,
    this.uploadId,
    this.sourceLabel,
  });

  static String routeName = 'forecastProcessing';
  static String routePath = 'forecastProcessing';

  final String? uploadId;
  final String? sourceLabel;

  @override
  State<ForecastProcessingWidget> createState() =>
      _ForecastProcessingWidgetState();
}

class _ForecastProcessingWidgetState extends State<ForecastProcessingWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _hasNavigatedToResults = false;

  void _openResults(List<ForecastRecord> results, String? sourceLabel) {
    if (_hasNavigatedToResults || !mounted) {
      return;
    }

    _hasNavigatedToResults = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.goNamedAuth(
        ForecastResultsWidget.routeName,
        context.mounted,
        extra: {
          'results': results.map((entry) => entry.toMap()).toList(growable: false),
          'sourceLabel': sourceLabel,
        },
      );
    });
  }

  Widget _buildProcessingBody({
    required String title,
    required String subtitle,
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
                      fontStyle: FlutterFlowTheme.of(context)
                          .headlineMedium
                          .fontStyle,
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
                      return _buildFailedBody(
                        'Error while reading processing status: ${snapshot.error}',
                      );
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return _buildProcessingBody(
                        title: 'Processing forecast in Cloud Run...',
                        subtitle: widget.sourceLabel?.isNotEmpty == true
                            ? 'Source: ${widget.sourceLabel}'
                            : 'Waiting for backend processing to start',
                      );
                    }

                    final data = snapshot.data!.data() ?? {};
                    final status =
                        (data['status'] ?? 'processing').toString().toLowerCase();
                    final effectiveSource = (widget.sourceLabel?.isNotEmpty == true)
                        ? widget.sourceLabel
                        : data['source']?.toString();

                    if (status == 'failed') {
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
                      _openResults(parsedResults, effectiveSource);
                      return _buildProcessingBody(
                        title: 'Forecast completed',
                        subtitle: 'Preparing the results page...',
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