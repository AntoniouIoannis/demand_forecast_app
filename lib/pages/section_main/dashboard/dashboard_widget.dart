import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  static const List<String> _businessMarkets = <String>[
    'Retail',
    'Food & Beverage',
    'Pharmacy',
    'Electronics',
    'Fashion',
    'Automotive',
    'Hospitality',
    'Other',
  ];
  static const List<String> _marketCountries = <String>[
    'Greece',
    'Cyprus',
    'Italy',
    'Germany',
    'France',
    'Spain',
    'United Kingdom',
    'United States',
  ];
  static const List<int> _forecastHorizons = <int>[30, 90, 365];

  String? _selectedMarket;
  String? _selectedCountry;
  int? _selectedForecastHorizonDays;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DashboardModel());
    _selectedMarket = FFAppState().selectedBusinessMarket;
    _selectedCountry = FFAppState().selectedMarketCountry;
    _selectedForecastHorizonDays = FFAppState().forecastHorizonDays;
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

  void _onProfileSelectionChanged() {
    FFAppState().update(() {
      FFAppState().selectedBusinessMarket = _selectedMarket;
      FFAppState().selectedMarketCountry = _selectedCountry;
      FFAppState().forecastHorizonDays = _selectedForecastHorizonDays;
    });
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('onhold_users')
          .doc(uid)
          .set(<String, dynamic>{
        'market': _selectedMarket,
        'marketCountry': _selectedCountry,
        'forecastHorizonDays': _selectedForecastHorizonDays,
        'lastSeenAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Widget _buildSelectionCriteriaPanel() {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: theme.alternate),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8.0,
            offset: Offset(0.0, 2.0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, color: theme.primary, size: 20.0),
              const SizedBox(width: 8.0),
              Text(
                'Business Context',
                style: GoogleFonts.interTight(
                  color: theme.primaryText,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Text(
            'Business Market',
            style: GoogleFonts.inter(
              color: theme.secondaryText,
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6.0),
          DropdownButtonFormField<String>(
            initialValue: _selectedMarket,
            items: _businessMarkets
                .map((m) => DropdownMenuItem<String>(value: m, child: Text(m)))
                .toList(),
            onChanged: (val) {
              setState(() => _selectedMarket = val);
              _onProfileSelectionChanged();
            },
            decoration: InputDecoration(
              hintText: 'Choose market',
              filled: true,
              fillColor: theme.primaryBackground,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 14.0),
          Text(
            'Market Country',
            style: GoogleFonts.inter(
              color: theme.secondaryText,
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6.0),
          DropdownButtonFormField<String>(
            initialValue: _selectedCountry,
            items: _marketCountries
                .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                .toList(),
            onChanged: (val) {
              setState(() => _selectedCountry = val);
              _onProfileSelectionChanged();
            },
            decoration: InputDecoration(
              hintText: 'Choose country',
              filled: true,
              fillColor: theme.primaryBackground,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 14.0),
          Text(
            'Forecast Horizon',
            style: GoogleFonts.inter(
              color: theme.secondaryText,
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6.0),
          DropdownButtonFormField<int>(
            initialValue: _selectedForecastHorizonDays,
            items: _forecastHorizons
                .map((d) =>
                    DropdownMenuItem<int>(value: d, child: Text('$d days')))
                .toList(),
            onChanged: (val) {
              setState(() => _selectedForecastHorizonDays = val);
              _onProfileSelectionChanged();
            },
            decoration: InputDecoration(
              hintText: 'Select horizon',
              filled: true,
              fillColor: theme.primaryBackground,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ],
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
                    const SizedBox(height: 20.0),
                    _buildSelectionCriteriaPanel(),
                    const SizedBox(height: 24.0),

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
                                context.pushNamed(HomePageWidget.routeName);
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
                                          onTap: () {},
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
                                          onTap: () {},
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
                                          onTap: () {},
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
                                context.pushNamed(HomePageWidget.routeName);
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
                                    onTap: () {},
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

                    _buildHorizontalTile(
                      label: 'About App (under the hood!!)',
                      icon: Icons.info_rounded,
                      color: const Color(0xFF7B1FA2),
                      onTap: () {},
                    ),
                    SizedBox(height: gridGap),
                    _buildHorizontalTile(
                      label: 'Team (Your coders)',
                      icon: Icons.groups_rounded,
                      color: const Color(0xFF0288D1),
                      onTap: () {},
                    ),
                    SizedBox(height: gridGap),
                    _buildHorizontalTile(
                      label:
                          'Secure your info (kerveros protect your business privacy)',
                      icon: Icons.security_rounded,
                      color: const Color(0xFFD32F2F),
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
