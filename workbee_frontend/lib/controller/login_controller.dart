import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/http_client.dart';
import '../models/user_model.dart';

class LoginController extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;
  String? errorMessage;
  UserModel? currentUser;

  static const String _loginUrl = '/api/users/login/';

  void togglePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  Future<bool> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      errorMessage = 'Please enter both email and password';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await HttpClient.post(
        _loginUrl,
        body: {'email': email, 'password': password},
      ).timeout(const Duration(seconds: 45));

      final data = response.body.isNotEmpty
          ? Map<String, dynamic>.from(jsonDecode(response.body))
          : <String, dynamic>{};

      if (response.statusCode == 200 || response.statusCode == 201) {
        currentUser = UserModel.fromJson(data);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', currentUser!.token);
        await prefs.setString('user_role', currentUser!.role);
        await HttpClient.setToken(currentUser!.token);

        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = data['detail'] ?? data['error'] ?? 'Invalid email or password';
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = 'Connection failed: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
