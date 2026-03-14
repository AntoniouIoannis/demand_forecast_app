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
}
