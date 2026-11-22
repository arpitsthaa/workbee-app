import 'package:flutter/material.dart';
import '../controller/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = LoginController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final success = await _controller.login();
    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.errorMessage ?? 'Login failed')),
      );
      return;
    }

    final user = _controller.currentUser!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged in as ${user.email}')),
    );

    if (user.role == 'business') {
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BusinessDashboardPage()));
    } else {
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StudentGigsPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const darkText = Color(0xFF1E293B);
    const subtitleText = Color(0xFF64748B);
    const beeGold = Color(0xFFF59E0B);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Logo
                  Image.asset(
                    'assets/workbee_logo.png',
                    height: 44,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 36),

                  // Title & Subtitle
                  const Text(
                    'Welcome back',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bee Busy Be Paid\nConnect with opportunities across Nepal.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: subtitleText,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Reusable Email Input
                  _WorkBeeInput(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  // Reusable Password Input
                  _WorkBeeInput(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _controller.passwordController,
                    obscureText: _controller.obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _controller.obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: subtitleText,
                      ),
                      onPressed: _controller.togglePassword,
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
                          color: primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Log In Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _controller.isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _controller.isLoading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Log in',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Registration Options
                  const Center(
                    child: Text(
                      'New to WorkBee? Register as:',
                      style: TextStyle(fontSize: 14, color: subtitleText),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _RegistrationButton(
                    title: 'Student Registration',
                    borderColor: primaryBlue,
                    accentColor: beeGold,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),

                  _RegistrationButton(
                    title: 'Business Registration',
                    borderColor: primaryBlue,
                    accentColor: beeGold,
                    onTap: () {},
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// REUSABLE WIDGETS (Exact same as your original code)
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
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1D61E7), width: 1.5),
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

class _EmptyCard extends StatelessWidget {
  final double height;
  final Widget? child;

  const _EmptyCard({
    this.height = 100,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }
}