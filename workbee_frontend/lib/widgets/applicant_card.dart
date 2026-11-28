import 'package:flutter/material.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/format_utils.dart';
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
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.softBlueBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryBlue, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    app.studentName.isNotEmpty ? app.studentName[0].toUpperCase() : 'S',
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.school, size: 12, color: AppColors.mutedText),
                          const SizedBox(width: 6),
                          Text(
                            '${app.gigTitle} · Applied ${formatDateDmy(app.appliedAt)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.mutedText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
    final skills = app.studentSkills.where((s) => s.isNotEmpty).toList();
    final hasCover = app.coverMessage.isNotEmpty;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: avatar + name + college
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.softBlueBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryBlue, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      app.studentName.isNotEmpty ? app.studentName[0].toUpperCase() : 'S',
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.studentName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                        if (app.studentCollege.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.school, size: 14, color: AppColors.mutedText),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  app.studentCollege,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.mutedText,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Quick info chips
               Wrap(
                 spacing: 8,
                 runSpacing: 8,
                 children: [
                   _InfoChip(label: 'Rating', value: '${app.studentRating.toStringAsFixed(1)} / 5'),
                   _InfoChip(label: 'Projects', value: app.verifiedProjectsCount.toString()),
                   if (skills.isNotEmpty)
                     _InfoChip(label: 'Skills', value: skills.join(', ')),
                 ],
               ),
              const SizedBox(height: 20),

              // Application details section
              Row(
                children: [
                  const Icon(Icons.description, size: 18, color: AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    'Application Details',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _DetailRow(label: 'Gig', value: app.gigTitle),
              _DetailRow(
                label: 'Status',
                value: app.status.replaceAll('_', ' ').toUpperCase(),
              ),
              _DetailRow(label: 'Applied', value: app.appliedAt),
              const SizedBox(height: 20),

              // Cover message
              if (hasCover) ...[
                const Text(
                  'Cover Message',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.softBlueBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    app.coverMessage,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 16),
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
