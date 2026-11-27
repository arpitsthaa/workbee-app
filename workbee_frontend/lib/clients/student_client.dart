import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../clients/auth_client.dart';

/// Handles student API requests: dashboard, gigs, applications, work, passport, profile.
class StudentClient {
  static const Duration _timeout = Duration(seconds: 30);
  static const Duration _shortTimeout = Duration(seconds: 15);

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

  /// Decodes a JSON response body into a List.
  static List<dynamic> _decodeList(String body) {
    if (body.isEmpty) return <dynamic>[];
    try {
      final decoded = jsonDecode(body);
      return decoded is List<dynamic> ? decoded : <dynamic>[];
    } catch (_) {
      return <dynamic>[];
    }
  }

  /// Builds auth headers with the stored token.
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthClient.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };
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

  /// Fetches the full student dashboard (combined endpoint).
  static Future<Map<String, dynamic>> getDashboard() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.studentDashboard}');
    final headers = await _authHeaders();

    try {
      final response = await http.get(url, headers: headers).timeout(_timeout);
      final body = _decodeBody(response.body);

      if (response.statusCode == 200) return body;

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

  /// Fetches student profile data.
  static Future<Map<String, dynamic>> getProfile() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.studentProfile}');
    final headers = await _authHeaders();

    try {
      final response = await http.get(url, headers: headers).timeout(_timeout);
      final body = _decodeBody(response.body);

      if (response.statusCode == 200) return body;

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

  /// Updates the student profile.
  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.studentProfile}');
    final headers = await _authHeaders();

    try {
      final response = await http
          .put(
        url,
        headers: headers,
        body: jsonEncode(data),
      )
          .timeout(_timeout);

      final body = _decodeBody(response.body);

      if (response.statusCode == 200) return body;

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

  /// Fetches browsable gigs with optional filters.
  static Future<Map<String, dynamic>> browseGigs({
    String? search,
    String? category,
    int? maxBudget,
  }) async {
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (maxBudget != null) queryParams['max_budget'] = maxBudget.toString();

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.studentGigs}')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
    final headers = await _authHeaders();

    try {
      final response = await http.get(uri, headers: headers).timeout(_timeout);

      if (response.statusCode == 200) {
        return {'gigs': _decodeList(response.body)};
      }

      return {
        'error': _errorMessage(_decodeBody(response.body), response.statusCode),
        'status': response.statusCode,
      };
    } on TimeoutException {
      return {'error': 'Server took too long to respond.', 'status': 408};
    } catch (e) {
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }

  /// Applies for a gig.
  static Future<Map<String, dynamic>> applyForGig(
      int gigId, {
        String? coverMessage,
      }) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.studentApplyGigById}$gigId/apply/');
    final headers = await _authHeaders();

    try {
      final response = await http
          .post(
        url,
        headers: headers,
        body: jsonEncode({'cover_message': coverMessage ?? ''}),
      )
          .timeout(_timeout);

      final body = _decodeBody(response.body);

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

  /// Withdraws a gig application.
  static Future<Map<String, dynamic>> withdrawApplication(int applicationId) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.studentWithdrawApplication}$applicationId/withdraw/');
    final headers = await _authHeaders();

    try {
      final response = await http.delete(url, headers: headers).timeout(_timeout);

      final body = _decodeBody(response.body);

      if (response.statusCode == 200) return body;

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

  /// Fetches student's work (applications + projects combined).
  static Future<Map<String, dynamic>> getWork() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.studentWork}');
    final headers = await _authHeaders();

    try {
      final response = await http.get(url, headers: headers).timeout(_timeout);
      final body = _decodeBody(response.body);

      if (response.statusCode == 200) return body;

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

  /// Fetches the career passport data.
  static Future<Map<String, dynamic>> getPassport() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.studentPassport}');
    final headers = await _authHeaders();

    try {
      final response = await http.get(url, headers: headers).timeout(_timeout);
      final body = _decodeBody(response.body);

      if (response.statusCode == 200) return body;

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

  // ---- Split dashboard endpoints (parallel fetch) ----

  static Future<Map<String, dynamic>> getDashboardProfile() async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.studentDashboardProfile}');
    final headers = await _authHeaders();

    try {
      final response = await http.get(url, headers: headers).timeout(_shortTimeout);
      if (response.statusCode == 200) return _decodeBody(response.body);

      return {
        'error': _errorMessage(_decodeBody(response.body), response.statusCode),
        'status': response.statusCode,
      };
    } on TimeoutException {
      return {'error': 'Server took too long to respond.', 'status': 408};
    } catch (e) {
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }

  static Future<Map<String, dynamic>> getDashboardGigs() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.studentDashboardGigs}');
    final headers = await _authHeaders();

    try {
      final response = await http.get(url, headers: headers).timeout(_shortTimeout);
      if (response.statusCode == 200) return _decodeBody(response.body);

      return {
        'error': _errorMessage(_decodeBody(response.body), response.statusCode),
        'status': response.statusCode,
      };
    } on TimeoutException {
      return {'error': 'Server took too long to respond.', 'status': 408};
    } catch (e) {
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }

  static Future<Map<String, dynamic>> getDashboardSummary() async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.studentDashboardSummary}');
    final headers = await _authHeaders();

    try {
      final response = await http.get(url, headers: headers).timeout(_shortTimeout);
      if (response.statusCode == 200) return _decodeBody(response.body);

      return {
        'error': _errorMessage(_decodeBody(response.body), response.statusCode),
        'status': response.statusCode,
      };
    } on TimeoutException {
      return {'error': 'Server took too long to respond.', 'status': 408};
    } catch (e) {
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }

  // ---- Split work endpoints (parallel fetch) ----

  static Future<Map<String, dynamic>> getWorkApplications() async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.studentWorkApplications}');
    final headers = await _authHeaders();

    try {
      final response = await http.get(url, headers: headers).timeout(_shortTimeout);
      if (response.statusCode == 200) return _decodeBody(response.body);

      return {
        'error': _errorMessage(_decodeBody(response.body), response.statusCode),
        'status': response.statusCode,
      };
    } on TimeoutException {
      return {'error': 'Server took too long to respond.', 'status': 408};
    } catch (e) {
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }

  static Future<Map<String, dynamic>> getWorkProjects() async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.studentWorkProjects}');
    final headers = await _authHeaders();

    try {
      final response = await http.get(url, headers: headers).timeout(_shortTimeout);
      if (response.statusCode == 200) return _decodeBody(response.body);

      return {
        'error': _errorMessage(_decodeBody(response.body), response.statusCode),
        'status': response.statusCode,
      };
    } on TimeoutException {
      return {'error': 'Server took too long to respond.', 'status': 408};
    } catch (e) {
      return {'error': 'Connection error: $e', 'status': 0};
    }
  }

  /// Submits work for a project (delivery link + note).
  static Future<Map<String, dynamic>> submitProjectWork(
      int projectId, Map<String, dynamic> data) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.studentWorkSubmit}$projectId/submit/');
    final headers = await _authHeaders();

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      ).timeout(_timeout);

      final body = _decodeBody(response.body);

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

  /// Updates a project's status (Not Started / In Progress / Completed).
  static Future<Map<String, dynamic>> updateProjectStatus(
      int projectId, String status) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.studentWorkUpdateStatus}$projectId/status/');
    final headers = await _authHeaders();

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'status': status}),
      ).timeout(_timeout);

      final body = _decodeBody(response.body);

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

  /// Fast parallel loader for work applications and projects.
  static Future<Map<String, dynamic>> loadWorkFast() async {
    final results = await Future.wait([
      getWorkApplications(),
      getWorkProjects(),
    ]);

    final any404 =
        results.any((r) => r.containsKey('error') && r['status'] == 404);

    if (any404) {
      return getWork();
    }

    return {
      'applications': results[0]['applications'] ?? [],
      'projects': results[1]['projects'] ?? [],
    };
  }
}
