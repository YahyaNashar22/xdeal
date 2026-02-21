// lib/services/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

extension _Body on Object? {
  String? toJsonBody() => this == null ? null : jsonEncode(this);
}

class ApiClient {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  ApiClient({
    required this.baseUrl,
    this.defaultHeaders = const {'Content-Type': 'application/json'},
  });

  Uri _uri(String path, [Map<String, String>? query]) {
    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$cleanBase$cleanPath').replace(queryParameters: query);
  }

  Future<dynamic> getJson(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    final res = await http.get(
      _uri(path, query),
      headers: {...defaultHeaders, ...?headers},
    );
    final body = res.body.isEmpty ? null : jsonDecode(res.body);

    if (res.statusCode >= 200 && res.statusCode < 300) return body;

    final msg = (body is Map && body['message'] != null)
        ? body['message'].toString()
        : 'Request failed';
    throw Exception('$msg (HTTP ${res.statusCode})');
  }

  Future<dynamic> postJson(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final res = await http.post(
      _uri(path),
      headers: {...defaultHeaders, ...?headers},
      body: body.toJsonBody(),
    );
    final data = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    final msg = (data is Map && data['message'] != null)
        ? data['message'].toString()
        : 'Request failed';
    throw Exception('$msg (HTTP ${res.statusCode})');
  }

  Future<dynamic> putJson(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final res = await http.put(
      _uri(path),
      headers: {...defaultHeaders, ...?headers},
      body: body.toJsonBody(),
    );
    final data = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    final msg = (data is Map && data['message'] != null)
        ? data['message'].toString()
        : 'Request failed';
    throw Exception('$msg (HTTP ${res.statusCode})');
  }

  Future<dynamic> patchJson(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final res = await http.patch(
      _uri(path),
      headers: {...defaultHeaders, ...?headers},
      body: body.toJsonBody(),
    );
    final data = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    final msg = (data is Map && data['message'] != null)
        ? data['message'].toString()
        : 'Request failed';
    throw Exception('$msg (HTTP ${res.statusCode})');
  }

  Future<dynamic> deleteJson(
    String path, {
    Map<String, String>? headers,
  }) async {
    final res = await http.delete(
      _uri(path),
      headers: {...defaultHeaders, ...?headers},
    );
    final data = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    final msg = (data is Map && data['message'] != null)
        ? data['message'].toString()
        : 'Request failed';
    throw Exception('$msg (HTTP ${res.statusCode})');
  }
}
