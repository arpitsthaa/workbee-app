import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Shows a consistent success or error message at the bottom of the screen.
///
/// Beginners: call `showAlert(context, 'Saved!')` or
/// `showAlert(context, 'Something went wrong', isError: true)`
/// instead of writing ScaffoldMessenger + SnackBar everywhere.
void showAlert(
  BuildContext context, {
  required String message,
  bool isError = false,
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppColors.errorRedDark : AppColors.successGreenDark,
      duration: duration,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
