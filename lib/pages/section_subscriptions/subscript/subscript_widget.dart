import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/app_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'subscript_model.dart';
export 'subscript_model.dart';

class SubscriptWidget extends StatefulWidget {
  const SubscriptWidget({super.key});

  static String routeName = 'subscript';
  static String routePath = 'subscript';

  @override
  State<SubscriptWidget> createState() => _SubscriptWidgetState();
}

class _SubscriptWidgetState extends State<SubscriptWidget> {
  late SubscriptModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SubscriptModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _applyPlan(String plan) {
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
      if (appState.usedTokensThisMonth > appState.monthlyTokenLimit) {
        appState.usedTokensThisMonth = appState.monthlyTokenLimit;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Plan set to $plan for user token controls.')),
    );
  }

  Widget _planCard({
    required String title,
    required String subtitle,
    required String price,
    required List<String> bullets,
    required bool selected,
    required VoidCallback onSelect,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE8F0FE) : Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: selected ? const Color(0xFF1565C0) : const Color(0xFFD6DEEA),
          width: selected ? 2.0 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).titleMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).titleMedium.fontStyle,
                  ),
                  letterSpacing: 0.0,
                ),
          ),
          const SizedBox(height: 4.0),
          Text(price, style: FlutterFlowTheme.of(context).headlineSmall),
          const SizedBox(height: 6.0),
          Text(subtitle, style: FlutterFlowTheme.of(context).bodySmall),
          const SizedBox(height: 8.0),
          ...bullets.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text('- $item',
                  style: FlutterFlowTheme.of(context).bodySmall),
            ),
          ),
          const SizedBox(height: 10.0),
          FFButtonWidget(
            onPressed: onSelect,
            text: selected ? 'Selected' : 'Choose $title',
            options: FFButtonOptions(
              width: double.infinity,
              height: 40.0,
              color: selected
                  ? const Color(0xFF1565C0)
                  : FlutterFlowTheme.of(context).secondary,
              textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    color: Colors.white,
                    letterSpacing: 0.0,
                  ),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = FFAppState();
    final userId = currentUserUid.isEmpty ? 'guest-user' : currentUserUid;
    final userEmail =
        currentUserEmail.isEmpty ? 'Not signed in' : currentUserEmail;
    final tokensLeft =
        (appState.monthlyTokenLimit - appState.usedTokensThisMonth)
            .clamp(0, 999999);
    final usageFraction = appState.monthlyTokenLimit == 0
        ? 0.0
        : appState.usedTokensThisMonth / appState.monthlyTokenLimit;

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
            'Subscriptions & Tokens',
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
          elevation: 2.0,
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
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0B3B6E), Color(0xFF1565C0)],
                    ),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Auth User: $userId',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(color: Colors.white)),
                      const SizedBox(height: 4.0),
                      Text('Email: $userEmail',
                          style: FlutterFlowTheme.of(context)
                              .bodySmall
                              .override(color: const Color(0xFFE6ECF5))),
                      const SizedBox(height: 8.0),
                      Text('Current Plan: ${appState.subscriptionPlan}',
                          style: FlutterFlowTheme.of(context)
                              .titleSmall
                              .override(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  'Pricing & Business Model',
                  style: FlutterFlowTheme.of(context).titleMedium,
                ),
                const SizedBox(height: 8.0),
                _planCard(
                  title: 'Freemium',
                  price: 'EUR 0 / month',
                  subtitle: 'Single-SKU forecast free, fast onboarding.',
                  bullets: const [
                    'Up to 1 SKU per forecast',
                    'Token wallet enabled',
                    'Great for testing the flow',
                  ],
                  selected: appState.subscriptionPlan == 'Freemium',
                  onSelect: () => _applyPlan('Freemium'),
                ),
                const SizedBox(height: 10.0),
                _planCard(
                  title: 'Starter',
                  price: 'EUR 19 / month',
                  subtitle: 'For small businesses up to 50 SKUs.',
                  bullets: const [
                    'Up to 50 SKUs',
                    'Higher monthly token limit',
                    'Ideal for regular weekly forecasts',
                  ],
                  selected: appState.subscriptionPlan == 'Starter',
                  onSelect: () => _applyPlan('Starter'),
                ),
                const SizedBox(height: 10.0),
                _planCard(
                  title: 'Pro',
                  price: 'EUR 59 / month',
                  subtitle: 'API access, batch uploads, custom models.',
                  bullets: const [
                    'API access enabled',
                    'Batch uploads enabled',
                    'Custom model configuration',
                  ],
                  selected: appState.subscriptionPlan == 'Pro',
                  onSelect: () => _applyPlan('Pro'),
                ),
                const SizedBox(height: 10.0),
                _planCard(
                  title: 'Consulting',
                  price: 'Custom pricing',
                  subtitle: 'Personalized forecasting and integrations.',
                  bullets: const [
                    'High-volume token budget',
                    'Integration support',
                    'Tailored forecasting setup',
                  ],
                  selected: appState.subscriptionPlan == 'Consulting',
                  onSelect: () => _applyPlan('Consulting'),
                ),
                const SizedBox(height: 16.0),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FC),
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(color: const Color(0xFFD6DEEA)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Per-user Token Wallet',
                          style: FlutterFlowTheme.of(context).titleSmall),
                      const SizedBox(height: 6.0),
                      Text(
                        'Used ${appState.usedTokensThisMonth} / ${appState.monthlyTokenLimit} tokens',
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                      const SizedBox(height: 8.0),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999.0),
                        child: LinearProgressIndicator(
                          value: usageFraction.clamp(0.0, 1.0),
                          minHeight: 8.0,
                          backgroundColor: const Color(0xFFE4EAF2),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text('Remaining tokens: $tokensLeft',
                          style: FlutterFlowTheme.of(context).bodySmall),
                      const SizedBox(height: 8.0),
                      Text(
                        'Capabilities: max SKUs ${appState.maxSkusPerRun}, batch uploads ${appState.batchUploadsEnabled ? 'on' : 'off'}, API ${appState.apiAccessEnabled ? 'on' : 'off'}',
                        style: FlutterFlowTheme.of(context).bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(color: const Color(0xFFD6DEEA)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Core User Flow Target',
                          style: FlutterFlowTheme.of(context).titleSmall),
                      const SizedBox(height: 6.0),
                      Text('1. Upload file (Excel/CSV)',
                          style: FlutterFlowTheme.of(context).bodySmall),
                      Text('2. Validate and auto-detect columns',
                          style: FlutterFlowTheme.of(context).bodySmall),
                      Text('3. Train demand forecast model',
                          style: FlutterFlowTheme.of(context).bodySmall),
                      Text('4. Show chart + confidence bands + metrics',
                          style: FlutterFlowTheme.of(context).bodySmall),
                      Text('5. Export diagnostics (Excel/CSV)',
                          style: FlutterFlowTheme.of(context).bodySmall),
                      const SizedBox(height: 8.0),
                      Text(
                        'Target UX: upload -> forecast -> export in under 2 minutes and perceived result speed under 30 seconds.',
                        style: FlutterFlowTheme.of(context).bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14.0),
                FFButtonWidget(
                  onPressed: () => context.pushNamedAuth(
                    SubscriptionPlansWidget.routeName,
                    context.mounted,
                  ),
                  text: 'Open Plan Comparison Page',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 44.0,
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context)
                        .bodyMedium
                        .override(color: Colors.white, letterSpacing: 0.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                const SizedBox(height: 10.0),
                FFButtonWidget(
                  onPressed: () => context.pushNamedAuth(
                    TokenWalletWidget.routeName,
                    context.mounted,
                  ),
                  text: 'Open Token Wallet Page',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 44.0,
                    color: FlutterFlowTheme.of(context).secondary,
                    textStyle: FlutterFlowTheme.of(context)
                        .bodyMedium
                        .override(color: Colors.white, letterSpacing: 0.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                const SizedBox(height: 10.0),
                FFButtonWidget(
                  onPressed: () => context.pushNamedAuth(
                    ForecastUxLabWidget.routeName,
                    context.mounted,
                  ),
                  text: 'Open Forecast UX Lab',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 44.0,
                    color: const Color(0xFF2E7D32),
                    textStyle: FlutterFlowTheme.of(context)
                        .bodyMedium
                        .override(color: Colors.white, letterSpacing: 0.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                if (currentUserUid.isEmpty) ...[
                  const SizedBox(height: 12.0),
                  FFButtonWidget(
                    onPressed: () => context.goNamedAuth(
                      Auth2Widget.routeName,
                      context.mounted,
                    ),
                    text: 'Sign in to bind plan to auth user',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 44.0,
                      color: const Color(0xFF8D6E63),
                      textStyle: FlutterFlowTheme.of(context)
                          .bodyMedium
                          .override(color: Colors.white, letterSpacing: 0.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
