import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HttpClient {
  static const String baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'https://workbee-app.onrender.com');

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Token $token';
    }
    return headers;
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<http.Response> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    return http.get(uri, headers: await _headers());
  }

  static Future<http.Response> post(String path, {Object? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    return http.post(uri, headers: await _headers(), body: body == null ? null : jsonEncode(body));
  }

  static Future<http.Response> put(String path, {Object? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    return http.put(uri, headers: await _headers(), body: body == null ? null : jsonEncode(body));
  }
}
