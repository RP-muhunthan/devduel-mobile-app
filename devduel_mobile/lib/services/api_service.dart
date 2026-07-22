import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Central HTTP client for the DevDuel REST API.
/// Automatically attaches JWT token to every request.
class ApiService {
  // ── Base URL ──────────────────────────────────────────────────────────────
  // Android emulator: use 10.0.2.2 to reach host machine's localhost
  // Web / desktop: use localhost
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Reverted to 127.0.0.1 because Windows Firewall blocks Wi-Fi connections.
      // We will use the `adb reverse tcp:8000 tcp:8000` USB bridge instead!
      return 'http://127.0.0.1:8000';
    } else {
      // Desktop uses localhost
      return 'http://127.0.0.1:8000';
    }
  }

  static const String _tokenKey = 'devduel_jwt_token';

  // ── Token Management ──────────────────────────────────────────────────────

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── Headers ───────────────────────────────────────────────────────────────

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // ── HTTP Methods ──────────────────────────────────────────────────────────

  static Future<dynamic> get(String path, {bool auth = true}) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = await _headers(auth: auth);
    debugPrint('[API] GET $uri');
    final response = await http.get(uri, headers: headers);
    return _handleResponse(response);
  }

  static Future<dynamic> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = await _headers(auth: auth);
    debugPrint('[API] POST $uri');
    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> put(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = await _headers(auth: auth);
    debugPrint('[API] PUT $uri');
    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> delete(String path, {bool auth = true}) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = await _headers(auth: auth);
    debugPrint('[API] DELETE $uri');
    final response = await http.delete(uri, headers: headers);
    return _handleResponse(response);
  }

  // ── Response Handler ──────────────────────────────────────────────────────

  static dynamic _handleResponse(http.Response response) {
    final body = utf8.decode(response.bodyBytes);
    debugPrint('[API] Status: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body.isEmpty) return null;
      return jsonDecode(body);
    }

    // Try to extract error detail from response
    String errorMessage = 'Request failed (${response.statusCode})';
    try {
      final errorBody = jsonDecode(body);
      final detail = errorBody['detail'];
      if (detail is List && detail.isNotEmpty) {
        errorMessage = detail.first['msg']?.toString() ?? errorMessage;
      } else if (detail is String) {
        errorMessage = detail;
      }
    } catch (_) {}

    throw ApiException(errorMessage, response.statusCode);
  }
}

/// Custom exception for API errors.
class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
