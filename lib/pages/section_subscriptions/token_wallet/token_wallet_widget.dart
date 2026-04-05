//import '/app_state.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TokenWalletWidget extends StatefulWidget {
  const TokenWalletWidget({super.key});

  static String routeName = 'tokenWallet';
  static String routePath = 'tokenWallet';

  @override
  State<TokenWalletWidget> createState() => _TokenWalletWidgetState();
}

class _TokenWalletWidgetState extends State<TokenWalletWidget> {
  late TextEditingController _horizonController;
  late TextEditingController _timezoneController;
  String _selectedGranularity = 'Weekly';

  @override
  void initState() {
    super.initState();
    _horizonController = TextEditingController(
        text: FFAppState().defaultForecastHorizon.toString());
    _timezoneController =
        TextEditingController(text: FFAppState().defaultTimezone);
    _selectedGranularity = FFAppState().defaultGranularity;
  }

  @override
  void dispose() {
    _horizonController.dispose();
    _timezoneController.dispose();
    super.dispose();
  }

  void _consumeTokens(int amount) {
    final appState = FFAppState();
    appState.update(() {
      final next = appState.usedTokensThisMonth + amount;
      appState.usedTokensThisMonth =
          next > appState.monthlyTokenLimit ? appState.monthlyTokenLimit : next;
    });
  }

  void _saveForecastDefaults() {
    final parsedHorizon = int.tryParse(_horizonController.text.trim());
    if (parsedHorizon == null || parsedHorizon <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid horizon in days.')),
      );
      return;
    }

    FFAppState().update(() {
      FFAppState().defaultForecastHorizon = parsedHorizon;
      FFAppState().defaultGranularity = _selectedGranularity;
      FFAppState().defaultTimezone = _timezoneController.text.trim().isEmpty
          ? 'Europe/Athens'
          : _timezoneController.text.trim();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Forecast option defaults saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = FFAppState();
    final remaining =
        (appState.monthlyTokenLimit - appState.usedTokensThisMonth)
            .clamp(0, 999999);
    final usage = appState.monthlyTokenLimit == 0
        ? 0.0
        : appState.usedTokensThisMonth / appState.monthlyTokenLimit;

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        title: Text(
          'Token Wallet',
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7FF),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: const Color(0xFFD8CCE8)),
                ),
                child: Text(
                  'Auth User: ${currentUserUid.isEmpty ? 'guest-user' : currentUserUid}\nPlan: ${appState.subscriptionPlan}',
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              ),
              const SizedBox(height: 12.0),
              Text('Token Consumption',
                  style: FlutterFlowTheme.of(context).titleMedium),
              const SizedBox(height: 6.0),
              Text(
                'Used ${appState.usedTokensThisMonth} / ${appState.monthlyTokenLimit} • Remaining $remaining',
                style: FlutterFlowTheme.of(context).bodyMedium,
              ),
              const SizedBox(height: 8.0),
              ClipRRect(
                borderRadius: BorderRadius.circular(999.0),
                child: LinearProgressIndicator(
                  value: usage.clamp(0.0, 1.0),
                  minHeight: 8.0,
                  backgroundColor: const Color(0xFFE8EBF0),
                ),
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: FFButtonWidget(
                      onPressed: () {
                        _consumeTokens(25);
                        safeSetState(() {});
                      },
                      text: 'Simulate +25',
                      options: FFButtonOptions(
                        height: 40.0,
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle: FlutterFlowTheme.of(context)
                            .bodySmall
                            .override(color: Colors.white, letterSpacing: 0.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: FFButtonWidget(
                      onPressed: () {
                        appState.update(() {
                          appState.usedTokensThisMonth = 0;
                        });
                        safeSetState(() {});
                      },
                      text: 'Reset month',
                      options: FFButtonOptions(
                        height: 40.0,
                        color: FlutterFlowTheme.of(context).secondary,
                        textStyle: FlutterFlowTheme.of(context)
                            .bodySmall
                            .override(color: Colors.white, letterSpacing: 0.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Text('Forecast Options',
                  style: FlutterFlowTheme.of(context).titleMedium),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _horizonController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Forecast horizon (days)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                initialValue: _selectedGranularity,
                decoration: const InputDecoration(
                  labelText: 'Granularity',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  safeSetState(() {
                    _selectedGranularity = value;
                  });
                },
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: _timezoneController,
                decoration: const InputDecoration(
                  labelText: 'Timezone',
                  hintText: 'Europe/Athens',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10.0),
              FFButtonWidget(
                onPressed: _saveForecastDefaults,
                text: 'Save Option Defaults',
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 42.0,
                  color: const Color(0xFF455A64),
                  textStyle: FlutterFlowTheme.of(context)
                      .bodyMedium
                      .override(color: Colors.white, letterSpacing: 0.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
