import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'http_client.dart';
import '../models/business_registration_model.dart';
import '../models/student_registration_model.dart';

class AuthService {
  static final _gigCreatedController = StreamController<void>.broadcast();
  static Stream<void> get onGigCreated => _gigCreatedController.stream;
  static void notifyGigCreated() => _gigCreatedController.add(null);

  Future<void> warmUp() async {
    try {
      await HttpClient.get('/api/health/');
    } catch (_) {}
  }

  dynamic _decodeBody(dynamic body) {
    if (body == null) return null;
    if (body is String) {
      if (body.isEmpty) return null;
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
        return decoded;
      } catch (e) {
        debugPrint('JSON decode error: $e');
        return null;
      }
    }
    return body;
  }

  Map<String, dynamic> _errorBody(dynamic decoded, String defaultMessage, int statusCode) {
    final body = decoded is Map<String, dynamic> && decoded.isNotEmpty
        ? decoded
        : <String, dynamic>{};
    if (body.isNotEmpty) {
      final detail = body['detail'] ?? body['message'];
      if (detail != null) return {'error': detail.toString(), 'status': statusCode};
      final firstValue = body.values.first;
      if (firstValue is List && firstValue.isNotEmpty) {
        return {'error': firstValue.first.toString(), 'status': statusCode};
      } else if (firstValue is String) {
        return {'error': firstValue, 'status': statusCode};
      }
      return {'error': defaultMessage, 'status': statusCode};
    }
    return {'error': defaultMessage, 'status': statusCode};
  }

  Future<StudentRegistrationResponse> registerStudent(StudentRegistrationRequest request) async {
    final url = '/api/users/register/student/';
    try {
      final response = await HttpClient.post(url, body: request.toJson()).timeout(const Duration(seconds: 30));
      debugPrint('Register Status: ${response.statusCode}');
      debugPrint('Register Body: ${response.body}');
      final decodedBody = _decodeBody(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return StudentRegistrationResponse.fromJson(
          decodedBody is Map<String, dynamic> ? decodedBody : <String, dynamic>{},
          response.statusCode,
        );
      }
      return StudentRegistrationResponse(
        success: false,
        message: _errorBody(decodedBody, 'Registration failed', response.statusCode).values.first.toString(),
      );
    } catch (e) {
      debugPrint('Register Error: $e');
      return StudentRegistrationResponse(success: false, message: 'Connection error: $e');
    }
  }

  Future<BusinessRegistrationResponse> registerBusiness(BusinessRegistrationRequest request) async {
    final url = '/api/users/register/business/';
    try {
      final response = await HttpClient.post(url, body: request.toJson()).timeout(const Duration(seconds: 30));
      debugPrint('Business Register Status: ${response.statusCode}');
      debugPrint('Business Register Body: ${response.body}');
      final decodedBody = _decodeBody(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        if (decodedBody is Map && decodedBody['token'] != null) {
          await prefs.setString('auth_token', decodedBody['token'].toString());
          await HttpClient.setToken(decodedBody['token'].toString());
        }
        return BusinessRegistrationResponse.fromJson(
          decodedBody is Map<String, dynamic> ? decodedBody : <String, dynamic>{},
          response.statusCode,
        );
      }
      return BusinessRegistrationResponse(
        success: false,
        message: _errorBody(decodedBody, 'Registration failed', response.statusCode).values.first.toString(),
      );
    } catch (e) {
      debugPrint('Business Register Error: $e');
      return BusinessRegistrationResponse(success: false, message: 'Connection error: $e');
    }
  }

  Future<Map<String, dynamic>> getStudentDashboard() async {
    final url = '/api/student/dashboard/';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      return {'error': 'Not authenticated. Please log in.', 'status': 401};
    }
    try {
      final response = await HttpClient.get(url).timeout(const Duration(seconds: 30));
      debugPrint('Dashboard Status: ${response.statusCode}');
      debugPrint('Dashboard Body: ${response.body}');
      final decoded = _decodeBody(response.body);
      if (response.statusCode == 200) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }
      return _errorBody(decoded, 'Failed to load dashboard', response.statusCode);
    } catch (e) {
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }

  Future<Map<String, dynamic>> browseGigs({String? search, String? category, int? maxBudget}) async {
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (maxBudget != null) queryParams['max_budget'] = maxBudget.toString();
    final uri = '/api/student/gigs/' + (queryParams.isEmpty ? '' : '?${Uri(queryParameters: queryParams).query}');
    debugPrint('BrowseGigs Request: $uri');
    try {
      final response = await HttpClient.get(uri).timeout(const Duration(seconds: 30));
      debugPrint('BrowseGigs Response Status: ${response.statusCode}');
      debugPrint('BrowseGigs Response Body: ${response.body}');
      final decoded = _decodeBody(response.body);
      if (response.statusCode == 200) {
        final gigs = decoded is List ? decoded : <dynamic>[];
        return {'gigs': gigs};
      }
      return _errorBody(decoded, 'Failed to load gigs', response.statusCode);
    } catch (e) {
      debugPrint('BrowseGigs Error: $e');
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }

  Future<Map<String, dynamic>> getStudentWork() async {
    final url = '/api/student/work/';
    try {
      final response = await HttpClient.get(url).timeout(const Duration(seconds: 30));
      final decoded = _decodeBody(response.body);
      if (response.statusCode == 200) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }
      return _errorBody(decoded, 'Failed to load work', response.statusCode);
    } catch (e) {
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }

  Future<Map<String, dynamic>> getCareerPassport() async {
    final url = '/api/student/passport/';
    try {
      final response = await HttpClient.get(url).timeout(const Duration(seconds: 30));
      final decoded = _decodeBody(response.body);
      if (response.statusCode == 200) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }
      return _errorBody(decoded, 'Failed to load passport', response.statusCode);
    } catch (e) {
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }

  Future<Map<String, dynamic>> getStudentProfile() async {
    final url = '/api/student/profile/';
    try {
      final response = await HttpClient.get(url).timeout(const Duration(seconds: 30));
      final decoded = _decodeBody(response.body);
      if (response.statusCode == 200) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }
      return _errorBody(decoded, 'Failed to load profile', response.statusCode);
    } catch (e) {
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }

  Future<Map<String, dynamic>> updateStudentProfile(Map<String, dynamic> data) async {
    final url = '/api/student/profile/';
    try {
      final response = await HttpClient.put(url, body: data).timeout(const Duration(seconds: 30));
      final decoded = _decodeBody(response.body);
      if (response.statusCode == 200) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }
      return _errorBody(decoded, 'Failed to update profile', response.statusCode);
    } catch (e) {
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }
}
