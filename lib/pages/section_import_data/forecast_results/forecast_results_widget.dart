import 'dart:convert';

import '/backend/forecast/forecast_models.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'forecast_results_model.dart';
export 'forecast_results_model.dart';

class ForecastResultsWidget extends StatefulWidget {
  const ForecastResultsWidget({
    super.key,
    this.initialResults,
    this.sourceLabel,
    this.debugMode = false,
  });

  static String routeName = 'forecastResults';
  static String routePath = 'forecastResults';

  final List<dynamic>? initialResults;
  final String? sourceLabel;
  final bool debugMode;

  @override
  State<ForecastResultsWidget> createState() => _ForecastResultsWidgetState();
}

class _ForecastResultsWidgetState extends State<ForecastResultsWidget> {
  late ForecastResultsModel _model;
  late final List<ForecastRecord> _results;
  bool _isPreparingResults = true;
  final List<String> _debugEvents = <String>[];

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ForecastResultsModel());

    _results = (widget.initialResults ?? const [])
        .whereType<Map>()
        .map((item) => ForecastRecord.fromMap(Map<String, dynamic>.from(item)))
        .toList(growable: false);

    if (widget.debugMode) {
      _debugEvents.add('[init] Results page opened with ${_results.length} rows.');
      _debugEvents.add('[init] Waiting for chart and table rendering.');
    }

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) {
        return;
      }
      safeSetState(() {
        _isPreparingResults = false;
        if (widget.debugMode) {
          _debugEvents.add('[ready] Chart and data sheet rendered.');
        }
      });
    });
  }

  Widget _buildDebugPanel() {
    if (!widget.debugMode) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16.0),
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
            Text('Results debug trace', style: FlutterFlowTheme.of(context).titleSmall),
            const SizedBox(height: 8.0),
            ..._debugEvents.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(event, style: FlutterFlowTheme.of(context).bodySmall),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _downloadCsv(List<ForecastRecord> rows) async {
    final buffer = StringBuffer('product_id,month_year,forecast_qty\n');
    for (final row in rows) {
      buffer.writeln('${row.productId},${row.monthYear},${row.forecastQty}');
    }

    final csvBytes = Uint8List.fromList(utf8.encode(buffer.toString()));
    await Share.shareXFiles(
      [
        XFile.fromData(
          csvBytes,
          mimeType: 'text/csv',
          name: 'forecast_results.csv',
        ),
      ],
      text: 'Forecast results export',
      subject: 'forecast_results.csv',
    );
  }

  Widget _buildLoadingResultsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 16),
            Text(
              'Forecast Results',
              style: FlutterFlowTheme.of(context).titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Loading chart and data sheet...',
              style: FlutterFlowTheme.of(context).bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsContent({
    required List<ForecastRecord> results,
    String? sourceLabel,
  }) {
    final monthlyTotals = <String, double>{};
    for (final row in results) {
      monthlyTotals[row.monthYear] =
          (monthlyTotals[row.monthYear] ?? 0) + row.forecastQty;
    }

    final sortedMonths = monthlyTotals.keys.toList()..sort();
    final lineSpots = sortedMonths
        .asMap()
        .entries
        .map((entry) =>
            FlSpot(entry.key.toDouble(), monthlyTotals[entry.value] ?? 0))
        .toList(growable: false);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sourceLabel?.isNotEmpty == true
                ? 'Source: $sourceLabel'
                : 'Forecast generated successfully',
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
          _buildDebugPanel(),
          const SizedBox(height: 16.0),
          Container(
            width: double.infinity,
            height: 240.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: lineSpots.isEmpty
                  ? Center(
                      child: Text(
                        'No chart data available.',
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: null,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: FlutterFlowTheme.of(context).alternate,
                            strokeWidth: 1.0,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 48.0,
                              getTitlesWidget: (value, meta) => Text(
                                value.toStringAsFixed(0),
                                style: FlutterFlowTheme.of(context).bodySmall,
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28.0,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= sortedMonths.length) {
                                  return const SizedBox.shrink();
                                }
                                final monthLabel = sortedMonths[index];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    monthLabel.length >= 7
                                        ? monthLabel.substring(0, 7)
                                        : monthLabel,
                                    style:
                                        FlutterFlowTheme.of(context).bodySmall,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).alternate,
                          ),
                        ),
                        minX: 0,
                        maxX: (lineSpots.length - 1).toDouble(),
                        lineBarsData: [
                          LineChartBarData(
                            spots: lineSpots,
                            isCurved: true,
                            color: FlutterFlowTheme.of(context).primary,
                            barWidth: 3.0,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (_, __, ___, ____) =>
                                  FlDotCirclePainter(
                                radius: 3.0,
                                color: FlutterFlowTheme.of(context).primary,
                                strokeColor: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    headingTextStyle: FlutterFlowTheme.of(context).labelLarge,
                    dataTextStyle: FlutterFlowTheme.of(context).bodyMedium,
                    columns: const [
                      DataColumn(label: Text('Product ID')),
                      DataColumn(label: Text('Month')),
                      DataColumn(label: Text('Forecast Qty')),
                    ],
                    rows: results
                        .map(
                          (row) => DataRow(
                            cells: [
                              DataCell(Text(row.productId)),
                              DataCell(Text(row.monthYear)),
                              DataCell(
                                  Text(row.forecastQty.toStringAsFixed(2))),
                            ],
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: FFButtonWidget(
                  onPressed: () => _downloadCsv(results),
                  text: 'Download CSV',
                  options: FFButtonOptions(
                    height: 48.0,
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    iconPadding:
                        const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.inter(
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
              ),
            ],
          ),
        ],
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
          automaticallyImplyLeading: true,
          title: Text(
            'Forecast Results',
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
          child: _results.isEmpty
              ? Center(
                  child: Text(
                    'No forecast data available.',
                    style: FlutterFlowTheme.of(context).bodyLarge,
                  ),
                )
              : _isPreparingResults
                  ? _buildLoadingResultsView()
                  : _buildResultsContent(
                      results: _results,
                      sourceLabel: widget.sourceLabel,
                    ),
        ),
      ),
    );
  }
}
