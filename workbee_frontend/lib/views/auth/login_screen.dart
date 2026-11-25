import 'package:flutter/material.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/controller/login_controller.dart';
import 'package:workbee_frontend/widgets/primary_button.dart';
import 'package:workbee_frontend/views/auth/register_student_screen.dart';
import 'package:workbee_frontend/views/auth/register_business_screen.dart';
import 'package:workbee_frontend/views/student/student_dashboard_screen.dart';
import 'package:workbee_frontend/views/business/business_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = LoginController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final success = await _controller.login();

    if (!mounted) return;

    if (success) {
      final role = _controller.currentUser?.role;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => role == 'business'
              ? const BusinessDashboardScreen()
              : const StudentDashboardScreen(),
        ),
      );
    } else if (_controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage!),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bigger, Cleaner Brand Header
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withOpacity(0.22),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.school_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'WorkBee',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.labelDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Title & Subtitle
                  const Text(
                    'Welcome back',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.labelDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bee Busy Be Paid\nConnect with opportunities across Nepal.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: AppColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email Input
                  _WorkBeeInput(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  // Password Input
                  _WorkBeeInput(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _controller.passwordController,
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

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Primary Log In Button
                  ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) {
                      return PrimaryButton(
                        text: 'Log in',
                        onPressed: _handleLogin,
                        isLoading: _controller.isLoading,
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // Registration Section
                  const Center(
                    child: Text(
                      'New to WorkBee? Register as:',
                      style:
                      TextStyle(fontSize: 14, color: AppColors.mutedText),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _RegistrationButton(
                    title: 'Student Registration',
                    borderColor: AppColors.primaryBlue,
                    accentColor: AppColors.beeGold,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const StudentRegistrationScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  _RegistrationButton(
                    title: 'Business Registration',
                    borderColor: AppColors.primaryBlue,
                    accentColor: AppColors.beeGold,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const BusinessRegistrationScreen(),
                        ),
                      );
                    },
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

// ---------------------------------------------------------------------------
// REUSABLE WIDGETS
// ---------------------------------------------------------------------------

class _WorkBeeInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  const _WorkBeeInput({
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
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: AppColors.primaryBlue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _RegistrationButton extends StatelessWidget {
  final String title;
  final Color borderColor;
  final Color accentColor;
  final VoidCallback onTap;

  const _RegistrationButton({
    required this.title,
    required this.borderColor,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Container(width: 6, height: double.infinity, color: accentColor),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: borderColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}