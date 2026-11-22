import 'package:flutter/material.dart';

class BusinessRegistrationScreen extends StatefulWidget {
  const BusinessRegistrationScreen({super.key});

  @override
  State<BusinessRegistrationScreen> createState() =>
      _BusinessRegistrationScreenState();
}

class _BusinessRegistrationScreenState
    extends State<BusinessRegistrationScreen> {
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _handleCreateAccount() {
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
      _showMessage('Please fill in all fields.');
      return;
    }

    if (pan.length != 9) {
      _showMessage('PAN number must be 9 digits.');
      return;
    }

    if (password.length < 8) {
      _showMessage('Password must be at least 8 characters.');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Passwords do not match.');
      return;
    }

    // TODO: Connect your backend registration API here
    _showMessage('Business account created for $businessName!');
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const darkText = Color(0xFF1E293B);
    const subtitleText = Color(0xFF64748B);

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
                  // Brand Header
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: primaryBlue,
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
                          color: darkText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Page Title
                  const Text(
                    'Business Registration',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: darkText,
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
                    hint: 'Enter your 9-digit PAN number',
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
                        color: subtitleText,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  _FormFieldItem(
                    label: 'Confirm password',
                    hint: 'Re-enter your password',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: subtitleText,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _handleCreateAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Create Business Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Back to Login Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(fontSize: 14, color: subtitleText),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primaryBlue,
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

// ---------------------------------------------------------------------------
// REUSABLE FORM FIELD WIDGET
// ---------------------------------------------------------------------------

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
              vertical: 15,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF1D61E7),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}