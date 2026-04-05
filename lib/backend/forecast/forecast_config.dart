class ForecastConfig {
  // Keep the service endpoint updated for future reactivation.
  static const String cloudRunBaseUrl =
      'https://demand-python-314-hc4e65tfbq-uc.a.run.app';

  // Safety switch: when false, UI will not trigger forecasting traffic.
  static const bool forecastingEnabled = false;

  static const String forecastingPausedMessage =
      'Forecast processing is temporarily disabled to prevent Cloud Run charges.';
}
