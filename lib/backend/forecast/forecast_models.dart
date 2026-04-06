class ForecastRecord {
  const ForecastRecord({
    required this.productId,
    required this.monthYear,
    required this.forecastQty,
  });

  final String productId;
  final String monthYear;
  final double forecastQty;

  factory ForecastRecord.fromMap(Map<String, dynamic> map) {
    return ForecastRecord(
      productId: (map['product_id'] ?? map['productId'] ?? '').toString(),
      monthYear: (map['month_year'] ?? map['monthYear'] ?? '').toString(),
      forecastQty: double.tryParse(
            (map['forecast_qty'] ?? map['forecastQty'] ?? 0).toString(),
          ) ??
          0,
    );
  }

  Map<String, dynamic> toMap() => {
        'product_id': productId,
        'month_year': monthYear,
        'forecast_qty': forecastQty,
      };
}

class ForecastInputFile {
  const ForecastInputFile({
    required this.fieldName,
    required this.fileName,
    required this.bytes,
  });

  final String fieldName;
  final String fileName;
  final List<int> bytes;
}
