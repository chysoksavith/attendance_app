import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

/// Minimal HTTP client wrapping `package:http`. Handles auth headers,
/// JSON encoding, and translates errors into [ApiException].
class ApiClient {
  final http.Client _client;
  final TokenStorage _tokenStorage;

  ApiClient({http.Client? client, required this._tokenStorage})
    : _client = client ?? http.Client();

  // -- Public API ------------------------------------------------------------

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _send('GET', path);
    return _decode(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _send('POST', path, body: body);
    return _decode(response);
  }

  // -- Internal --------------------------------------------------------------

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final headers = await _buildHeaders();

    try {
      final http.Response response;

      switch (method) {
        case 'GET':
          response = await _client
              .get(uri, headers: headers)
              .timeout(ApiConstants.receiveTimeout);
        case 'POST':
          response = await _client
              .post(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(ApiConstants.receiveTimeout);
        default:
          throw ApiException('Unsupported method: $method');
      }

      return response;
    } on SocketException {
      throw const ApiException(
        'No internet connection. Please check your network.',
        statusCode: 0,
      );
    } on http.ClientException {
      throw const ApiException(
        'Could not connect to the server. Please try again.',
        statusCode: 0,
      );
    }
  }

  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Map<String, dynamic> _decode(http.Response response) {
    final Map<String, dynamic> body;

    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        'Unexpected server response',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    // Parse Laravel error format
    final message = body['message'] as String? ?? 'Something went wrong';
    final rawErrors = body['errors'] as Map<String, dynamic>?;
    final errors = <String, List<String>>{};

    if (rawErrors != null) {
      for (final entry in rawErrors.entries) {
        if (entry.value is List) {
          errors[entry.key] = (entry.value as List)
              .map((e) => e.toString())
              .toList();
        }
      }
    }

    throw ApiException(
      message,
      statusCode: response.statusCode,
      errors: errors,
    );
  }
}
