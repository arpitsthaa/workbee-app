import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

/// Handles authentication API requests: login, register student, register business.
class AuthClient {
  static const Duration _timeout = Duration(seconds: 30);

  /// Decodes a JSON response body into a Map.
  static Map<String, dynamic> _decodeBody(String body) {
    if (body.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  /// Extracts a readable error message from the response body.
  static String _errorMessage(Map<String, dynamic> body, int status) {
    final detail = body['detail'] ?? body['message'] ?? body['error'];
    if (detail is String && detail.isNotEmpty) return detail;

    if (body.isNotEmpty) {
      final errors = <String>[];
      body.forEach((key, value) {
        if (key == 'detail' || key == 'message' || key == 'error') return;
        if (value is List) {
          for (final v in value) {
            errors.add('$key: ${v.toString()}');
          }
        } else if (value is String) {
          errors.add('$key: $value');
        }
      });
      if (errors.isNotEmpty) return errors.join('; ');
    }

    return 'Server error ($status). Please try again later.';
  }

  /// Registers a new student account.
  static Future<Map<String, dynamic>> registerStudent(
      Map<String, dynamic> requestData) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.registerStudent}');

    try {
      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      )
          .timeout(_timeout);

      final body = _decodeBody(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': body['message'] ?? 'Student account created successfully.',
          'token': body['token']?.toString(),
          'user': body['user'],
        };
      }

      return {
        'success': false,
        'message': _errorMessage(body, response.statusCode),
        'status': response.statusCode,
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Server took too long to respond. Please try again.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  /// Registers a new business account.
  static Future<Map<String, dynamic>> registerBusiness(
      Map<String, dynamic> requestData) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.registerBusiness}');

    try {
      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      )
          .timeout(_timeout);

      final body = _decodeBody(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': body['message'] ?? 'Business account created successfully.',
          'token': body['token']?.toString(),
          'user': body['user'],
        };
      }

      return {
        'success': false,
        'message': _errorMessage(body, response.statusCode),
        'status': response.statusCode,
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Server took too long to respond. Please try again.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  /// Logs in a user with email and password.
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}');

    try {
      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      )
          .timeout(const Duration(seconds: 45));

      final body = _decodeBody(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Login successful.',
          'user': body['user'],
          'token': body['token'],
        };
      }

      return {
        'success': false,
        'message': body['detail'] ?? body['error'] ?? 'Invalid email or password',
        'status': response.statusCode,
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Server took too long to respond. Please try again.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection failed. Make sure the backend is running.',
      };
    }
  }

  /// Saves the auth token to local storage.
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Retrieves the stored auth token.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Removes the auth token from local storage.
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
