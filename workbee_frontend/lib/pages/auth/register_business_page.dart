import 'package:flutter/material.dart';
import 'package:workbee_frontend/clients/auth_client.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/helpers/alert_helper.dart';
import 'package:workbee_frontend/pages/business/business_dashboard_page.dart';
import 'package:workbee_frontend/services/token_service.dart';

/// Business registration page. Collects business details and creates a business account.
class RegisterBusinessPage extends StatefulWidget {
  const RegisterBusinessPage({super.key});

  @override
  State<RegisterBusinessPage> createState() => _RegisterBusinessPageState();
}

class _RegisterBusinessPageState extends State<RegisterBusinessPage> {
  final _businessNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _panController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _contactPersonController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _panController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    showAlert(context, message: message, isError: isError);
  }

  Future<void> _handleCreateAccount() async {
    final businessName = _businessNameController.text.trim();
    final contactPerson = _contactPersonController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final location = _locationController.text.trim();
    final pan = _panController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (businessName.isEmpty ||
        contactPerson.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        location.isEmpty ||
        pan.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('Please fill in all fields.', isError: true);
      return;
    }

    if (pan.length != 9) {
      _showMessage('PAN number must be 9 digits.', isError: true);
      return;
    }

    if (password.length < 8) {
      _showMessage('Password must be at least 8 characters.', isError: true);
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Passwords do not match.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthClient.registerBusiness({
      'business_name': businessName,
      'contact_person': contactPerson,
      'email': email,
      'phone': phone,
      'location': location,
      'pan_number': pan,
      'password': password,
      'confirm_password': confirmPassword,
    });

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      // Save token and session so the user is logged in automatically
      final token = result['token'] as String?;
      if (token != null && token.isNotEmpty) {
        await AuthClient.saveToken(token);
        await TokenService.saveRole('business');
        final userData = result['data']?['user'];
        if (userData is Map) {
          await TokenService.saveUser(
            name: userData['full_name']?.toString() ?? '',
            id: userData['id']?.toString() ?? '',
            role: 'business',
          );
        }
      }

      _showMessage(result['message'] ?? 'Business account created successfully!');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const BusinessDashboardPage(),
        ),
      );
    } else {
      _showMessage(result['message'] ?? 'Registration failed.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.school_outlined,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'WorkBee',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.labelDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  const Text(
                    'Business Registration',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.labelDark,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _FormFieldItem(
                    label: 'Business name',
                    hint: 'Enter your business name',
                    controller: _businessNameController,
                  ),
                  const SizedBox(height: 16),

                  _FormFieldItem(
                    label: 'Contact person',
                    hint: "Enter contact person's name",
                    controller: _contactPersonController,
                  ),
                  const SizedBox(height: 16),

                  _FormFieldItem(
                    label: 'Email',
                    hint: 'Enter your business email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  _FormFieldItem(
                    label: 'Phone',
                    hint: '+977 98XXXXXXXXX',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  _FormFieldItem(
                    label: 'Location',
                    hint: 'e.g. Kathmandu, Nepal',
                    controller: _locationController,
                  ),
                  const SizedBox(height: 16),

                  _FormFieldItem(
                    label: 'PAN number',
                    hint: 'Enter your 9 digit PAN number',
                    controller: _panController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  _FormFieldItem(
                    label: 'Password',
                    hint: 'Create a password (min. 8 characters)',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.mutedText,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  _FormFieldItem(
                    label: 'Confirm password',
                    hint: 'Confirm your password',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.mutedText,
                      ),
                      onPressed: () {
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleCreateAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Create Business Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(fontSize: 14, color: AppColors.mutedText),
                      ),
                      GestureDetector(
                        onTap: _isLoading ? null : () => Navigator.pop(context),
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable form field item used on the business registration page.
class _FormFieldItem extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  const _FormFieldItem({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.labelDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.hintText),
            filled: true,
            fillColor: AppColors.inputFill,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
