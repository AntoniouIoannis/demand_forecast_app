import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForecastUxLabWidget extends StatefulWidget {
  const ForecastUxLabWidget({super.key});

  static String routeName = 'forecastUxLab';
  static String routePath = 'forecastUxLab';

  @override
  State<ForecastUxLabWidget> createState() => _ForecastUxLabWidgetState();
}

class _ForecastUxLabWidgetState extends State<ForecastUxLabWidget> {
  bool _fileAttached = false;
  bool _columnsDetected = false;
  bool _trained = false;

  final List<List<String>> _previewRows = const [
    ['2025-01-01', 'SKU-001', '24'],
    ['2025-01-08', 'SKU-001', '28'],
    ['2025-01-15', 'SKU-001', '22'],
    ['2025-01-22', 'SKU-001', '31'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        title: Text(
          'Forecast UX Lab',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                font: GoogleFonts.interTight(
                  fontWeight:
                      FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).info,
                letterSpacing: 0.0,
              ),
        ),
      ),
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Frontend & UX Deployment Targets',
                style: FlutterFlowTheme.of(context).titleMedium,
              ),
              const SizedBox(height: 6.0),
              Text(
                'Goal: upload -> forecast -> export in under 2 minutes, with an instant-feeling first response under 30 seconds.',
                style: FlutterFlowTheme.of(context).bodyMedium,
              ),
              const SizedBox(height: 12.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F9FC),
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: const Color(0xFFD6DEE8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1) Upload (Drag & Drop style)',
                        style: FlutterFlowTheme.of(context).titleSmall),
                    const SizedBox(height: 8.0),
                    InkWell(
                      onTap: () {
                        safeSetState(() {
                          _fileAttached = true;
                          _columnsDetected = true;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18.0),
                        decoration: BoxDecoration(
                          color: _fileAttached
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: _fileAttached
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFB7C5D4),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          _fileAttached
                              ? 'File attached: sales_2025.csv (demo)'
                              : 'Tap to simulate drag-drop upload',
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      _columnsDetected
                          ? 'Auto-detected columns: date, product_id, quantity'
                          : 'Columns will be auto-detected after upload.',
                      style: FlutterFlowTheme.of(context).bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: const Color(0xFFD6DEE8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('2) Data Preview',
                        style: FlutterFlowTheme.of(context).titleSmall),
                    const SizedBox(height: 8.0),
                    Table(
                      border: TableBorder.all(color: const Color(0xFFD9E2EC)),
                      children: [
                        const TableRow(children: [
                          Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Text('date'),
                          ),
                          Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Text('product_id'),
                          ),
                          Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Text('quantity'),
                          ),
                        ]),
                        ..._previewRows.map(
                          (row) => TableRow(
                            children: row
                                .map((cell) => Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Text(cell),
                                    ))
                                .toList(growable: false),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: const Color(0xFFD6DEE8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('3) Forecast Options',
                        style: FlutterFlowTheme.of(context).titleSmall),
                    const SizedBox(height: 6.0),
                    Text(
                      'Horizon: ${FFAppState().defaultForecastHorizon} days | Granularity: ${FFAppState().defaultGranularity} | Timezone: ${FFAppState().defaultTimezone}',
                      style: FlutterFlowTheme.of(context).bodySmall,
                    ),
                    const SizedBox(height: 8.0),
                    FFButtonWidget(
                      onPressed: () {
                        safeSetState(() {
                          _trained = true;
                        });
                      },
                      text: 'Train Model (Demo)',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 40.0,
                        color: const Color(0xFF00695C),
                        textStyle: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .override(color: Colors.white, letterSpacing: 0.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF2),
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: const Color(0xFFFFDF9A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('4) Results (Interactive Chart + Confidence Bands)',
                        style: FlutterFlowTheme.of(context).titleSmall),
                    const SizedBox(height: 8.0),
                    Container(
                      height: 140.0,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFF5D8), Color(0xFFFFE7A7)],
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                        child: Text(
                          _trained
                              ? 'Chart ready (line + confidence bands)'
                              : 'Run training to render forecast chart area',
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Diagnostics: SMAPE 12.4% | MAPE 10.7% | RMSE 5.8',
                      style: FlutterFlowTheme.of(context).bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12.0),
              FFButtonWidget(
                onPressed: _trained
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Exported forecast table + diagnostics (demo).'),
                          ),
                        );
                      }
                    : null,
                text: 'Download Excel / CSV',
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 44.0,
                  color: const Color(0xFF5D4037),
                  textStyle: FlutterFlowTheme.of(context)
                      .bodyMedium
                      .override(color: Colors.white, letterSpacing: 0.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
