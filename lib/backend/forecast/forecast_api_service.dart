import 'dart:convert';

import 'package:http/http.dart' as http;

import 'forecast_models.dart';

class ForecastApiException implements Exception {
  ForecastApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ForecastApiService {
  ForecastApiService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<List<ForecastRecord>> runForecast({
    required List<ForecastInputFile> files,
  }) async {
    final uri = Uri.parse(baseUrl).replace(path: '/forecast');
    final request = http.MultipartRequest('POST', uri);

    for (final file in files) {
      request.files.add(
        http.MultipartFile.fromBytes(
          file.fieldName,
          file.bytes,
          filename: file.fileName,
        ),
      );
    }

    final streamedResponse = await _client.send(request);
    final body = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode < 200 ||
        streamedResponse.statusCode >= 300) {
      throw ForecastApiException(
        _extractErrorMessage(body) ??
            'API request failed (HTTP ${streamedResponse.statusCode}).',
      );
    }

    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw ForecastApiException('Invalid API response format.');
    }

    final results = decoded['results'];
    if (results is! List) {
      throw ForecastApiException(
          'No forecast results were returned by the API.');
    }

    return results
        .whereType<Map>()
        .map((item) => ForecastRecord.fromMap(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  String? _extractErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return (decoded['message'] ?? decoded['error'])?.toString();
      }
    } catch (_) {}
    return null;
  }
}
