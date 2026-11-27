import 'package:flutter/material.dart';
import 'package:workbee_frontend/constants/app_colors.dart';

/// Simple colored badge for a status string (e.g. NOT_STARTED, IN_PROGRESS,
/// COMPLETED, PENDING, ACCEPTED, REJECTED, APPROVED, SUBMITTED).
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color _color(String s) {
    switch (s.toUpperCase()) {
      case 'NOT_STARTED':
        return AppColors.mutedText;
      case 'IN_PROGRESS':
        return AppColors.primaryBlue;
      case 'COMPLETED':
        return AppColors.successGreen;
      case 'SUBMITTED':
        return const Color(0xFFF59E0B);
      case 'APPROVED':
        return AppColors.successGreenDark;
      case 'PENDING':
        return const Color(0xFFF59E0B); // bright amber
      case 'SHORTLISTED':
        return const Color(0xFFF59E0B); // bright amber
      case 'ACCEPTED':
        return const Color(0xFF10B981); // bright green
      case 'REJECTED':
        return const Color(0xFFEF4444); // bright red
      case 'CHANGES_REQUESTED':
        return const Color(0xFFF59E0B);
      default:
        return AppColors.borderColor;
    }
  }

  Color _bgColor(String s) {
    final c = _color(s);
    return c.withValues(alpha: 0.25);
  }

  @override
  Widget build(BuildContext context) {
    final s = status.toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _bgColor(s),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color(s)),
      ),
      child: Text(
        s.replaceAll('_', ' '),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _color(s),
        ),
      ),
    );
  }
}
