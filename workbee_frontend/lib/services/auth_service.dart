import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/business_registration_model.dart';
import '../models/student_registration_model.dart';

class AuthService {
  static const String _baseUrl = 'https://workbee-app.onrender.com/api/users';

  Future<StudentRegistrationResponse> registerStudent(
      StudentRegistrationRequest request,
      ) async {
    final url = Uri.parse('$_baseUrl/register/student/');

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
    final url = Uri.parse('$_baseUrl/register/business/');

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

      // Extracts the first field error returned by Django REST Framework
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
}

