import 'package:flutter/material.dart';
import 'package:workbee_frontend/constants/app_colors.dart';

/// Primary brand button used across screens.
///
/// Keeps the exact visual of the existing inline `ElevatedButton`:
/// `primaryBlue` background, white foreground, no elevation, rounded radius 12.
/// The `isLoading` flag swaps the child for a loading indicator and disables
/// the tap target — matching the pattern already used in login/register screens.
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double height;
  final double fontSize;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.height = 52,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          disabledBackgroundColor: AppColors.primaryBlue.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
