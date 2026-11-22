import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class LoginController extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;
  String? errorMessage;
  UserModel? currentUser;

  static const String _loginUrl = 'https://workbee-app.onrender.com/api/users/login/';

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
      final response = await http
          .post(
        Uri.parse(_loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      )
          .timeout(const Duration(seconds: 45));

      final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode == 200 || response.statusCode == 201) {
        currentUser = UserModel.fromJson(data);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', currentUser!.token);
        await prefs.setString('user_role', currentUser!.role);

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
      errorMessage = 'Connection failed. Make sure the backend is running on localhost:8000.';
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
