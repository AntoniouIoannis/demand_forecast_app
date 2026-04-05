import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'exchanges_model.dart';
export 'exchanges_model.dart';

class ExchangesWidget extends StatefulWidget {
  const ExchangesWidget({super.key});

  static String routeName = 'Exchanges';
  static String routePath = 'exchanges';

  @override
  State<ExchangesWidget> createState() => _ExchangesWidgetState();
}

class _ExchangesWidgetState extends State<ExchangesWidget>
    with TickerProviderStateMixin {
  late ExchangesModel _model;
  late TabController _tabController;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const String _alphaVantageApiKey = '5YC1Z24GTQ08CAH6';

  static const Map<String, String> _currencySymbols = <String, String>{
    'EUR': '€',
    'USD': r'$',
    'GBP': '£',
    'JPY': '¥',
    'CHF': 'CHF',
    'CAD': r'C$',
    'AUD': r'A$',
    'CNY': '¥',
    'SEK': 'kr',
    'NOK': 'kr',
    'DKK': 'kr',
    'PLN': 'zł',
    'TRY': '₺',
    'INR': '₹',
    'BRL': r'R$',
    'MXN': r'MX$',
    'ZAR': 'R',
    'NZD': r'NZ$',
    'SGD': r'S$',
    'HKD': r'HK$',
  };

  static const List<String> _defaultCurrencies = <String>[
    'EUR',
    'USD',
    'GBP',
    'JPY',
    'CHF',
    'CAD',
    'AUD',
    'CNY',
    'SEK',
    'NOK',
    'DKK',
    'PLN',
    'TRY',
    'INR',
    'BRL',
    'MXN',
    'ZAR',
    'NZD',
    'SGD',
    'HKD',
  ];

  static const List<String> _stockSymbols = <String>[
    'IBM',
    'AAPL',
    'MSFT',
    'GOOGL',
    'AMZN',
    'TSLA',
    'NVDA',
  ];

  static const Map<String, String> _stockCompanyNames = <String, String>{
    'IBM': 'IBM Corp.',
    'AAPL': 'Apple Inc.',
    'MSFT': 'Microsoft Corp.',
    'GOOGL': 'Alphabet (Google)',
    'AMZN': 'Amazon.com Inc.',
    'TSLA': 'Tesla Inc.',
    'NVDA': 'NVIDIA Corp.',
  };

  String _baseCurrency = 'EUR';
  String _currencyDate = '';
  bool _isCurrencyLoading = false;
  String? _currencyError;
  final Map<String, double> _currencyRates = <String, double>{};
  Map<String, String> _currencyNames = <String, String>{};

  String _stockSymbol = 'IBM';
  bool _isStockLoading = false;
  String? _stockError;
  final Map<String, String> _stockFields = <String, String>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ExchangesModel());

    final initialIndex = FFAppState().exchangesInitialTab.clamp(0, 1);
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialIndex,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      FFAppState().update(() {
        FFAppState().exchangesInitialTab = 0;
      });
      await _loadCurrencies();
      await _fetchCurrencyRates();
      await _fetchStockData();
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _model.dispose();
    super.dispose();
  }

  String _currencySymbol(String code) => _currencySymbols[code] ?? code;

  String _currencyName(String code) => _currencyNames[code] ?? code;

  String _formatStockFieldLabel(String rawKey) {
    final keyNoPrefix = rawKey.replaceFirst(RegExp(r'^\d+\.\s*'), '');
    final words =
        keyNoPrefix.split(RegExp(r'[_\s]+')).where((w) => w.isNotEmpty);
    return words
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  Future<void> _loadCurrencies() async {
    try {
      final uri = Uri.parse('https://api.frankfurter.dev/v1/currencies');
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        return;
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (!mounted) {
        return;
      }
      setState(() {
        _currencyNames = decoded.map(
          (key, value) => MapEntry(key, value.toString()),
        );
      });
    } catch (_) {
      // Keep fallback labels when the metadata request fails.
    }
  }

  Future<void> _fetchCurrencyRates() async {
    setState(() {
      _isCurrencyLoading = true;
      _currencyError = null;
      _currencyRates.clear();
    });

    try {
      final uri = Uri.parse(
          'https://api.frankfurter.dev/v1/latest?base=${Uri.encodeQueryComponent(_baseCurrency)}');
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Currency API returned ${response.statusCode}.');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final rates =
          (decoded['rates'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final parsedRates = <String, double>{};
      for (final entry in rates.entries) {
        final value = entry.value;
        if (value is num) {
          parsedRates[entry.key] = value.toDouble();
        }
      }
      final sortedEntries = parsedRates.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      if (!mounted) {
        return;
      }
      setState(() {
        _currencyDate = decoded['date']?.toString() ??
            dateTimeFormat('y-MM-dd', DateTime.now());
        _currencyRates
          ..clear()
          ..addEntries(sortedEntries);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _currencyError = 'Unable to load live currency rates right now.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCurrencyLoading = false;
        });
      }
    }
  }

  Future<void> _fetchStockData() async {
    setState(() {
      _isStockLoading = true;
      _stockError = null;
      _stockFields.clear();
    });

    try {
      final uri = Uri.parse(
          'https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=${Uri.encodeQueryComponent(_stockSymbol)}&apikey=$_alphaVantageApiKey');
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Stock API returned ${response.statusCode}.');
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final raw = (decoded['Global Quote'] as Map<String, dynamic>?) ??
          <String, dynamic>{};
      if (raw.isEmpty) {
        throw Exception('No stock data available now.');
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _stockFields
          ..clear()
          ..addEntries(raw.entries.map(
            (e) => MapEntry(e.key, e.value.toString()),
          ));
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _stockError = 'Unable to load live stock data right now.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isStockLoading = false;
        });
      }
    }
  }

  Widget _buildCurrencyTab() {
    final theme = FlutterFlowTheme.of(context);
    final todayLabel = _currencyDate.isEmpty
        ? dateTimeFormat('y-MM-dd', DateTime.now())
        : _currencyDate;
    final baseCurrencyLabel =
        '${_currencyName(_baseCurrency)} (${_baseCurrency}) ${_currencySymbol(_baseCurrency)}';

    final currencyCodes = _currencyNames.isEmpty
        ? _defaultCurrencies
        : _currencyNames.keys.toList()
      ..sort();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F2FF),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: const Color(0xFFB9D4FF)),
            ),
            child: Text(
              'Currency rates are LIVE from Frankfurter API and refreshed on demand.',
              style: theme.bodyMedium,
            ),
          ),
          const SizedBox(height: 14.0),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _baseCurrency,
                  decoration: InputDecoration(
                    labelText: 'Base Currency',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  items: currencyCodes
                      .map(
                        (code) => DropdownMenuItem<String>(
                          value: code,
                          child: Text(
                            '${_currencyName(code)}  $code  ${_currencySymbol(code)}',
                            style: theme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) async {
                    if (value == null || value == _baseCurrency) {
                      return;
                    }
                    setState(() {
                      _baseCurrency = value;
                    });
                    await _fetchCurrencyRates();
                  },
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Container(
                  height: 58.0,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: const Color(0xFFD6DEEA)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_clock_rounded,
                          color: theme.secondaryText, size: 18.0),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          'Date: $todayLabel',
                          style: theme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              IconButton(
                onPressed: _isCurrencyLoading ? null : _fetchCurrencyRates,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh live rates',
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            'Base selected: $baseCurrencyLabel',
            style: theme.bodyMedium.override(
              font: GoogleFonts.interTight(
                fontWeight: FontWeight.w700,
                fontStyle: theme.bodyMedium.fontStyle,
              ),
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 12.0),
          if (_isCurrencyLoading)
            const Center(child: CircularProgressIndicator())
          else if (_currencyError != null)
            Text(
              _currencyError!,
              style: theme.bodyMedium.override(
                color: theme.error,
                letterSpacing: 0.0,
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                const int cols = 5;
                const double spacing = 6.0;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _currencyRates.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    mainAxisExtent: 68.0,
                  ),
                  itemBuilder: (context, index) {
                    final entry = _currencyRates.entries.elementAt(index);
                    final code = entry.key;
                    final value = entry.value;
                    final name = _currencyName(code);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: const Color(0xFFDCE4F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: theme.labelSmall.override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    letterSpacing: 0.0,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                value.toStringAsFixed(4),
                                style: theme.labelSmall.override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$code  ${_currencySymbol(code)}',
                                style: theme.labelSmall.override(
                                  color: theme.secondaryText,
                                  letterSpacing: 0.0,
                                ),
                                maxLines: 1,
                              ),
                              Text(
                                'per $_baseCurrency',
                                style: theme.labelSmall.override(
                                  color: theme.secondaryText,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStockTab() {
    final theme = FlutterFlowTheme.of(context);
    const pastelPalette = <Color>[
      Color(0xFFE3F2FD),
      Color(0xFFE8F5E9),
      Color(0xFFFFF3E0),
      Color(0xFFF3E5F5),
      Color(0xFFE0F2F1),
      Color(0xFFFFEBEE),
      Color(0xFFF1F8E9),
      Color(0xFFE8EAF6),
      Color(0xFFE0F7FA),
      Color(0xFFFFF8E1),
    ];

    final entries = _stockFields.entries.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: const Color(0xFFEAFBF0),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: const Color(0xFFC7EFD2)),
            ),
            child: Text(
              'Stock values are LIVE from Alpha Vantage API and refreshed on demand.',
              style: theme.bodyMedium,
            ),
          ),
          const SizedBox(height: 14.0),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _stockSymbol,
                  decoration: InputDecoration(
                    labelText: 'Stock Symbol',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  items: _stockSymbols
                      .map(
                        (symbol) => DropdownMenuItem<String>(
                          value: symbol,
                          child: Text(
                            '$symbol – ${_stockCompanyNames[symbol] ?? symbol}',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) async {
                    if (value == null || value == _stockSymbol) {
                      return;
                    }
                    setState(() {
                      _stockSymbol = value;
                    });
                    await _fetchStockData();
                  },
                ),
              ),
              const SizedBox(width: 10.0),
              IconButton(
                onPressed: _isStockLoading ? null : _fetchStockData,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh live stock data',
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          if (_isStockLoading)
            const Center(child: CircularProgressIndicator())
          else if (_stockError != null)
            Text(
              _stockError!,
              style: theme.bodyMedium.override(
                color: theme.error,
                letterSpacing: 0.0,
              ),
            )
          else
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: [
                for (int i = 0; i < entries.length; i++)
                  Container(
                    width: 220.0,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: pastelPalette[i % pastelPalette.length],
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: const Color(0xFFD8E4F2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatStockFieldLabel(entries[i].key),
                          style: theme.titleSmall.override(
                            font: GoogleFonts.interTight(
                              fontWeight: FontWeight.w700,
                              fontStyle: theme.titleSmall.fontStyle,
                            ),
                            letterSpacing: 0.0,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          entries[i].value,
                          style: theme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

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
            'Exchanges',
            style: theme.headlineMedium.override(
              font: GoogleFonts.interTight(
                fontWeight: theme.headlineMedium.fontWeight,
                fontStyle: theme.headlineMedium.fontStyle,
              ),
              color: Colors.white,
              letterSpacing: 0.0,
            ),
          ),
          centerTitle: false,
          elevation: 2.0,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFFD5E2FF),
            labelStyle: theme.bodyMedium.override(
              font: GoogleFonts.interTight(
                fontWeight: FontWeight.w600,
                fontStyle: theme.bodyMedium.fontStyle,
              ),
              letterSpacing: 0.0,
            ),
            tabs: const [
              Tab(text: 'Currency Exhange Rate'),
              Tab(text: 'Stock Exchange'),
            ],
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100.0),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCurrencyTab(),
                _buildStockTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
