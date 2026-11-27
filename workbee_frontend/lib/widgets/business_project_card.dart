import 'package:flutter/material.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/widgets/status_badge.dart';

/// Business's project card: shows project info, status badge, submission
/// details, Approve / Request Changes buttons, and a rating section.
/// Tapping the card shows student info in a bottom sheet.
class BusinessProjectCard extends StatelessWidget {
  final BusinessProject project;
  final bool canReview;
  final bool canRate;
  final VoidCallback onApprove;
  final VoidCallback onRequestChanges;
  final void Function(double rating, String comment) onSubmitRating;
  final VoidCallback onProjectTap;

  const BusinessProjectCard({
    super.key,
    required this.project,
    required this.canReview,
    required this.canRate,
    required this.onApprove,
    required this.onRequestChanges,
    required this.onSubmitRating,
    required this.onProjectTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = project;
    final isCompleted = p.status.toUpperCase() == 'COMPLETED' ||
        p.status.toUpperCase() == 'SUBMITTED';

    return GestureDetector(
      onTap: onProjectTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
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
                        p.gigTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${p.studentName} · NPR ${p.budgetNpr}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: p.status),
              ],
            ),
            const SizedBox(height: 10),
            if (p.deliverables.isNotEmpty) ...[
              const Text(
                'Deliverables',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: p.deliverables
                    .map(
                      (d) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.softBlueBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
            ],
            if (isCompleted && p.submissionLink.isNotEmpty) ...[
              const Text(
                'Project File (submitted by student)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    const Icon(
                      Icons.link,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        p.submissionLink,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryBlue,
                          decoration: TextDecoration.underline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            if (!isCompleted &&
                (p.submissionLink.isNotEmpty ||
                    p.submissionNote.isNotEmpty)) ...[
              if (p.submissionNote.isNotEmpty) ...[
                const Text(
                  'Submission note',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  p.submissionNote,
                  style: const TextStyle(fontSize: 13, color: AppColors.darkText),
                ),
                const SizedBox(height: 8),
              ],
              if (p.submissionLink.isNotEmpty) ...[
                const Text(
                  'Submission link',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      const Icon(
                        Icons.link,
                        size: 16,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          p.submissionLink,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryBlue,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ],
            if (canReview) ...[
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        onPressed: onApprove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Approve Work'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: OutlinedButton(
                        onPressed: onRequestChanges,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryBlue,
                          side: const BorderSide(color: AppColors.borderColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Request Changes'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
            if (canRate) ...[
              const Text(
                'Rate Student',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 8),
              _StarRating(
                onSubmitRating: (rating, comment) =>
                    onSubmitRating(rating, comment),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Simple 5-star rating selector. Calls onSubmitRating with (rating, comment).
class _StarRating extends StatefulWidget {
  final void Function(double rating, String comment) onSubmitRating;

  const _StarRating({required this.onSubmitRating});

  @override
  State<_StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<_StarRating> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    widget.onSubmitRating(_rating.toDouble(), _commentController.text.trim());
    setState(() => _isSubmitting = false);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (index) {
            final starValue = index + 1;
            return IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 34,
                minHeight: 34,
              ),
              onPressed: () => setState(() => _rating = starValue),
              icon: Icon(
                starValue <= _rating ? Icons.star : Icons.star_border,
                color: starValue <= _rating
                    ? const Color(0xFFF59E0B)
                    : AppColors.mutedText,
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _commentController,
          enabled: _rating > 0,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Write a short review...',
            filled: true,
            fillColor: AppColors.inputFill,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton(
            onPressed: _isSubmitting || _rating == 0 ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(width: 20, height: 20)
                : const Text('Submit Review'),
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet showing student info for a project.
class StudentInfoBottomSheet extends StatelessWidget {
  final BusinessProject project;

  const StudentInfoBottomSheet({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final p = project;
    final isCompleted = p.status.toUpperCase() == 'COMPLETED' ||
        p.status.toUpperCase() == 'SUBMITTED';

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
                      p.studentName.isNotEmpty ? p.studentName[0].toUpperCase() : 'S',
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
                          p.studentName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                        if (p.studentCollege.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            p.studentCollege,
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
                  _InfoChip(label: 'Rating', value: '${p.studentRating.toStringAsFixed(1)} / 5'),
                  const SizedBox(width: 8),
                  _InfoChip(label: 'Projects', value: p.verifiedProjectsCount.toString()),
                  if (p.studentSkills.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _InfoChip(label: 'Skills', value: p.studentSkills.join(', ')),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Project Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 8),
              _DetailRow(label: 'Gig', value: p.gigTitle),
              _DetailRow(label: 'Budget', value: 'NPR ${p.budgetNpr}'),
              _DetailRow(label: 'Deadline', value: p.deadline),
              _DetailRow(label: 'Status', value: p.status.replaceAll('_', ' ').toUpperCase()),
              if (p.deliverables.isNotEmpty)
                _DetailRow(label: 'Deliverables', value: p.deliverables.join(', ')),
              if (isCompleted && p.submissionLink.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Project File',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      const Icon(
                        Icons.description,
                        size: 18,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          p.submissionLink,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryBlue,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (p.submissionNote.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Submission Note',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  p.submissionNote,
                  style: const TextStyle(fontSize: 13, color: AppColors.darkText),
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
