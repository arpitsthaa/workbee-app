import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/business_registration_model.dart';
import '../models/student_registration_model.dart';
import '../services/user_session_service.dart';

class AuthService {
  static const String _baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://workbee-app.onrender.com');

  static final _gigCreatedController = StreamController<void>.broadcast();
  static Stream<void> get onGigCreated => _gigCreatedController.stream;
  static void notifyGigCreated() => _gigCreatedController.add(null);

  Future<void> warmUp() async {
    try {
      await http.get(Uri.parse('$_baseUrl/api/health/'))
          .timeout(const Duration(seconds: 10));
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

  Map<String, dynamic> _decodeMap(String body) {
    if (body.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  List<dynamic> _decodeList(String body) {
    if (body.isEmpty) return <dynamic>[];
    try {
      final decoded = jsonDecode(body);
      return decoded is List<dynamic> ? decoded : <dynamic>[];
    } catch (_) {
      return <dynamic>[];
    }
  }

  String _errorMessage(Map<String, dynamic> body, int status) {
    final detail = body['detail'] ?? body['message'] ?? body['error'];
    if (detail is String && detail.isNotEmpty) return detail;
    return 'Server error ($status). Please try again later.';
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

      final Map<String, dynamic> decodedBody = response.body.isNotEmpty
          ? Map<String, dynamic>.from(jsonDecode(response.body))
          : <String, dynamic>{};

      if (response.statusCode == 200 || response.statusCode == 201) {
        return StudentRegistrationResponse.fromJson(
          decodedBody,
          response.statusCode,
        );
      }

      String errorMessage = 'Registration failed (${response.statusCode}).';
      if (decodedBody.isNotEmpty) {
        final firstValue = decodedBody.values.first;
        if (firstValue is List && firstValue.isNotEmpty) {
          errorMessage = firstValue.first.toString();
        } else if (firstValue is String) {
          errorMessage = firstValue;
        }
      }

      return StudentRegistrationResponse(
        success: false,
        message: errorMessage,
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

      final Map<String, dynamic> decodedBody = response.body.isNotEmpty
          ? Map<String, dynamic>.from(jsonDecode(response.body))
          : <String, dynamic>{};

      if (response.statusCode == 200 || response.statusCode == 201) {
        return BusinessRegistrationResponse.fromJson(
          decodedBody,
          response.statusCode,
        );
      }

      String errorMessage = 'Registration failed (${response.statusCode}).';
      if (decodedBody.isNotEmpty) {
        final firstValue = decodedBody.values.first;
        if (firstValue is List && firstValue.isNotEmpty) {
          errorMessage = firstValue.first.toString();
        } else if (firstValue is String) {
          errorMessage = firstValue;
        }
      }

      return BusinessRegistrationResponse(
        success: false,
        message: errorMessage,
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

      final body = _decodeMap(response.body);

      if (response.statusCode == 200) {
        return body;
      }
      return {
        'error': _errorMessage(body, response.statusCode),
        'status': response.statusCode,
      };
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

      final body = _decodeList(response.body);

      if (response.statusCode == 200) {
        return {'gigs': body};
      }
      return {
        'error': _errorMessage(_decodeMap(response.body), response.statusCode),
        'status': response.statusCode,
      };
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

      final body = _decodeMap(response.body);

      if (response.statusCode == 200) {
        return body;
      }
      return {
        'error': _errorMessage(body, response.statusCode),
        'status': response.statusCode,
      };
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

      final body = _decodeMap(response.body);

      if (response.statusCode == 200) {
        return body;
      }
      return {
        'error': _errorMessage(body, response.statusCode),
        'status': response.statusCode,
      };
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

      final body = _decodeMap(response.body);

      if (response.statusCode == 200) {
        return body;
      }
      return {
        'error': _errorMessage(body, response.statusCode),
        'status': response.statusCode,
      };
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

      final body = _decodeMap(response.body);

      if (response.statusCode == 200) {
        return body;
      }
      return {
        'error': _errorMessage(body, response.statusCode),
        'status': response.statusCode,
      };
    } on TimeoutException {
      return {'error': 'Server took too long to respond.', 'status': 408};
    } catch (e) {
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    await UserSessionService().clear();
  }

  Future<Map<String, dynamic>> applyForGig(int gigId, {String? coverMessage}) async {
    final url = Uri.parse('$_baseUrl/api/student/gigs/$gigId/apply/');
    final headers = await _authHeaders();

    try {
      final response = await http
          .post(
        url,
        headers: headers,
        body: jsonEncode({'cover_message': coverMessage ?? ''}),
      )
          .timeout(const Duration(seconds: 30));

      final body = _decodeMap(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return body;
      }
      return {
        'error': _errorMessage(body, response.statusCode),
        'status': response.statusCode,
      };
    } on TimeoutException {
      return {'error': 'Server took too long to respond.', 'status': 408};
    } catch (e) {
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }

  Future<Map<String, dynamic>> withdrawApplication(int applicationId) async {
    final url = Uri.parse('$_baseUrl/api/student/applications/$applicationId/withdraw/');
    final headers = await _authHeaders();

    try {
      final response = await http
          .delete(
        url,
        headers: headers,
      )
          .timeout(const Duration(seconds: 30));

      final body = _decodeMap(response.body);

      if (response.statusCode == 200) {
        return body;
      }
      return {
        'error': _errorMessage(body, response.statusCode),
        'status': response.statusCode,
      };
    } on TimeoutException {
      return {'error': 'Server took too long to respond.', 'status': 408};
    } catch (e) {
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }
}
