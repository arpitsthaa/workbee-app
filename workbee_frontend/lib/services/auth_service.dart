import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/business_registration_model.dart';
import '../models/student_registration_model.dart';

class AuthService {
  static const String _baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://workbee-app.onrender.com');

  static final _gigCreatedController = StreamController<void>.broadcast();
  static Stream<void> get onGigCreated => _gigCreatedController.stream;
  static void notifyGigCreated() => _gigCreatedController.add(null);

  Future<void> warmUp() async {
    try {
      await http.get(Uri.parse('$_baseUrl/api/health/')).timeout(const Duration(seconds: 10));
    } catch (_) {
      // best-effort wake-up; ignore
    }
  }

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };
  }

  /// Safely decodes a response body. Returns null when the body is empty or
  /// the response is not JSON, logging a preview of the raw body for debugging.
  dynamic _decodeBody(http.Response response) {
    final body = response.body;
    if (body.isEmpty) return null;
    final contentType = response.headers['content-type'] ?? '';
    if (!contentType.contains('application/json')) {
      final preview = body.length > 200 ? '${body.substring(0, 200)}...' : body;
      debugPrint('Non-JSON response (${response.statusCode}): $preview');
      return null;
    }
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return decoded;
    } catch (e) {
      debugPrint('JSON decode error: $e');
      return null;
    }
  }

  /// Builds an error map from a response. Extracts detail/message from JSON
  /// bodies; otherwise falls back to the first 200 chars of the raw body.
  Map<String, dynamic> _errorBody(http.Response response, dynamic decoded, String defaultMessage) {
    final body = response.body;
    if (decoded is Map<String, dynamic> && decoded.isNotEmpty) {
      final detail = decoded['detail'] ?? decoded['message'];
      if (detail != null) {
        return {'error': detail.toString(), 'status': response.statusCode};
      }
      final firstValue = decoded.values.first;
      if (firstValue is List && firstValue.isNotEmpty) {
        return {'error': firstValue.first.toString(), 'status': response.statusCode};
      } else if (firstValue is String) {
        return {'error': firstValue, 'status': response.statusCode};
      }
      return {'error': defaultMessage, 'status': response.statusCode};
    }
    final preview = body.isNotEmpty ? (body.length > 200 ? '${body.substring(0, 200)}...' : body) : '';
    return {'error': preview.isNotEmpty ? preview : '$defaultMessage (${response.statusCode})', 'status': response.statusCode};
  }

  Future<StudentRegistrationResponse> registerStudent(
      StudentRegistrationRequest request,
      ) async {
    final url = Uri.parse('$_baseUrl/api/users/register/student/');

    try {
      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      )
          .timeout(const Duration(seconds: 30));

      debugPrint('Register Status: ${response.statusCode}');
      debugPrint('Register Body: ${response.body}');

      final decodedBody = _decodeBody(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return StudentRegistrationResponse.fromJson(
          decodedBody is Map<String, dynamic> ? decodedBody : <String, dynamic>{},
          response.statusCode,
        );
      }

      return StudentRegistrationResponse(
        success: false,
        message: _errorBody(response, decodedBody, 'Registration failed').values.first.toString(),
      );
    } on TimeoutException {
      return StudentRegistrationResponse(
        success: false,
        message: 'Server took too long to respond. Please try again.',
      );
    } catch (e) {
      debugPrint('Register Error: $e');
      return StudentRegistrationResponse(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }

  Future<BusinessRegistrationResponse> registerBusiness(
      BusinessRegistrationRequest request,
      ) async {
    final url = Uri.parse('$_baseUrl/api/users/register/business/');

    try {
      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      )
          .timeout(const Duration(seconds: 30));

      debugPrint('Business Register Status: ${response.statusCode}');
      debugPrint('Business Register Body: ${response.body}');

      final decodedBody = _decodeBody(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        if (decodedBody is Map && decodedBody['token'] != null) {
          await prefs.setString('auth_token', decodedBody['token'].toString());
        }
        return BusinessRegistrationResponse.fromJson(
          decodedBody is Map<String, dynamic> ? decodedBody : <String, dynamic>{},
          response.statusCode,
        );
      }

      return BusinessRegistrationResponse(
        success: false,
        message: _errorBody(response, decodedBody, 'Registration failed').values.first.toString(),
      );
    } on TimeoutException {
      return BusinessRegistrationResponse(
        success: false,
        message: 'Server took too long to respond. Please try again.',
      );
    } catch (e) {
      debugPrint('Business Register Error: $e');
      return BusinessRegistrationResponse(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }

  Future<Map<String, dynamic>> getStudentDashboard() async {
    final url = Uri.parse('$_baseUrl/api/student/dashboard/');
    final headers = await _authHeaders();

    try {
      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 30),
      );

      final decoded = _decodeBody(response);

      if (response.statusCode == 200) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }
      return _errorBody(response, decoded, 'Failed to load dashboard');
    } on TimeoutException {
      return {'error': 'Server took too long to respond.', 'status': 408};
    } catch (e) {
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }

  Future<Map<String, dynamic>> browseGigs({
    String? search,
    String? category,
    int? maxBudget,
  }) async {
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (maxBudget != null) queryParams['max_budget'] = maxBudget.toString();

    final uri = Uri.parse('$_baseUrl/api/student/gigs/').replace(
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    final headers = await _authHeaders();

    debugPrint('BrowseGigs Request: $uri');
    debugPrint('BrowseGigs Headers: $headers');

    try {
      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 30),
      );

      debugPrint('BrowseGigs Response Status: ${response.statusCode}');
      debugPrint('BrowseGigs Response Body: ${response.body}');

      final decoded = _decodeBody(response);

      if (response.statusCode == 200) {
        final gigs = decoded is List ? decoded : <dynamic>[];
        return {'gigs': gigs};
      }
      return _errorBody(response, decoded, 'Failed to load gigs');
    } on TimeoutException {
      return {'error': 'Server took too long to respond.', 'status': 408};
    } catch (e) {
      debugPrint('BrowseGigs Error: $e');
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }

  Future<Map<String, dynamic>> getStudentWork() async {
    final url = Uri.parse('$_baseUrl/api/student/work/');
    final headers = await _authHeaders();

    try {
      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 30),
      );

      final decoded = _decodeBody(response);

      if (response.statusCode == 200) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }
      return _errorBody(response, decoded, 'Failed to load work');
    } on TimeoutException {
      return {'error': 'Server took too long to respond.', 'status': 408};
    } catch (e) {
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }

  Future<Map<String, dynamic>> getCareerPassport() async {
    final url = Uri.parse('$_baseUrl/api/student/passport/');
    final headers = await _authHeaders();

    try {
      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 30),
      );

      final decoded = _decodeBody(response);

      if (response.statusCode == 200) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }
      return _errorBody(response, decoded, 'Failed to load passport');
    } on TimeoutException {
      return {'error': 'Server took too long to respond.', 'status': 408};
    } catch (e) {
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }

  Future<Map<String, dynamic>> getStudentProfile() async {
    final url = Uri.parse('$_baseUrl/api/student/profile/');
    final headers = await _authHeaders();

    try {
      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 30),
      );

      final decoded = _decodeBody(response);

      if (response.statusCode == 200) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }
      return _errorBody(response, decoded, 'Failed to load profile');
    } on TimeoutException {
      return {'error': 'Server took too long to respond.', 'status': 408};
    } catch (e) {
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }

  Future<Map<String, dynamic>> updateStudentProfile(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/api/student/profile/');
    final headers = await _authHeaders();

    try {
      final response = await http
          .put(
        url,
        headers: headers,
        body: jsonEncode(data),
      )
          .timeout(const Duration(seconds: 30));

      final decoded = _decodeBody(response);

      if (response.statusCode == 200) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }
      return _errorBody(response, decoded, 'Failed to update profile');
    } on TimeoutException {
      return {'error': 'Server took too long to respond.', 'status': 408};
    } catch (e) {
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }
}
