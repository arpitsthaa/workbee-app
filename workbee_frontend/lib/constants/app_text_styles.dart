import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Greeting: 28 / w800 (student dashboard "Hi, Name!")
  static const TextStyle greeting = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.darkText,
  );

  // Section heading: 16 / w700 (repeated across screens)
  static const TextStyle sectionHeading16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.darkText,
  );

  // Section heading: 18 / w700 (repeated across screens)
  static const TextStyle sectionHeading18 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.darkText,
  );

  // Section heading: 20 / w700 (profile name)
  static const TextStyle sectionHeading20 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.darkText,
  );

  // Subtitle / muted: 13 / regular
  static const TextStyle subtitle13 = TextStyle(
    fontSize: 13,
    color: AppColors.mutedText,
  );

  // Subtitle / muted: 14 / regular
  static const TextStyle subtitle14 = TextStyle(
    fontSize: 14,
    color: AppColors.mutedText,
  );

  // Label: 14 / w600 (input labels)
  static const TextStyle label14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.labelDark,
  );

  // Label: 14 / w600 register (input labels on register screens)
  static const TextStyle label14Register = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.labelRegister,
  );

  // Button text: 16 / w600 (primary buttons)
  static const TextStyle button16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Button text: 15 / w600
  static const TextStyle button15 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Body small: 13.5 / regular (muted details)
  static const TextStyle body135 = TextStyle(
    fontSize: 13.5,
    color: AppColors.mutedText,
  );

  // Small caption: 12 / regular
  static const TextStyle caption12 = TextStyle(
    fontSize: 12,
    color: AppColors.mutedText,
  );

  // Link / action text: 14 / w600 / primaryBlue
  static const TextStyle action14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryBlue,
  );

  // Primary blue large text: 18 / w800 (budget in details sheet)
  static const TextStyle primaryLarge18 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryBlue,
  );
}
