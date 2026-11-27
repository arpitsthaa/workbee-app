import 'package:flutter/material.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/widgets/status_badge.dart';

/// Business's applicant card: shows student info, status badge, and
/// Accept / Reject buttons (shown only when the application is PENDING or
/// SHORTLISTED).
/// Tapping the whole card shows student info in a bottom sheet.
class ApplicantCard extends StatelessWidget {
  final GigApplication app;
  final bool canUpdate;
  final ValueChanged<String> onUpdateStatus;
  final bool isUpdating;
  final VoidCallback onApplicantTap;

  const ApplicantCard({
    super.key,
    required this.app,
    required this.canUpdate,
    required this.onUpdateStatus,
    this.isUpdating = false,
    required this.onApplicantTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onApplicantTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.studentName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${app.gigTitle} · Applied ${app.appliedAt}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: app.status),
              ],
            ),
            if (canUpdate) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isUpdating ? null : () => onUpdateStatus('accepted'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isUpdating ? null : () => onUpdateStatus('rejected'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.errorRed,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Reject',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet showing student info for an applicant.
class ApplicantInfoBottomSheet extends StatelessWidget {
  final GigApplication app;

  const ApplicantInfoBottomSheet({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: AppColors.softBlueBg,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      app.studentName.isNotEmpty ? app.studentName[0].toUpperCase() : 'S',
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.studentName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                        if (app.studentCollege.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            app.studentCollege,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.mutedText,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _InfoChip(label: 'Rating', value: '${app.studentRating.toStringAsFixed(1)} / 5'),
                  const SizedBox(width: 8),
                  _InfoChip(label: 'Projects', value: app.verifiedProjectsCount.toString()),
                  if (app.studentSkills.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _InfoChip(label: 'Skills', value: app.studentSkills.join(', ')),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Application Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 8),
              _DetailRow(label: 'Gig', value: app.gigTitle),
              _DetailRow(label: 'Status', value: app.status.replaceAll('_', ' ').toUpperCase()),
              _DetailRow(label: 'Applied', value: app.appliedAt),
              if (app.coverMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Cover Message',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  app.coverMessage,
                  style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.mutedText),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small info chip showing a label and value.
class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.softBlueBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Detail row with label and value.
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.mutedText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
