import 'package:flutter/material.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/format_utils.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/widgets/status_badge.dart';
import 'package:url_launcher/url_launcher.dart';

/// Business's project card: shows project info, status badge, submission
/// details, Approve / Request Changes buttons, and a rating section.
/// Tapping the card shows student info in a bottom sheet.
class BusinessProjectCard extends StatelessWidget {
  final BusinessProject project;
  final bool canReview;
  final bool canRate;
  final VoidCallback onRequestChanges;
  final void Function(double rating, String comment) onSubmitRating;
  final VoidCallback onProjectTap;

  const BusinessProjectCard({
    super.key,
    required this.project,
    required this.canReview,
    required this.canRate,
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
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
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
                    p.studentName.isNotEmpty ? p.studentName[0].toUpperCase() : 'S',
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              p.gigTitle,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(status: p.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          Text(
                            'NPR ${p.budgetNpr}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.schedule, size: 13, color: AppColors.mutedText),
                              const SizedBox(width: 6),
                              Text(
                                p.deadline.isNotEmpty
                                    ? 'Due ${formatDateDmy(p.deadline)}'
                                    : '—',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
              if (p.proposalLink.isNotEmpty) ...[
                const Text(
                  'Proposal / Document',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final url = Uri.parse(p.proposalLink);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.description, size: 16),
                    label: Text(
                      p.proposalLink,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
            ],
            if (isCompleted && p.submissionLink.isNotEmpty) ...[
              const Text(
                'Project File',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.description, size: 16),
                  label: Text(
                    p.submissionLink,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
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
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.link, size: 16),
                    label: Text(
                      p.submissionLink,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
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
              const SizedBox(height: 14),
            ],
            if (canReview) ...[
              SizedBox(
                width: double.infinity,
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
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.softBlueBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryBlue, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      p.studentName.isNotEmpty ? p.studentName[0].toUpperCase() : 'S',
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
                          p.studentName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                        if (p.studentCollege.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.school, size: 14, color: AppColors.mutedText),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  p.studentCollege,
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
               Wrap(
                 spacing: 8,
                 runSpacing: 8,
                 children: [
                   _InfoChip(label: 'Rating', value: '${p.studentRating.toStringAsFixed(1)} / 5'),
                   _InfoChip(label: 'Projects', value: p.verifiedProjectsCount.toString()),
                   if (p.studentSkills.isNotEmpty)
                     _InfoChip(label: 'Skills', value: p.studentSkills.join(', ')),
                 ],
               ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.description, size: 18, color: AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    'Project Details',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.description, size: 16),
                    label: Text(
                      p.submissionLink,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.softBlueBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    p.submissionNote,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.darkText,
                    ),
                  ),
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
