import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thin transport layer. Tokens are supplied per request and never persisted.
class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? const String.fromEnvironment('API_BASE_URL');

  final http.Client _client;
  final String _baseUrl;

  Future<dynamic> get(String path, {String? token}) =>
      _request('GET', path, token: token);

  Future<dynamic> post(String path, {Object? body, String? token}) =>
      _request('POST', path, body: body, token: token);

  Future<dynamic> _request(
    String method,
    String path, {
    Object? body,
    String? token,
  }) async {
    final base = Uri.tryParse(_baseUrl);
    if (base == null ||
        !base.hasAuthority ||
        !['http', 'https'].contains(base.scheme)) {
      throw const ApiException('Configura una URL válida con API_BASE_URL.');
    }
    if (!path.startsWith('/') || path.startsWith('//')) {
      throw const ApiException('La ruta de la API debe comenzar con /.');
    }
    final request = http.Request(method, base.resolve(path));
    request.headers['Accept'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    try {
      final streamed = await _client
          .send(request)
          .timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamed)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          'La API respondió con el código ${response.statusCode}.',
          statusCode: response.statusCode,
        );
      }
      return response.body.isEmpty
          ? null
          : jsonDecode(utf8.decode(response.bodyBytes));
    } on TimeoutException {
      throw const ApiException(
        'La conexión con la API agotó el tiempo de espera.',
      );
    } on http.ClientException {
      throw const ApiException('No se pudo conectar con la API.');
    } on FormatException {
      throw const ApiException('La API devolvió una respuesta inválida.');
    }
  }

  void close() => _client.close();
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}
