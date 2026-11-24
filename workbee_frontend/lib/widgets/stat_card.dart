import 'package:flutter/material.dart';
import 'package:workbee_frontend/constants/app_colors.dart';

class StatCard extends StatelessWidget {
  final String countText;
  final String subtitleText;
  final Color borderColor;
  final VoidCallback onTap;

  const StatCard({
    super.key,
    required this.countText,
    required this.subtitleText,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              countText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitleText,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
