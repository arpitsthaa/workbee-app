import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_registration_model.dart';
import '../services/auth_service.dart';

class StudentRegistrationController extends ChangeNotifier {
  final AuthService _authService;

  StudentRegistrationController({AuthService? authService})
      : _authService = authService ?? AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? validateInputs({
    required String fullName,
    required String email,
    required String password,
    required String college,
  }) {
    if (fullName.trim().isEmpty) {
      return 'Please enter your full name.';
    }
    if (email.trim().isEmpty || !email.contains('@')) {
      return 'Please enter a valid email address.';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    if (college.trim().isEmpty) {
      return 'Please enter your college or university.';
    }
    return null;
  }

  Future<bool> registerAndLoginStudent({
    required String fullName,
    required String email,
    required String password,
    required String college,
  }) async {
    _errorMessage = null;

    final validationError = validateInputs(
      fullName: fullName,
      email: email,
      password: password,
      college: college,
    );

    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final request = StudentRegistrationRequest(
      fullName: fullName.trim(),
      email: email.trim(),
      password: password,
      collegeUniversity: college.trim(),
    );

    final response = await _authService.registerStudent(request);

    if (response.success && response.token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response.token!);
      if (response.userData != null) {
        await prefs.setString('user_data', jsonEncode(response.userData));
      }
    } else if (!response.success) {
      _errorMessage = response.message;
    }

    _isLoading = false;
    notifyListeners();

    return response.success && response.token != null;
  }
}