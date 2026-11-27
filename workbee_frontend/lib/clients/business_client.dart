import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../clients/auth_client.dart';

/// Handles business API requests: dashboard, gigs, profile, projects, applications.
class BusinessClient {
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

  /// Fetches the business dashboard data.
  static Future<Map<String, dynamic>> getDashboard() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.businessDashboard}');
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

  /// Fetches the business's gigs.
  static Future<Map<String, dynamic>> getGigs() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.businessGigs}');
    final headers = await _authHeaders();

    try {
      final response = await http.get(url, headers: headers).timeout(_timeout);
      final body = _decodeList(response.body);

      if (response.statusCode == 200) {
        return {'gigs': body};
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

  /// Posts a new gig.
  static Future<Map<String, dynamic>> postGig(Map<String, dynamic> data) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.businessGigs}');
    final headers = await _authHeaders();

    try {
      final response = await http
          .post(
        url,
        headers: headers,
        body: jsonEncode(data),
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

  /// Updates an existing gig.
  static Future<Map<String, dynamic>> updateGig(
      int gigId, Map<String, dynamic> data) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.businessGigById}$gigId/');
    final headers = await _authHeaders();

    try {
      final response = await http
          .patch(
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

  /// Deletes a gig.
  static Future<Map<String, dynamic>> deleteGig(int gigId) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.businessGigById}$gigId/');
    final headers = await _authHeaders();

    try {
      final response = await http.delete(url, headers: headers).timeout(_timeout);

      final body = _decodeBody(response.body);

      if (response.statusCode == 200 || response.statusCode == 204) {
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

  /// Fetches the business profile.
  static Future<Map<String, dynamic>> getProfile() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.businessProfile}');
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

  /// Updates the business profile.
  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.businessProfile}');
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

  /// Fetches the business's projects.
  static Future<Map<String, dynamic>> getProjects() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.businessProjects}');
    final headers = await _authHeaders();

    try {
      final response = await http.get(url, headers: headers).timeout(_timeout);
      final body = _decodeBody(response.body);

      if (response.statusCode == 200) {
        return {'projects': _decodeList(response.body)};
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

  /// Fetches the business's gig applications (applicants).
  static Future<Map<String, dynamic>> getApplications() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.businessApplicationsStatus}');
    final headers = await _authHeaders();

    try {
      final response = await http.get(url, headers: headers).timeout(_timeout);
      final body = _decodeBody(response.body);

      if (response.statusCode == 200) {
        return {'applications': _decodeList(response.body)};
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

  /// Updates an application's status (shortlisted / accepted / rejected).
  static Future<Map<String, dynamic>> updateApplicationStatus(
      int applicationId, String status) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.businessApplicationsStatus}$applicationId/status/');
    final headers = await _authHeaders();

    try {
      final response = await http
          .patch(
        url,
        headers: headers,
        body: jsonEncode({'status': status}),
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

  /// Approves or requests changes on a project.
  static Future<Map<String, dynamic>> reviewProjectWork(
      int projectId, String action) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.businessReviewWork}$projectId/review-work/');
    final headers = await _authHeaders();

    try {
      final response = await http
          .post(
        url,
        headers: headers,
        body: jsonEncode({'action': action}),
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

  /// Rates a student after project approval.
  static Future<Map<String, dynamic>> rateStudentProject(
      int projectId, Map<String, dynamic> data) async {
    final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.businessRateStudent}$projectId/rate/');
    final headers = await _authHeaders();

    try {
      final response = await http
          .post(
        url,
        headers: headers,
        body: jsonEncode(data),
      )
          .timeout(_timeout);

      final body = _decodeBody(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) return body;

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
