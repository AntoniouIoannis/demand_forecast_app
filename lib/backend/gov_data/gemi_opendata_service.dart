import 'dart:convert';

import 'package:http/http.dart' as http;

class GemiOpenDataException implements Exception {
  GemiOpenDataException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _CacheEntry {
  _CacheEntry(this.value, this.createdAt);

  final Map<String, dynamic>? value;
  final DateTime createdAt;
}

class GemiOpenDataService {
  static const String _host = 'opendata-api.businessportal.gr';
  static const String _basePath = '/api/opendata/v1';
  static const Duration _cacheTtl = Duration(minutes: 10);

  static const String _apiKey = String.fromEnvironment(
    'GEMI_OPENDATA_API_KEY',
    defaultValue: '',
  );

  static final Map<String, _CacheEntry> _websiteCache = <String, _CacheEntry>{};

  static Future<Map<String, dynamic>?> lookupCompanyByWebsite(
    String website, {
    String? apiKeyOverride,
  }) async {
    final normalizedWebsite = _normalizeWebsite(website);
    if (normalizedWebsite.isEmpty) return null;

    final cached = _websiteCache[normalizedWebsite];
    if (cached != null &&
        DateTime.now().difference(cached.createdAt) < _cacheTtl) {
      return cached.value;
    }

    final apiKey = (apiKeyOverride ?? _apiKey).trim();
    if (apiKey.isEmpty) {
      throw GemiOpenDataException(
        'Λείπει το GEMI API key. Βάλε --dart-define=GEMI_OPENDATA_API_KEY=<key>.',
      );
    }

    final searchTerm = _searchTermFromWebsite(normalizedWebsite);

    final searchUri = Uri.https(_host, '$_basePath/companies', <String, String>{
      'name': searchTerm,
      'resultsSize': '50',
      'resultsOffset': '0',
      'resultsSortBy': '+arGemi',
    });

    final headers = <String, String>{
      'accept': 'application/json',
      'api_key': apiKey,
    };

    final searchResp = await http.get(searchUri, headers: headers);
    _throwIfFailed(searchResp, endpoint: '/companies');

    final searchPayload = _decodeJsonMap(searchResp.bodyBytes);
    final searchResults = _toMapList(searchPayload['searchResults']);

    if (searchResults.isEmpty) {
      _websiteCache[normalizedWebsite] = _CacheEntry(null, DateTime.now());
      return null;
    }

    final matched =
        _pickBestMatch(searchResults, normalizedWebsite) ?? searchResults.first;

    final arGemi = matched['arGemi']?.toString().trim() ?? '';
    if (arGemi.isEmpty) {
      _websiteCache[normalizedWebsite] = _CacheEntry(null, DateTime.now());
      return null;
    }

    final companyUri = Uri.https(_host, '$_basePath/companies/$arGemi');
    final companyResp = await http.get(companyUri, headers: headers);
    _throwIfFailed(companyResp, endpoint: '/companies/{arGemi}');

    final companyPayload = _decodeJsonMap(companyResp.bodyBytes);

    Map<String, dynamic>? documentsPayload;
    try {
      final docsUri =
          Uri.https(_host, '$_basePath/companies/$arGemi/documents');
      final docsResp = await http.get(docsUri, headers: headers);
      if (docsResp.statusCode >= 200 && docsResp.statusCode < 300) {
        documentsPayload = _decodeJsonMap(docsResp.bodyBytes);
      }
    } catch (_) {
      // Documents are optional for the live card.
    }

    final result = <String, dynamic>{
      'matchedSearchTerm': searchTerm,
      'matchedWebsite': normalizedWebsite,
      'searchHit': matched,
      'company': companyPayload,
      'documents': documentsPayload,
      'fetchedAtUtc': DateTime.now().toUtc().toIso8601String(),
    };

    _websiteCache[normalizedWebsite] = _CacheEntry(result, DateTime.now());
    return result;
  }

  static void _throwIfFailed(
    http.Response response, {
    required String endpoint,
  }) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw GemiOpenDataException(
        'Αποτυχία αυθεντικοποίησης στο ΓΕΜΗ API ($endpoint). Έλεγξε το api_key.',
      );
    }

    throw GemiOpenDataException(
      'Αποτυχία κλήσης ΓΕΜΗ API ($endpoint): HTTP ${response.statusCode}.',
    );
  }

  static String _normalizeWebsite(String website) {
    var value = website.trim().toLowerCase();
    if (value.isEmpty) return '';

    value = value.replaceFirst(RegExp(r'^https?://'), '');
    value = value.replaceFirst(RegExp(r'^www\.'), '');

    final slashIndex = value.indexOf('/');
    if (slashIndex >= 0) {
      value = value.substring(0, slashIndex);
    }

    return value.trim();
  }

  static String _searchTermFromWebsite(String normalizedWebsite) {
    final token = normalizedWebsite.split('.').first.trim();
    if (token.length >= 3) {
      return token.replaceAll(RegExp(r'[_\-]+'), ' ');
    }
    return normalizedWebsite;
  }

  static Map<String, dynamic>? _pickBestMatch(
    List<Map<String, dynamic>> candidates,
    String normalizedWebsite,
  ) {
    for (final item in candidates) {
      final companyUrl = _normalizeWebsite(item['url']?.toString() ?? '');
      if (companyUrl.isNotEmpty &&
          (companyUrl == normalizedWebsite ||
              companyUrl.contains(normalizedWebsite) ||
              normalizedWebsite.contains(companyUrl))) {
        return item;
      }
    }
    return null;
  }

  static Map<String, dynamic> _decodeJsonMap(List<int> bodyBytes) {
    final body = utf8.decode(bodyBytes, allowMalformed: true);
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw GemiOpenDataException('Μη έγκυρο JSON response από το ΓΕΜΗ API.');
  }

  static List<Map<String, dynamic>> _toMapList(dynamic value) {
    if (value is! List) return <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
