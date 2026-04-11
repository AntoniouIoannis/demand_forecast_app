import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_model.dart';
export 'dashboard_model.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  static String routeName = 'Dashboard';
  static String routePath = 'dashboard';

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  late DashboardModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DashboardModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget _buildGuideStep(BuildContext context, String text, IconData icon) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: theme.primaryText,
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTile({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isLarge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.4),
              blurRadius: 10.0,
              offset: const Offset(0.0, 4.0),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: isLarge ? 52.0 : 32.0,
            ),
            const SizedBox(height: 12.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.interTight(
                  color: Colors.white,
                  fontSize: isLarge ? 20.0 : 14.0,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 800.0;

    // Grid configuration
    final double horizontalPadding = isDesktop ? 40.0 : 16.0;
    final double gridGap = 14.0;
    final double availableWidth = screenWidth - horizontalPadding * 2 - gridGap;
    final double tileSize = (availableWidth / 2).clamp(140.0, 280.0);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          backgroundColor: theme.primary,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 28.0),
            onPressed: () => context.safePop(),
          ),
          title: Text(
            'Dashboard',
            style: GoogleFonts.interTight(
              color: Colors.white,
              fontSize: 22.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'profile') {
                  context.pushNamed(UserProfileWidget.routeName);
                } else if (value == 'signout') {
                  await authManager.signOut();
                  if (mounted) context.goNamed(Auth2Widget.routeName);
                }
              },
              offset: const Offset(0, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: CircleAvatar(
                radius: 18.0,
                // ignore: deprecated_member_use
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.person_rounded,
                    color: Colors.white, size: 22.0),
              ),
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: const [
                      Icon(Icons.manage_accounts_outlined),
                      SizedBox(width: 10),
                      Text('Profile'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'signout',
                  child: Row(
                    children: const [
                      Icon(Icons.logout_rounded, color: Colors.redAccent),
                      SizedBox(width: 10),
                      Text('Sign Out',
                          style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8.0),
          ],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720.0),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome to your Dashboard',
                                  style: GoogleFonts.interTight(
                                    color: theme.primaryText,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6.0),
                                Text(
                                  'Choose a section to get started',
                                  style: GoogleFonts.inter(
                                    color: theme.secondaryText,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20.0),
                          FFButtonWidget(
                            onPressed: () async {
                              context.pushNamed(Auth2Widget.routeName);
                            },
                            text: 'Sign Up / Log In',
                            options: FFButtonOptions(
                              height: 70.0,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: theme.secondary,
                              textStyle: theme.headlineMedium.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: theme.headlineMedium.fontWeight,
                                  fontStyle: theme.headlineMedium.fontStyle,
                                ),
                                color: theme.alternate,
                                letterSpacing: 0.0,
                                fontWeight: theme.headlineMedium.fontWeight,
                                fontStyle: theme.headlineMedium.fontStyle,
                              ),
                              elevation: 0.0,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(40.0),
                                bottomRight: Radius.circular(0.0),
                                topLeft: Radius.circular(0.0),
                                topRight: Radius.circular(40.0),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to your Dashboard',
                            style: GoogleFonts.interTight(
                              color: theme.primaryText,
                              fontSize: 22.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          Text(
                            'Choose a section to get started',
                            style: GoogleFonts.inter(
                              color: theme.secondaryText,
                              fontSize: 14.0,
                            ),
                          ),
                          const SizedBox(height: 14.0),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FFButtonWidget(
                              onPressed: () async {
                                context.pushNamed(Auth2Widget.routeName);
                              },
                              text: 'Sign Up / Log In',
                              options: FFButtonOptions(
                                height: 70.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                color: theme.secondary,
                                textStyle: theme.headlineMedium.override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: theme.headlineMedium.fontWeight,
                                    fontStyle: theme.headlineMedium.fontStyle,
                                  ),
                                  color: theme.alternate,
                                  letterSpacing: 0.0,
                                  fontWeight: theme.headlineMedium.fontWeight,
                                  fontStyle: theme.headlineMedium.fontStyle,
                                ),
                                elevation: 0.0,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(40.0),
                                  bottomRight: Radius.circular(0.0),
                                  topLeft: Radius.circular(0.0),
                                  topRight: Radius.circular(40.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20.0),
                    // Quick Start Guide setup
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.accent1,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: theme.primary,
                          width: 2.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Start Guide',
                              style: GoogleFonts.interTight(
                                color: theme.primaryText,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            _buildGuideStep(
                              context,
                              '1. Upload your historical sales data (CSV, Excel, JSON).',
                              Icons.upload_file_rounded,
                            ),
                            _buildGuideStep(
                              context,
                              '2. We\'ll automatically validate and process your data.',
                              Icons.verified_user_rounded,
                            ),
                            _buildGuideStep(
                              context,
                              '3. Select your horizon and generate your ML forecast.',
                              Icons.online_prediction_rounded,
                            ),
                            _buildGuideStep(
                              context,
                              '4. Download your results as a CSV.',
                              Icons.download_rounded,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    // Main layout: Large "Forecast" on left, grid of 4 tiles on right (desktop) / stacked (mobile)
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left: Large "Forecast your products" button
                          SizedBox(
                            width: tileSize,
                            height: tileSize,
                            child: _buildDashboardTile(
                              label: 'Forecast your products',
                              icon: Icons.auto_graph_rounded,
                              color: const Color(0xFF6A1B9A),
                              isLarge: true,
                              onTap: () async {
                                context.pushNamed(ImportDataWidget.routeName);
                              },
                            ),
                          ),
                          SizedBox(width: gridGap * 2),
                          // Right: 2×2 grid of tiles
                          Expanded(
                            child: Column(
                              children: [
                                // Top row
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: tileSize * 0.4,
                                        child: _buildDashboardTile(
                                          label: 'Markets',
                                          icon: Icons
                                              .store_mall_directory_rounded,
                                          color: const Color(0xFF1565C0),
                                          onTap: () => context.pushNamed(
                                              CalendarWidget.routeName),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: gridGap),
                                    Expanded(
                                      child: SizedBox(
                                        height: tileSize * 0.4,
                                        child: _buildDashboardTile(
                                          label: 'Stock Exchange',
                                          icon: Icons.candlestick_chart_rounded,
                                          color: const Color(0xFF00695C),
                                          onTap: () {
                                            FFAppState().update(() {
                                              FFAppState().exchangesInitialTab =
                                                  1;
                                            });
                                            context.pushNamed(
                                                ExchangesWidget.routeName);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: gridGap),
                                // Bottom row
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: tileSize * 0.4,
                                        child: _buildDashboardTile(
                                          label: 'Seasonal Calendar',
                                          icon: Icons.calendar_month_rounded,
                                          color: const Color(0xFFAD1457),
                                          onTap: () => context.pushNamed(
                                              CalendarWidget.routeName),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: gridGap),
                                    Expanded(
                                      child: SizedBox(
                                        height: tileSize * 0.4,
                                        child: _buildDashboardTile(
                                          label: 'Currency Exchange Rates',
                                          icon: Icons.currency_exchange_rounded,
                                          color: const Color(0xFFF57F17),
                                          onTap: () {
                                            FFAppState().update(() {
                                              FFAppState().exchangesInitialTab =
                                                  0;
                                            });
                                            context.pushNamed(
                                                ExchangesWidget.routeName);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          // Mobile: Stacked layout
                          SizedBox(
                            width: double.infinity,
                            height: tileSize,
                            child: _buildDashboardTile(
                              label: 'Forecast your products',
                              icon: Icons.auto_graph_rounded,
                              color: const Color(0xFF6A1B9A),
                              isLarge: true,
                              onTap: () async {
                                context.pushNamed(ImportDataWidget.routeName);
                              },
                            ),
                          ),
                          SizedBox(height: gridGap),
                          Row(
                            children: [
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: _buildDashboardTile(
                                    label: 'Markets',
                                    icon: Icons.store_mall_directory_rounded,
                                    color: const Color(0xFF1565C0),
                                    onTap: () => context
                                        .pushNamed(CalendarWidget.routeName),
                                  ),
                                ),
                              ),
                              SizedBox(width: gridGap),
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: _buildDashboardTile(
                                    label: 'Stock Exchange',
                                    icon: Icons.candlestick_chart_rounded,
                                    color: const Color(0xFF00695C),
                                    onTap: () {
                                      FFAppState().update(() {
                                        FFAppState().exchangesInitialTab = 1;
                                      });
                                      context
                                          .pushNamed(ExchangesWidget.routeName);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: gridGap),
                          Row(
                            children: [
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: _buildDashboardTile(
                                    label: 'Seasonal Calendar',
                                    icon: Icons.calendar_month_rounded,
                                    color: const Color(0xFFAD1457),
                                    onTap: () => context
                                        .pushNamed(CalendarWidget.routeName),
                                  ),
                                ),
                              ),
                              SizedBox(width: gridGap),
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: _buildDashboardTile(
                                    label: 'Currency Exchange Rates',
                                    icon: Icons.currency_exchange_rounded,
                                    color: const Color(0xFFF57F17),
                                    onTap: () {
                                      FFAppState().update(() {
                                        FFAppState().exchangesInitialTab = 0;
                                      });
                                      context
                                          .pushNamed(ExchangesWidget.routeName);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                    const SizedBox(height: 32.0),

                    // New feature section: App Info, Team, Security
                    Text(
                      'More Info',
                      style: GoogleFonts.interTight(
                        color: theme.primaryText,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    if (isDesktop)
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: tileSize * 0.4,
                                  child: _buildDashboardTile(
                                    label: 'About App\n(Under the hood!)',
                                    icon: Icons.info_rounded,
                                    color: const Color(0xFF5D4037),
                                    onTap: () {
                                      FFAppState().update(() {
                                        FFAppState().aboutAppInitialTab = 0;
                                      });
                                      context
                                          .pushNamed(AboutAppWidget.routeName);
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: gridGap),
                              Expanded(
                                child: SizedBox(
                                  height: tileSize * 0.4,
                                  child: _buildDashboardTile(
                                    label: 'Team\n(Your Coders!)',
                                    icon: Icons.groups_rounded,
                                    color: const Color(0xFF546E7A),
                                    onTap: () {
                                      FFAppState().update(() {
                                        FFAppState().aboutAppInitialTab = 1;
                                      });
                                      context
                                          .pushNamed(AboutAppWidget.routeName);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: gridGap),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: tileSize * 0.4,
                                  child: _buildDashboardTile(
                                    label:
                                        'Secure your info\n(Kerveros protect you!)',
                                    icon: Icons.security_rounded,
                                    color: const Color(0xFF455A64),
                                    onTap: () {
                                      FFAppState().update(() {
                                        FFAppState().aboutAppInitialTab = 2;
                                      });
                                      context
                                          .pushNamed(AboutAppWidget.routeName);
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: gridGap),
                              Expanded(
                                child: SizedBox(
                                  height: tileSize * 0.4,
                                  child: _buildDashboardTile(
                                    label:
                                        'App Engine\n(A naturally aspirated V12 engine of App!)',
                                    icon: Icons.token_rounded,
                                    color: const Color(0xFF6D4C41),
                                    onTap: () {
                                      FFAppState().update(() {
                                        FFAppState().aboutAppInitialTab = 3;
                                      });
                                      context
                                          .pushNamed(AboutAppWidget.routeName);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: _buildDashboardTile(
                                    label: 'About App\n(Under the hood!)',
                                    icon: Icons.info_rounded,
                                    color: const Color(0xFF5D4037),
                                    onTap: () {
                                      FFAppState().update(() {
                                        FFAppState().aboutAppInitialTab = 0;
                                      });
                                      context
                                          .pushNamed(AboutAppWidget.routeName);
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: gridGap),
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: _buildDashboardTile(
                                    label: 'Team\n(Your Coders!)',
                                    icon: Icons.groups_rounded,
                                    color: const Color(0xFF546E7A),
                                    onTap: () {
                                      FFAppState().update(() {
                                        FFAppState().aboutAppInitialTab = 1;
                                      });
                                      context
                                          .pushNamed(AboutAppWidget.routeName);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: gridGap),
                          Row(
                            children: [
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: _buildDashboardTile(
                                    label:
                                        'Secure your info\n(Kerveros protect you!)',
                                    icon: Icons.security_rounded,
                                    color: const Color(0xFF455A64),
                                    onTap: () {
                                      FFAppState().update(() {
                                        FFAppState().aboutAppInitialTab = 2;
                                      });
                                      context
                                          .pushNamed(AboutAppWidget.routeName);
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: gridGap),
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: _buildDashboardTile(
                                    label:
                                        'App Engine\n(A naturally aspirated V12 engine of App!)',
                                    icon: Icons.token_rounded,
                                    color: const Color(0xFF6D4C41),
                                    onTap: () {
                                      FFAppState().update(() {
                                        FFAppState().aboutAppInitialTab = 3;
                                      });
                                      context
                                          .pushNamed(AboutAppWidget.routeName);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                    const SizedBox(height: 32.0),
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
