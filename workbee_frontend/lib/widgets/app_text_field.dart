import 'package:flutter/material.dart';
import 'package:workbee_frontend/constants/app_colors.dart';

/// A reusable text input field used across login and registration screens.
///
/// Combines a label + TextField with standard WorkBee styling:
/// filled background, rounded border, primary blue focus border.
///
/// Beginners: use this instead of writing the same InputDecoration + TextField
/// combo repeatedly. It keeps every input looking identical across the app.
class WorkBeeTextField extends StatelessWidget {
  /// The label shown above the field (e.g. "Email", "Password").
  final String label;

  /// The placeholder text shown inside the empty field (e.g. "Enter your email").
  final String hint;

  /// The controller that holds the text the user types.
  final TextEditingController controller;

  /// Whether the text is hidden (used for password fields).
  final bool obscureText;

  /// The keyboard type (email, phone, number, plain text).
  final TextInputType keyboardType;

  /// Optional icon on the right side of the field (e.g. visibility toggle).
  final Widget? suffixIcon;

  /// Optional action when the user presses "done/next" on the keyboard.
  final TextInputAction? textInputAction;

  /// Whether words should be auto-capitalized.
  final TextCapitalization textCapitalization;

  const WorkBeeTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field label (e.g. "Email")
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.labelDark,
          ),
        ),
        const SizedBox(height: 8),

        // The actual text input
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
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
