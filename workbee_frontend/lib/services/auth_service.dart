import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/dio_client.dart';
import '../models/business_registration_model.dart';
import '../models/student_registration_model.dart';

class AuthService {
  static final Dio _dio = DioClient().dio;

  static final _gigCreatedController = StreamController<void>.broadcast();
  static Stream<void> get onGigCreated => _gigCreatedController.stream;
  static void notifyGigCreated() => _gigCreatedController.add(null);

  Future<void> warmUp() async {
    DioClient().warmUp();
  }

  dynamic _decodeBody(dynamic body) {
    if (body == null) return null;
    if (body is String) {
      if (body.isEmpty) return null;
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
    return body;
  }

  Map<String, dynamic> _errorBody(dynamic decoded, String defaultMessage, int statusCode) {
    final body = decoded is Map<String, dynamic> && decoded.isNotEmpty
        ? decoded
        : <String, dynamic>{};

    if (body.isNotEmpty) {
      final detail = body['detail'] ?? body['message'];
      if (detail != null) {
        return {'error': detail.toString(), 'status': statusCode};
      }
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

  Future<StudentRegistrationResponse> registerStudent(
      StudentRegistrationRequest request,) async {
    final url = '/api/users/register/student/';

    try {
      final response = await _dio.post(
        url,
        data: jsonEncode(request.toJson()),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ).timeout(const Duration(seconds: 30));

      debugPrint('Register Status: ${response.statusCode}');
      debugPrint('Register Body: ${response.data}');

      final decodedBody = _decodeBody(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return StudentRegistrationResponse.fromJson(
          decodedBody is Map<String, dynamic> ? decodedBody : <String, dynamic>{},
          response.statusCode ?? 0,
        );
      }

      return StudentRegistrationResponse(
        success: false,
        message: _errorBody(decodedBody, 'Registration failed', response.statusCode ?? 0).values.first.toString(),
      );
    } on DioException catch (e) {
      debugPrint('Register DioError: $e');
      if (e.response == null) {
        return StudentRegistrationResponse(
          success: false,
          message: 'Unable to connect to the backend. Is the server running?',
        );
      }
      final statusCode = e.response?.statusCode ?? 0;
      final decodedBody = _decodeBody(e.response?.data);
      return StudentRegistrationResponse(
        success: false,
        message: _errorBody(decodedBody, 'Registration failed', statusCode).values.first.toString(),
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
      BusinessRegistrationRequest request,) async {
    final url = '/api/users/register/business/';

    try {
      final response = await _dio.post(
        url,
        data: jsonEncode(request.toJson()),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ).timeout(const Duration(seconds: 30));

      debugPrint('Business Register Status: ${response.statusCode}');
      debugPrint('Business Register Body: ${response.data}');

      final decodedBody = _decodeBody(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        if (decodedBody is Map && decodedBody['token'] != null) {
          await prefs.setString('auth_token', decodedBody['token'].toString());
        }
        return BusinessRegistrationResponse.fromJson(
          decodedBody is Map<String, dynamic> ? decodedBody : <String, dynamic>{},
          response.statusCode ?? 0,
        );
      }

      return BusinessRegistrationResponse(
        success: false,
        message: _errorBody(decodedBody, 'Registration failed', response.statusCode ?? 0).values.first.toString(),
      );
    } on DioException catch (e) {
      debugPrint('Business Register DioError: $e');
      if (e.response == null) {
        return BusinessRegistrationResponse(
          success: false,
          message: 'Unable to connect to the backend. Is the server running?',
        );
      }
      final statusCode = e.response?.statusCode ?? 0;
      final decodedBody = _decodeBody(e.response?.data);
      return BusinessRegistrationResponse(
        success: false,
        message: _errorBody(decodedBody, 'Registration failed', statusCode).values.first.toString(),
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
    final url = '/api/student/dashboard/';

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      return {'error': 'Not authenticated. Please log in.', 'status': 401};
    }

    try {
      final response = await _dio.get(url).timeout(
        const Duration(seconds: 30),
      );

      debugPrint('Dashboard Status: ${response.statusCode}');
      debugPrint('Dashboard Body: ${response.data}');

      final decoded = _decodeBody(response.data);

      if (response.statusCode == 200) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }
      return _errorBody(decoded, 'Failed to load dashboard', response.statusCode ?? 0);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 0;
      final decodedBody = _decodeBody(e.response?.data);
      debugPrint('Dashboard DioError: status=$statusCode data=${e.response?.data}');
      if (e.response == null) {
        return {'error': 'Unable to connect to the backend. Is the server running?', 'status': 0};
      }
      return _errorBody(decodedBody, 'Failed to load dashboard', statusCode);
    } catch (e) {
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }

  Future<Map<String, dynamic>> browseGigs({
    String? search,
    String? category,
    int? maxBudget,
  }) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (maxBudget != null) queryParams['max_budget'] = maxBudget.toString();

    final uri = '/api/student/gigs/';

    debugPrint('BrowseGigs Request: $uri');
    debugPrint('BrowseGigs Query: $queryParams');

    try {
      final response = await _dio.get(
        uri,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      ).timeout(
        const Duration(seconds: 30),
      );

      debugPrint('BrowseGigs Response Status: ${response.statusCode}');
      debugPrint('BrowseGigs Response Body: ${response.data}');

      final decoded = _decodeBody(response.data);

      if (response.statusCode == 200) {
        final gigs = decoded is List ? decoded : <dynamic>[];
        return {'gigs': gigs};
      }
      return _errorBody(decoded, 'Failed to load gigs', response.statusCode ?? 0);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 0;
      final decodedBody = _decodeBody(e.response?.data);
      if (e.response == null) {
        return {'error': 'Unable to connect to the backend. Is the server running?', 'status': 0};
      }
      return _errorBody(decodedBody, 'Failed to load gigs', statusCode);
    } catch (e) {
      debugPrint('BrowseGigs Error: $e');
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }

  Future<Map<String, dynamic>> getStudentWork() async {
    final url = '/api/student/work/';

    try {
      final response = await _dio.get(url).timeout(
        const Duration(seconds: 30),
      );

      final decoded = _decodeBody(response.data);

      if (response.statusCode == 200) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }
      return _errorBody(decoded, 'Failed to load work', response.statusCode ?? 0);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 0;
      final decodedBody = _decodeBody(e.response?.data);
      if (e.response == null) {
        return {'error': 'Unable to connect to the backend. Is the server running?', 'status': 0};
      }
      return _errorBody(decodedBody, 'Failed to load work', statusCode);
    } catch (e) {
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }

  Future<Map<String, dynamic>> getCareerPassport() async {
    final url = '/api/student/passport/';

    try {
      final response = await _dio.get(url).timeout(
        const Duration(seconds: 30),
      );

      final decoded = _decodeBody(response.data);

      if (response.statusCode == 200) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }
      return _errorBody(decoded, 'Failed to load passport', response.statusCode ?? 0);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 0;
      final decodedBody = _decodeBody(e.response?.data);
      if (e.response == null) {
        return {'error': 'Unable to connect to the backend. Is the server running?', 'status': 0};
      }
      return _errorBody(decodedBody, 'Failed to load passport', statusCode);
    } catch (e) {
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }

  Future<Map<String, dynamic>> getStudentProfile() async {
    final url = '/api/student/profile/';

    try {
      final response = await _dio.get(url).timeout(
        const Duration(seconds: 30),
      );

      final decoded = _decodeBody(response.data);

      if (response.statusCode == 200) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }
      return _errorBody(decoded, 'Failed to load profile', response.statusCode ?? 0);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 0;
      final decodedBody = _decodeBody(e.response?.data);
      if (e.response == null) {
        return {'error': 'Unable to connect to the backend. Is the server running?', 'status': 0};
      }
      return _errorBody(decodedBody, 'Failed to load profile', statusCode);
    } catch (e) {
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }

  Future<Map<String, dynamic>> updateStudentProfile(Map<String, dynamic> data) async {
    final url = '/api/student/profile/';

    try {
      final response = await _dio.put(
        url,
        data: jsonEncode(data),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ).timeout(const Duration(seconds: 30));

      final decoded = _decodeBody(response.data);

      if (response.statusCode == 200) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }
      return _errorBody(decoded, 'Failed to update profile', response.statusCode ?? 0);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 0;
      final decodedBody = _decodeBody(e.response?.data);
      if (e.response == null) {
        return {'error': 'Unable to connect to the backend. Is the server running?', 'status': 0};
      }
      return _errorBody(decodedBody, 'Failed to update profile', statusCode);
    } catch (e) {
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }
}
