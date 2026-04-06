import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'calendar_model.dart';
export 'calendar_model.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  static String routeName = 'Calendar';
  static String routePath = 'calendar';

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late CalendarModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  static const String _allCountries = 'All Countries';
  static const String _allMarkets = 'All Markets';

  static const Map<String, String> _countryCodeNames = <String, String>{
    'AF': 'Afghanistan',
    'AE': 'UAE',
    'BE': 'Belgium',
    'BH': 'Bahrain',
    'CN': 'China',
    'DE': 'Germany',
    'EG': 'Egypt',
    'ES': 'Spain',
    'FR': 'France',
    'GB': 'United Kingdom',
    'GR': 'Greece',
    'HK': 'Hong Kong',
    'IL': 'Israel',
    'IN': 'India',
    'IR': 'Iran',
    'IT': 'Italy',
    'JP': 'Japan',
    'JO': 'Jordan',
    'KW': 'Kuwait',
    'NL': 'Netherlands',
    'OM': 'Oman',
    'QA': 'Qatar',
    'SA': 'Saudi Arabia',
    'SG': 'Singapore',
    'TH': 'Thailand',
    'US': 'United States',
    'GLOBAL': 'Global',
  };

  String _countryLabel(String code) {
    if (code == _allCountries) return code;
    final name = _countryCodeNames[code];
    return name != null ? '$code – $name' : code;
  }

  String _selectedCountry = _allCountries;
  String _selectedMarket = _allMarkets;

  final List<Map<String, dynamic>> _calendarItems = const [
    {
      'name': 'Gregorian',
      'regions': 'Global / West / Greece',
      'notes': 'Standard civil calendar used globally.',
      'countries': ['GR', 'US', 'GB', 'DE', 'FR', 'IT', 'ES', 'GLOBAL'],
      'markets': ['Retail', 'E-commerce', 'FMCG', 'B2B', 'Hospitality'],
    },
    {
      'name': 'Islamic (Hijri)',
      'regions': 'Egypt / Middle East',
      'notes': 'Key for Ramadan, Eid, and related demand seasonality.',
      'countries': ['EG', 'SA', 'AE', 'QA', 'KW', 'OM', 'BH', 'JO'],
      'markets': ['Retail', 'FMCG', 'Hospitality', 'Pharma'],
    },
    {
      'name': 'Hindu calendar',
      'regions': 'India',
      'notes': 'Important for Diwali and major local festivals.',
      'countries': ['IN'],
      'markets': ['Retail', 'FMCG', 'E-commerce'],
    },
    {
      'name': 'Chinese lunar',
      'regions': 'China',
      'notes': 'Critical around Lunar New Year and Golden Week periods.',
      'countries': ['CN', 'HK', 'SG'],
      'markets': ['Retail', 'E-commerce', 'Manufacturing'],
    },
    {
      'name': 'Fiscal calendars',
      'regions': 'Businesses',
      'notes': 'Supports 4-4-5 and other fiscal planning cycles.',
      'countries': ['GLOBAL'],
      'markets': ['B2B', 'Retail', 'Manufacturing', 'Services'],
    },
    {
      'name': 'Hebrew calendar',
      'regions': 'Israel / Jewish communities',
      'notes': 'Useful for Passover, Rosh Hashanah, and Yom Kippur peaks.',
      'countries': ['IL', 'US', 'GLOBAL'],
      'markets': ['Retail', 'FMCG', 'Hospitality'],
    },
    {
      'name': 'Persian (Solar Hijri)',
      'regions': 'Iran / Afghanistan',
      'notes': 'Essential around Nowruz and local holiday seasons.',
      'countries': ['IR', 'AF'],
      'markets': ['Retail', 'FMCG'],
    },
    {
      'name': 'Thai solar (Buddhist Era)',
      'regions': 'Thailand',
      'notes': 'Commonly used in public-sector and retail date systems.',
      'countries': ['TH'],
      'markets': ['Retail', 'Hospitality'],
    },
    {
      'name': 'Japanese era calendar',
      'regions': 'Japan',
      'notes': 'Used in government forms and some enterprise systems.',
      'countries': ['JP'],
      'markets': ['B2B', 'Retail', 'Manufacturing'],
    },
    {
      'name': 'ISO week calendar',
      'regions': 'Europe / Logistics',
      'notes': 'Important for weekly planning, warehousing, and operations.',
      'countries': ['GR', 'DE', 'FR', 'IT', 'ES', 'NL', 'BE', 'GLOBAL'],
      'markets': ['Logistics', 'B2B', 'Manufacturing', 'Retail'],
    },
    {
      'name': 'Academic calendar',
      'regions': 'Education-driven demand',
      'notes': 'Back-to-school cycles strongly affect specific categories.',
      'countries': ['GLOBAL'],
      'markets': ['Retail', 'Education', 'E-commerce'],
    },
    {
      'name': 'Retail promotion calendar',
      'regions': 'Global commerce',
      'notes': 'Black Friday, Singles Day, and campaign windows.',
      'countries': ['US', 'CN', 'GLOBAL', 'GB', 'GR'],
      'markets': ['Retail', 'E-commerce'],
    },
  ];

  List<String> get _countryOptions {
    final countries = <String>{_allCountries};
    for (final item in _calendarItems) {
      countries.addAll((item['countries'] as List<String>));
    }
    final sorted = countries.where((c) => c != _allCountries).toList()..sort();
    return [_allCountries, ...sorted];
  }

  List<String> get _marketOptions {
    final markets = <String>{_allMarkets};
    for (final item in _calendarItems) {
      markets.addAll((item['markets'] as List<String>));
    }
    final sorted = markets.where((m) => m != _allMarkets).toList()..sort();
    return [_allMarkets, ...sorted];
  }

  List<Map<String, dynamic>> get _filteredCalendars {
    return _calendarItems.where((item) {
      final itemCountries = item['countries'] as List<String>;
      final itemMarkets = item['markets'] as List<String>;

      final countryMatches = _selectedCountry == _allCountries ||
          itemCountries.contains(_selectedCountry) ||
          itemCountries.contains('GLOBAL');
      final marketMatches = _selectedMarket == _allMarkets ||
          itemMarkets.contains(_selectedMarket);

      return countryMatches && marketMatches;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CalendarModel());

    final appState = FFAppState();
    final country = appState.selectedMarketCountry;
    final market = appState.selectedBusinessMarket;

    if (country != null && _countryOptions.contains(country)) {
      _selectedCountry = country;
    }
    if (market != null && _marketOptions.contains(market)) {
      _selectedMarket = market;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCalendars = _filteredCalendars;

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
          automaticallyImplyLeading: false,
          title: Text(
            'Multi-Calendar Support',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calendars to include in demand forecasting seasonal signals:',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        letterSpacing: 0.0,
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                ),
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCountry,
                        decoration: InputDecoration(
                          labelText: 'Country',
                          filled: true,
                          fillColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).alternate,
                            ),
                          ),
                        ),
                        items: _countryOptions
                            .map(
                              (country) => DropdownMenuItem<String>(
                                value: country,
                                child: Text(_countryLabel(country)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedCountry = value;
                          });
                          FFAppState().update(() {
                            FFAppState().selectedMarketCountry =
                                value == _allCountries ? null : value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedMarket,
                        decoration: InputDecoration(
                          labelText: 'Market',
                          filled: true,
                          fillColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).alternate,
                            ),
                          ),
                        ),
                        items: _marketOptions
                            .map(
                              (market) => DropdownMenuItem<String>(
                                value: market,
                                child: Text(market),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedMarket = value;
                          });
                          FFAppState().update(() {
                            FFAppState().selectedBusinessMarket =
                                value == _allMarkets ? null : value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Text(
                  'Showing ${filteredCalendars.length} calendars',
                  style: FlutterFlowTheme.of(context).labelMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FlutterFlowTheme.of(context)
                              .labelMedium
                              .fontWeight,
                          fontStyle: FlutterFlowTheme.of(context)
                              .labelMedium
                              .fontStyle,
                        ),
                        letterSpacing: 0.0,
                        fontWeight:
                            FlutterFlowTheme.of(context).labelMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).labelMedium.fontStyle,
                      ),
                ),
                const SizedBox(height: 10.0),
                Expanded(
                  child: GridView.builder(
                    itemCount: filteredCalendars.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      mainAxisExtent: 200.0,
                    ),
                    itemBuilder: (context, index) {
                      final item = filteredCalendars[index];
                      final countries = (item['countries'] as List<String>)
                          .map((c) => _countryCodeNames[c] != null
                              ? '$c\u00a0${_countryCodeNames[c]}'
                              : c)
                          .join(', ');
                      return Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).alternate,
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 16.0,
                                ),
                                const SizedBox(width: 4.0),
                                Expanded(
                                  child: Text(
                                    item['name'] as String,
                                    style: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.interTight(
                                            fontWeight: FontWeight.w700,
                                          ),
                                          letterSpacing: 0.0,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              item['regions'] as String,
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    color: FlutterFlowTheme.of(context).primary,
                                    letterSpacing: 0.0,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4.0),
                            Expanded(
                              child: Text(
                                item['notes'] as String,
                                style: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .fontWeight,
                                      ),
                                      letterSpacing: 0.0,
                                    ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              countries,
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
