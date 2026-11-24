import 'package:flutter/material.dart';
import 'package:workbee_frontend/constants/app_colors.dart';

/// Card showing a single completed, verified project in the Career Passport.
///
/// Displays the gig title, business/location, role/skills, completion date,
/// rating, and feedback text with a "Verified" badge.
class VerifiedProjectCard extends StatelessWidget {
  final String title;
  final String businessAndLocation;
  final String roleAndSkills;
  final String dateText;
  final String ratingText;
  final String feedback;
  final Color borderColor;

  const VerifiedProjectCard({
    super.key,
    required this.title,
    required this.businessAndLocation,
    required this.roleAndSkills,
    required this.dateText,
    required this.ratingText,
    required this.feedback,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.softBlueBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 14, color: AppColors.primaryBlue),
                    SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            businessAndLocation,
            style: const TextStyle(fontSize: 13.5, color: AppColors.mutedText),
          ),
          const SizedBox(height: 6),
          Text(
            roleAndSkills,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.labelRegister,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: AppColors.beeGold,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ratingText,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
              Text(
                dateText,
                style: const TextStyle(fontSize: 12.5, color: AppColors.mutedText),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            feedback,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              fontStyle: FontStyle.italic,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}
