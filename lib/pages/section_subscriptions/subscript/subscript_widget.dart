import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
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

  Widget _buildSquareTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.14) : Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: selected ? color : const Color(0xFFD6DEEA),
            width: selected ? 2.0 : 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: color.withValues(alpha: 0.28),
                    blurRadius: 8.0,
                    offset: const Offset(0.0, 3.0),
                  ),
                ]
              : const [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28.0),
            const SizedBox(height: 10.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).titleSmall.override(
                    font: GoogleFonts.interTight(
                      fontWeight:
                          FlutterFlowTheme.of(context).titleSmall.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).titleSmall.fontStyle,
                    ),
                    letterSpacing: 0.0,
                  ),
            ),
            const SizedBox(height: 6.0),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: FlutterFlowTheme.of(context).bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = FFAppState();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final tileGap = screenWidth >= 700.0 ? 14.0 : 10.0;
    final availableWidth = screenWidth - 32.0 - tileGap;
    final tileSide = (availableWidth / 2.0).clamp(140.0, 280.0).toDouble();
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720.0),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: tileSide,
                          height: tileSide,
                          child: _buildSquareTile(
                            title: 'Freemium',
                            subtitle: 'EUR 0 / month',
                            icon: Icons.rocket_launch_rounded,
                            color: const Color(0xFF1565C0),
                            selected: appState.subscriptionPlan == 'Freemium',
                            onTap: () => _applyPlan('Freemium'),
                          ),
                        ),
                        SizedBox(width: tileGap),
                        SizedBox(
                          width: tileSide,
                          height: tileSide,
                          child: _buildSquareTile(
                            title: 'Starter',
                            subtitle: 'EUR 19 / month',
                            icon: Icons.trending_up_rounded,
                            color: const Color(0xFF00897B),
                            selected: appState.subscriptionPlan == 'Starter',
                            onTap: () => _applyPlan('Starter'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: tileGap),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: tileSide,
                          height: tileSide,
                          child: _buildSquareTile(
                            title: 'Pro',
                            subtitle: 'EUR 59 / month',
                            icon: Icons.workspace_premium_rounded,
                            color: const Color(0xFF7B1FA2),
                            selected: appState.subscriptionPlan == 'Pro',
                            onTap: () => _applyPlan('Pro'),
                          ),
                        ),
                        SizedBox(width: tileGap),
                        SizedBox(
                          width: tileSide,
                          height: tileSide,
                          child: _buildSquareTile(
                            title: 'Consulting',
                            subtitle: 'Custom pricing',
                            icon: Icons.handshake_rounded,
                            color: const Color(0xFFF57C00),
                            selected: appState.subscriptionPlan == 'Consulting',
                            onTap: () => _applyPlan('Consulting'),
                          ),
                        ),
                      ],
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
                    Text(
                      'Quick Actions',
                      style: FlutterFlowTheme.of(context).titleMedium,
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: tileSide,
                          height: tileSide,
                          child: _buildSquareTile(
                            title: 'Open Plan',
                            subtitle: 'Comparison page',
                            icon: Icons.view_list_rounded,
                            color: const Color(0xFF3949AB),
                            onTap: () =>
                                context.pushNamed(Sub2Widget.routeName),
                          ),
                        ),
                        SizedBox(width: tileGap),
                        SizedBox(
                          width: tileSide,
                          height: tileSide,
                          child: _buildSquareTile(
                            title: 'Open Token Wallet',
                            subtitle: 'See your token balance',
                            icon: Icons.account_balance_wallet_rounded,
                            color: const Color(0xFF00838F),
                            onTap: () =>
                                context.pushNamed(TokenWalletWidget.routeName),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: tileGap),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: tileSide,
                          height: tileSide,
                          child: _buildSquareTile(
                            title: 'Open Forecast UX Lab',
                            subtitle: 'Prototype journey',
                            icon: Icons.science_rounded,
                            color: const Color(0xFF2E7D32),
                            onTap: () => context
                                .pushNamed(ForecastUxLabWidget.routeName),
                          ),
                        ),
                        SizedBox(width: tileGap),
                        SizedBox(
                          width: tileSide,
                          height: tileSide,
                          child: _buildSquareTile(
                            title: 'Sign in to bind plan',
                            subtitle: 'Open auth page',
                            icon: Icons.login_rounded,
                            color: const Color(0xFF8D6E63),
                            onTap: () =>
                                context.pushNamed(Auth2Widget.routeName),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
