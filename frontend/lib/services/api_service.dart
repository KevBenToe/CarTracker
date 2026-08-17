import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  ApiService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<bool> checkConnectivity() async {
    try {
      final http.Response response = await _client
          .get(_buildUri('vehicles/'))
          .timeout(const Duration(seconds: 4));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<List<dynamic>> getList(String path) async {
    final dynamic payload = await _requestJson('GET', path);
    return _normalizeList(payload);
  }

  Future<Map<String, dynamic>> getObject(String path) async {
    final dynamic payload = await _requestJson('GET', path);
    return _normalizeObject(payload);
  }

  Future<Map<String, dynamic>> postObject(
    String path,
    Map<String, dynamic> body,
  ) async {
    final dynamic payload = await _requestJson('POST', path, body: body);
    return _normalizeObject(payload);
  }

  Future<Map<String, dynamic>> putObject(
    String path,
    Map<String, dynamic> body,
  ) async {
    final dynamic payload = await _requestJson('PUT', path, body: body);
    return _normalizeObject(payload);
  }

  Future<void> delete(String path) async {
    final http.Response response = await _client
        .delete(_buildUri(path), headers: _headers)
        .timeout(const Duration(seconds: 8));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Request failed with status ${response.statusCode}: ${response.body}',
      );
    }
  }

  /// Uploads an image for a vehicle using a multipart PATCH request.
  /// [path] is the API path (e.g. 'vehicles/<id>/').
  /// [imageBytes] is the raw image bytes.
  /// [fileName] is the file name including extension.
  /// Returns the updated object as a JSON map.
  Future<Map<String, dynamic>> patchMultipart(
    String path,
    Map<String, String> fields,
    List<int> imageBytes,
    String fileName,
  ) async {
    final Uri uri = _buildUri(path);
    final http.MultipartRequest request = http.MultipartRequest('PATCH', uri)
      ..headers['Accept'] = 'application/json'
      ..fields.addAll(fields)
      ..files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: fileName,
        ),
      );
    final http.StreamedResponse streamed =
        await _client.send(request).timeout(const Duration(seconds: 30));
    final String body = await streamed.stream.bytesToString();
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw ApiException(
        'Request failed with status ${streamed.statusCode}: $body',
      );
    }
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }
    final dynamic decoded = jsonDecode(body);
    return _normalizeObject(decoded);
  }

  Uri _buildUri(String path) {
    final String normalizedBase =
        baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final String normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$normalizedBase/$normalizedPath');
  }

  Map<String, String> get _headers {
    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<dynamic> _requestJson(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    late http.Response response;
    final Uri uri = _buildUri(path);

    switch (method) {
      case 'GET':
        response = await _client
            .get(uri, headers: _headers)
            .timeout(const Duration(seconds: 8));
        break;
      case 'POST':
        response = await _client
            .post(uri, headers: _headers, body: jsonEncode(body))
            .timeout(const Duration(seconds: 8));
        break;
      case 'PUT':
        response = await _client
            .put(uri, headers: _headers, body: jsonEncode(body))
            .timeout(const Duration(seconds: 8));
        break;
      default:
        throw UnsupportedError('Unsupported method $method');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Request failed with status ${response.statusCode}: ${response.body}',
      );
    }

    if (response.body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    return jsonDecode(response.body);
  }

  List<dynamic> _normalizeList(dynamic payload) {
    if (payload is List<dynamic>) {
      return payload;
    }
    if (payload is Map<String, dynamic>) {
      if (payload['results'] is List<dynamic>) {
        return payload['results'] as List<dynamic>;
      }
      if (payload['items'] is List<dynamic>) {
        return payload['items'] as List<dynamic>;
      }
      if (payload['data'] is List<dynamic>) {
        return payload['data'] as List<dynamic>;
      }
    }
    throw ApiException('Expected a list response.');
  }

  Map<String, dynamic> _normalizeObject(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      if (payload['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(payload['data'] as Map);
      }
      return Map<String, dynamic>.from(payload);
    }
    throw ApiException('Expected an object response.');
  }
}

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => 'ApiException: $message';
}
