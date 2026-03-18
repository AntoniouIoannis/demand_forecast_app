import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
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

  Widget _buildHorizontalTile({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72.0,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14.0),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.4),
              blurRadius: 8.0,
              offset: const Offset(0.0, 3.0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 26.0,
            ),
            const SizedBox(width: 14.0),
            Text(
              label,
              style: GoogleFonts.interTight(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
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
    final double availableWidth =
        screenWidth - horizontalPadding * 2 - gridGap;
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
                    const SizedBox(height: 24.0),

                    // Large square "Forecast your products" button
                    SizedBox(
                      width: double.infinity,
                      height: tileSize,
                      child: _buildDashboardTile(
                        label: 'Forecast your products',
                        icon: Icons.auto_graph_rounded,
                        color: const Color(0xFF6A1B9A),
                        isLarge: true,
                        onTap: () async {
                          context.pushNamed(HomePageWidget.routeName);
                        },
                      ),
                    ),

                    SizedBox(height: gridGap),

                    // 2×2 grid of square tiles
                    if (isDesktop)
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: tileSize * 0.75,
                              child: _buildDashboardTile(
                                label: 'Markets',
                                icon: Icons.store_mall_directory_rounded,
                                color: const Color(0xFF1565C0),
                                onTap: () {},
                              ),
                            ),
                          ),
                          SizedBox(width: gridGap),
                          Expanded(
                            child: SizedBox(
                              height: tileSize * 0.75,
                              child: _buildDashboardTile(
                                label: 'Stock Exchange',
                                icon: Icons.candlestick_chart_rounded,
                                color: const Color(0xFF00695C),
                                onTap: () {},
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: _buildDashboardTile(
                                label: 'Markets',
                                icon: Icons.store_mall_directory_rounded,
                                color: const Color(0xFF1565C0),
                                onTap: () {},
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
                                onTap: () {},
                              ),
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: gridGap),

                    // Horizontal tiles
                    _buildHorizontalTile(
                      label: 'Seasonal Calendar',
                      icon: Icons.calendar_month_rounded,
                      color: const Color(0xFFAD1457),
                      onTap: () {},
                    ),
                    SizedBox(height: gridGap),
                    _buildHorizontalTile(
                      label: 'Currency Exchange Rates',
                      icon: Icons.currency_exchange_rounded,
                      color: const Color(0xFFF57F17),
                      onTap: () {},
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
