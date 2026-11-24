import 'package:flutter/material.dart';
import 'package:workbee_frontend/constants/app_colors.dart';

class GigCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String payText;
  final String metaText;
  final bool highlightMeta;
  final VoidCallback onTap;

  const GigCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.payText,
    required this.metaText,
    required this.highlightMeta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.mutedText,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  payText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
                Text(
                  metaText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: highlightMeta ? FontWeight.w600 : FontWeight.w400,
                    color: highlightMeta ? AppColors.primaryBlue : AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
