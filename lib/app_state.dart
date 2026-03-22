import 'package:flutter/material.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  bool _emailState = false;
  bool get emailState => _emailState;
  set emailState(bool value) {
    _emailState = value;
  }

  bool _passwordState = false;
  bool get passwordState => _passwordState;
  set passwordState(bool value) {
    _passwordState = value;
  }

  String? _selectedBusinessMarket;
  String? get selectedBusinessMarket => _selectedBusinessMarket;
  set selectedBusinessMarket(String? value) {
    _selectedBusinessMarket = value;
  }

  String? _selectedMarketCountry;
  String? get selectedMarketCountry => _selectedMarketCountry;
  set selectedMarketCountry(String? value) {
    _selectedMarketCountry = value;
  }

  int? _forecastHorizonDays;
  int? get forecastHorizonDays => _forecastHorizonDays;
  set forecastHorizonDays(int? value) {
    _forecastHorizonDays = value;
  }

  String? _forecastReferenceDateIso;
  String? get forecastReferenceDateIso => _forecastReferenceDateIso;
  set forecastReferenceDateIso(String? value) {
    _forecastReferenceDateIso = value;
  }

  String _subscriptionPlan = 'Freemium';
  String get subscriptionPlan => _subscriptionPlan;
  set subscriptionPlan(String value) {
    _subscriptionPlan = value;
  }

  int _monthlyTokenLimit = 300;
  int get monthlyTokenLimit => _monthlyTokenLimit;
  set monthlyTokenLimit(int value) {
    _monthlyTokenLimit = value;
  }

  int _usedTokensThisMonth = 0;
  int get usedTokensThisMonth => _usedTokensThisMonth;
  set usedTokensThisMonth(int value) {
    _usedTokensThisMonth = value;
  }

  int _maxSkusPerRun = 1;
  int get maxSkusPerRun => _maxSkusPerRun;
  set maxSkusPerRun(int value) {
    _maxSkusPerRun = value;
  }

  bool _batchUploadsEnabled = false;
  bool get batchUploadsEnabled => _batchUploadsEnabled;
  set batchUploadsEnabled(bool value) {
    _batchUploadsEnabled = value;
  }

  bool _apiAccessEnabled = false;
  bool get apiAccessEnabled => _apiAccessEnabled;
  set apiAccessEnabled(bool value) {
    _apiAccessEnabled = value;
  }

  bool _customModelsEnabled = false;
  bool get customModelsEnabled => _customModelsEnabled;
  set customModelsEnabled(bool value) {
    _customModelsEnabled = value;
  }

  int _defaultForecastHorizon = 30;
  int get defaultForecastHorizon => _defaultForecastHorizon;
  set defaultForecastHorizon(int value) {
    _defaultForecastHorizon = value;
  }

  String _defaultGranularity = 'Weekly';
  String get defaultGranularity => _defaultGranularity;
  set defaultGranularity(String value) {
    _defaultGranularity = value;
  }

  String _defaultTimezone = 'Europe/Athens';
  String get defaultTimezone => _defaultTimezone;
  set defaultTimezone(String value) {
    _defaultTimezone = value;
  }

  int _aboutAppInitialTab = 0;
  int get aboutAppInitialTab => _aboutAppInitialTab;
  set aboutAppInitialTab(int value) {
    _aboutAppInitialTab = value;
  }

  int _exchangesInitialTab = 0;
  int get exchangesInitialTab => _exchangesInitialTab;
  set exchangesInitialTab(int value) {
    _exchangesInitialTab = value;
  }
}
