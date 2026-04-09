import 'dart:convert';

import '/backend/forecast/forecast_models.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  bool get _isAnonymousUser =>
      FirebaseAuth.instance.currentUser?.isAnonymous ?? false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ForecastResultsModel());

    _results = (widget.initialResults ?? const [])
        .whereType<Map>()
        .map((item) => ForecastRecord.fromMap(Map<String, dynamic>.from(item)))
        .toList(growable: false);

    if (widget.debugMode) {
      _debugEvents
          .add('[init] Results page opened with ${_results.length} rows.');
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
            Text('Results debug trace',
                style: FlutterFlowTheme.of(context).titleSmall),
            const SizedBox(height: 8.0),
            ..._debugEvents.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child:
                    Text(event, style: FlutterFlowTheme.of(context).bodySmall),
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
<<<<<<< HEAD
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            csvBytes,
            mimeType: 'text/csv',
            name: 'forecast_results.csv',
          ),
        ],
        text: 'Forecast results export',
        subject: 'forecast_results.csv',
      ),
=======
    final params = ShareParams(
      files: [
        XFile.fromData(
          csvBytes,
          mimeType: 'text/csv',
          name: 'forecast_results.csv',
        ),
      ],
      text: 'Forecast results export',
      subject: 'forecast_results.csv',
>>>>>>> b92751a4cf3a231030ccd6a0af4949f66f56dd4c
    );
    await SharePlus.instance.share(params);
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

  DateTime? _tryParseMonthYear(String value) {
    final raw = value.trim();
    if (raw.isEmpty) {
      return null;
    }

    final direct = DateTime.tryParse(raw);
    if (direct != null) {
      return DateTime.utc(direct.year, direct.month, 1);
    }

    final yearMonthMatch = RegExp(r'^(\d{4})[-/](\d{1,2})').firstMatch(raw);
    if (yearMonthMatch != null) {
      final year = int.tryParse(yearMonthMatch.group(1)!);
      final month = int.tryParse(yearMonthMatch.group(2)!);
      if (year != null && month != null && month >= 1 && month <= 12) {
        return DateTime.utc(year, month, 1);
      }
    }

    final compactMonthMatch =
        RegExp(r'^([A-Za-z]{3})\s?(\d{4})$').firstMatch(raw);
    if (compactMonthMatch != null) {
      final monthToken = compactMonthMatch.group(1)!.toLowerCase();
      final year = int.tryParse(compactMonthMatch.group(2)!);
      const monthMap = {
        'jan': 1,
        'feb': 2,
        'mar': 3,
        'apr': 4,
        'may': 5,
        'jun': 6,
        'jul': 7,
        'aug': 8,
        'sep': 9,
        'oct': 10,
        'nov': 11,
        'dec': 12,
      };
      final month = monthMap[monthToken];
      if (month != null && year != null) {
        return DateTime.utc(year, month, 1);
      }
    }

    return null;
  }

  String _formatMonthLabel(DateTime date) =>
      '${DateFormat('MMM').format(date)}${date.year}';

  Widget _buildResultsContent({
    required List<ForecastRecord> results,
    String? sourceLabel,
  }) {
    final horizonDays = FFAppState().forecastHorizonDays;
    final horizonMonthsByDays = <int, int>{30: 1, 90: 3, 365: 12};
    final targetMonths = horizonMonthsByDays[horizonDays] ?? 3;
    final nowUtc = DateTime.now().toUtc();
    final defaultReference = DateTime.utc(nowUtc.year, nowUtc.month, 1);
    final parsedReference = DateTime.tryParse(
      FFAppState().forecastReferenceDateIso ?? '',
    );
    final referenceMonth = DateTime.utc(
      (parsedReference ?? defaultReference).year,
      (parsedReference ?? defaultReference).month,
      1,
    );
    final firstForecastMonth = DateTime.utc(
      referenceMonth.year,
      referenceMonth.month + 1,
      1,
    );
    final timelineMonths = List<DateTime>.generate(
      targetMonths,
      (index) => DateTime.utc(
        firstForecastMonth.year,
        firstForecastMonth.month + index,
        1,
      ),
      growable: false,
    );

    final timelineLabels =
        timelineMonths.map(_formatMonthLabel).toList(growable: false);

    final normalizedResults = results.map((row) {
      final parsed = _tryParseMonthYear(row.monthYear);
      final normalizedMonth =
          parsed != null ? _formatMonthLabel(parsed) : row.monthYear;
      return ForecastRecord(
        productId: row.productId,
        monthYear: normalizedMonth,
        forecastQty: row.forecastQty,
      );
    }).toList(growable: false);

    final uniqueBackendMonths = normalizedResults
        .map((row) => row.monthYear)
        .toSet()
        .toList(growable: false)
      ..sort((a, b) {
        final aDate = _tryParseMonthYear(a);
        final bDate = _tryParseMonthYear(b);
        if (aDate != null && bDate != null) {
          return aDate.compareTo(bDate);
        }
        if (aDate != null) {
          return -1;
        }
        if (bDate != null) {
          return 1;
        }
        return a.compareTo(b);
      });

    final backendToTimelineMonth = <String, String>{};
    for (var i = 0;
        i < uniqueBackendMonths.length && i < timelineLabels.length;
        i++) {
      backendToTimelineMonth[uniqueBackendMonths[i]] = timelineLabels[i];
    }

    List<ForecastRecord> displayResults = normalizedResults
        .where((row) => backendToTimelineMonth.containsKey(row.monthYear))
        .map(
          (row) => ForecastRecord(
            productId: row.productId,
            monthYear: backendToTimelineMonth[row.monthYear]!,
            forecastQty: row.forecastQty,
          ),
        )
        .toList(growable: false);

    if (displayResults.isEmpty && normalizedResults.isNotEmpty) {
      displayResults = normalizedResults
          .map(
            (row) => ForecastRecord(
              productId: row.productId,
              monthYear: timelineLabels.first,
              forecastQty: row.forecastQty,
            ),
          )
          .toList(growable: false);
    }

    final skuLabels = displayResults
        .map((row) => row.productId)
        .where((sku) => sku.trim().isNotEmpty)
        .toSet()
        .toList(growable: false)
      ..sort();
    final skuIndexByLabel = {
      for (var i = 0; i < skuLabels.length; i++) skuLabels[i]: i,
    };
    final monthIndexByLabel = {
      for (var i = 0; i < timelineLabels.length; i++) timelineLabels[i]: i,
    };

    final uniqueCoordinates = <String>{};
    final scatterSpots = <ScatterSpot>[];
    for (final row in displayResults) {
      final x = skuIndexByLabel[row.productId];
      final y = monthIndexByLabel[row.monthYear];
      if (x == null || y == null) {
        continue;
      }
      final key = '$x|$y';
      if (uniqueCoordinates.add(key)) {
        scatterSpots.add(
          ScatterSpot(
            x.toDouble(),
            y.toDouble(),
            dotPainter: FlDotCirclePainter(
              radius: 4.0,
              color: FlutterFlowTheme.of(context).primary,
              strokeWidth: 1.0,
              strokeColor: FlutterFlowTheme.of(context).secondaryBackground,
            ),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sourceLabel?.isNotEmpty == true
                  ? 'Source: $sourceLabel'
                  : 'Forecast generated successfully',
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
            if (FFAppState().selectedBusinessMarket != null ||
                FFAppState().selectedMarketCountry != null ||
                FFAppState().forecastHorizonDays != null)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  'Market: ${FFAppState().selectedBusinessMarket ?? '-'} | Country: ${FFAppState().selectedMarketCountry ?? '-'} | Forecast horizon: ${FFAppState().forecastHorizonDays ?? '-'} days',
                  style: FlutterFlowTheme.of(context).bodySmall,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Forecast start month: ${DateFormat('MMM yyyy').format(referenceMonth)}',
                style: FlutterFlowTheme.of(context).bodySmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                'Forecast window: ${DateFormat('MMM yyyy').format(firstForecastMonth)} to ${DateFormat('MMM yyyy').format(timelineMonths.last)}',
                style: FlutterFlowTheme.of(context).bodySmall,
              ),
            ),
            _buildDebugPanel(),
            const SizedBox(height: 16.0),
            Container(
              width: double.infinity,
              height: 280.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: skuLabels.length <= 6
                      ? 680.0
                      : (skuLabels.length * 120.0).clamp(680.0, 3200.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: scatterSpots.isEmpty
                        ? Center(
                            child: Text(
                              'No chart data available.',
                              style: FlutterFlowTheme.of(context).bodyMedium,
                            ),
                          )
                        : ScatterChart(
                            ScatterChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: true,
                                horizontalInterval: null,
                                getDrawingHorizontalLine: (_) => FlLine(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  strokeWidth: 1.0,
                                ),
                                getDrawingVerticalLine: (_) => FlLine(
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
                                  axisNameWidget: Text(
                                    'Month/Year',
                                    style:
                                        FlutterFlowTheme.of(context).bodySmall,
                                  ),
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 78.0,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index < 0 ||
                                          index >= timelineLabels.length) {
                                        return const SizedBox.shrink();
                                      }
                                      return Text(
                                        timelineLabels[index],
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall,
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  axisNameWidget: Text(
                                    'SKU (product_id)',
                                    style:
                                        FlutterFlowTheme.of(context).bodySmall,
                                  ),
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 64.0,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index < 0 ||
                                          index >= skuLabels.length) {
                                        return const SizedBox.shrink();
                                      }
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(top: 6.0),
                                        child: Transform.rotate(
                                          angle: -0.5,
                                          child: Text(
                                            skuLabels[index],
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall,
                                            overflow: TextOverflow.ellipsis,
                                          ),
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
                              maxX: (skuLabels.length - 1).toDouble(),
                              minY: 0,
                              maxY: (timelineLabels.length - 1).toDouble(),
                              scatterSpots: scatterSpots,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              width: double.infinity,
              height: 280.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingTextStyle: FlutterFlowTheme.of(context).labelLarge,
                      dataTextStyle: FlutterFlowTheme.of(context).bodyMedium,
                      columns: const [
                        DataColumn(label: Text('Product ID')),
                        DataColumn(label: Text('Month')),
                        DataColumn(label: Text('Forecast Qty')),
                      ],
                      rows: displayResults
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
                  child: _isAnonymousUser
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Anonymous mode: You can view chart and data, but download is available only for authenticated users.',
                              style: FlutterFlowTheme.of(context).bodySmall,
                            ),
                            const SizedBox(height: 10.0),
                            FFButtonWidget(
                              onPressed: () => context.goNamedAuth(
                                Auth2Widget.routeName,
                                context.mounted,
                              ),
                              text: 'Sign up / Login to enable download',
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 48.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 0, 0, 0),
                                iconPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        0, 0, 0, 0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
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
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                elevation: 2.0,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            FFButtonWidget(
                              onPressed: () => context.goNamedAuth(
                                WelcomeWidget.routeName,
                                context.mounted,
                              ),
                              text: 'Exit to Welcome',
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 44.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 0, 0, 0),
                                iconPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        0, 0, 0, 0),
                                color: FlutterFlowTheme.of(context).secondary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
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
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                elevation: 0.0,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ],
                        )
                      : FFButtonWidget(
                          onPressed: () => _downloadCsv(displayResults),
                          text: 'Download CSV',
                          options: FFButtonOptions(
                            height: 48.0,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 0, 0, 0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0, 0, 0, 0),
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
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
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontStyle,
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
