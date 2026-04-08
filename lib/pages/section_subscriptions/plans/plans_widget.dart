import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscriptionPlansWidget extends StatefulWidget {
  const SubscriptionPlansWidget({super.key});

  static String routeName = 'subscriptionPlans';
  static String routePath = 'subscriptionPlans';

  @override
  State<SubscriptionPlansWidget> createState() =>
      _SubscriptionPlansWidgetState();
}

class _SubscriptionPlansWidgetState extends State<SubscriptionPlansWidget> {
  void _setPlan(String plan) {
    final appState = FFAppState();
    appState.update(() {
      appState.subscriptionPlan = plan;
      switch (plan) {
        case 'Freemium':
          appState.monthlyTokenLimit = 300;
          appState.maxSkusPerRun = 1;
          appState.batchUploadsEnabled = false;
          appState.apiAccessEnabled = false;
          appState.customModelsEnabled = false;
          break;
        case 'Starter':
          appState.monthlyTokenLimit = 1500;
          appState.maxSkusPerRun = 50;
          appState.batchUploadsEnabled = false;
          appState.apiAccessEnabled = false;
          appState.customModelsEnabled = false;
          break;
        case 'Pro':
          appState.monthlyTokenLimit = 8000;
          appState.maxSkusPerRun = 500;
          appState.batchUploadsEnabled = true;
          appState.apiAccessEnabled = true;
          appState.customModelsEnabled = true;
          break;
        case 'Consulting':
          appState.monthlyTokenLimit = 20000;
          appState.maxSkusPerRun = 2000;
          appState.batchUploadsEnabled = true;
          appState.apiAccessEnabled = true;
          appState.customModelsEnabled = true;
          break;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Active plan switched to $plan.')),
    );
  }

  Widget _row(String plan, String pricing, String skus, String features) {
    final selected = FFAppState().subscriptionPlan == plan;
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE3F2FD) : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: selected ? const Color(0xFF0D47A1) : const Color(0xFFD9E0EA),
          width: selected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$plan  •  $pricing',
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FlutterFlowTheme.of(context)
                              .titleSmall
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).titleSmall.fontStyle,
                        ),
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              FFButtonWidget(
                onPressed: () => _setPlan(plan),
                text: selected ? 'Active' : 'Select',
                options: FFButtonOptions(
                  width: 90.0,
                  height: 36.0,
                  color: selected
                      ? const Color(0xFF0D47A1)
                      : FlutterFlowTheme.of(context).secondary,
                  textStyle: FlutterFlowTheme.of(context)
                      .bodySmall
                      .override(color: Colors.white, letterSpacing: 0.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          Text('SKU Limit: $skus',
              style: FlutterFlowTheme.of(context).bodySmall),
          const SizedBox(height: 4.0),
          Text(features, style: FlutterFlowTheme.of(context).bodySmall),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          borderWidth: 1.0,
          buttonSize: 60.0,
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 30.0,
          ),
          onPressed: () async {
            context.safePop();
          },
        ),
        title: Text(
          'Plan Comparison',
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
                'Pricing & Business Model Deployment',
                style: FlutterFlowTheme.of(context).titleMedium,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Freemium for single-SKU trials, Starter for small businesses, Pro for API + batch workflows, Consulting for integration-heavy use-cases.',
                style: FlutterFlowTheme.of(context).bodyMedium,
              ),
              const SizedBox(height: 12.0),
              _row('Freemium', 'EUR 0/mo', '1 SKU',
                  'Single-SKU forecast, basic tokens, perfect for onboarding.'),
              _row('Starter', 'EUR 19/mo', 'Up to 50 SKUs',
                  'Small business usage with increased token budget.'),
              _row('Pro', 'EUR 59/mo', 'Up to 500 SKUs',
                  'API access, batch uploads, custom models.'),
              _row('Consulting', 'Custom', 'Custom capacity',
                  'Personalized forecasting setups and integrations.'),
              const SizedBox(height: 14.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F9FF),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: const Color(0xFFD9E0EA)),
                ),
                child: Text(
                  'Current active plan: ${FFAppState().subscriptionPlan}\nToken limit: ${FFAppState().monthlyTokenLimit}\nMax SKUs per run: ${FFAppState().maxSkusPerRun}',
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
