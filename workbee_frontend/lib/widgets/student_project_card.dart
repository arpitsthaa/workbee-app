import 'package:flutter/material.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/format_utils.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/widgets/status_badge.dart';

/// Student's project card: shows project info, status dropdown (3 options)
/// with a Save button, and the submit-work form (link + note + submit button).
class StudentProjectCard extends StatefulWidget {
  final Project project;
  final bool isSelected;
  final VoidCallback onSelect;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onSave;
  final VoidCallback onSubmitWork;
  final bool isSubmitting;
  final String? selectedStatus;

  const StudentProjectCard({
    super.key,
    required this.project,
    required this.isSelected,
    required this.onSelect,
    required this.onStatusChanged,
    required this.onSave,
    required this.onSubmitWork,
    this.isSubmitting = false,
    this.selectedStatus,
  });

  @override
  State<StudentProjectCard> createState() => _StudentProjectCardState();
}

class _StudentProjectCardState extends State<StudentProjectCard> {
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _linkController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _dropdownValue(String projectStatus, String? selected) {
    if (selected != null &&
        ['NOT_STARTED', 'IN_PROGRESS', 'COMPLETED'].contains(selected)) {
      return selected;
    }
    if (['NOT_STARTED', 'IN_PROGRESS', 'COMPLETED'].contains(projectStatus)) {
      return projectStatus;
    }
    return 'NOT_STARTED';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final isSelected = widget.isSelected;
    final dropdownValue = _dropdownValue(p.status, widget.selectedStatus);

    return GestureDetector(
      onTap: widget.onSelect,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : AppColors.softBlueBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : const Color(0xFFBFDBFE),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    p.gigTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                StatusBadge(status: p.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${p.businessName} · Due ${formatDateDmy(p.deadline)}',
              style: const TextStyle(fontSize: 13, color: AppColors.mutedText),
            ),
            const SizedBox(height: 10),
            Text(
              '${formatNpr(p.budgetNpr)} · ${p.deliverables.join(', ')}',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
            if (p.proposalLink.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.description, size: 16, color: AppColors.primaryBlue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      p.proposalLink,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
            if (p.submissionLink.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Submitted: ${p.submissionLink}',
                style: const TextStyle(fontSize: 13, color: AppColors.mutedText),
              ),
            ],
            if (isSelected) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Status:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: dropdownValue,
                      items: const [
                        DropdownMenuItem(
                          value: 'NOT_STARTED',
                          child: Text('Not Started'),
                        ),
                        DropdownMenuItem(
                          value: 'IN_PROGRESS',
                          child: Text('In Progress'),
                        ),
                        DropdownMenuItem(
                          value: 'COMPLETED',
                          child: Text('Completed'),
                        ),
                      ],
                      onChanged: (newStatus) {
                        if (newStatus != null) {
                          widget.onStatusChanged(newStatus);
                        }
                      },
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: widget.onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Submit Work',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Paste your delivery link below.',
                style: TextStyle(fontSize: 13, color: AppColors.mutedText),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _linkController,
                decoration: const InputDecoration(
                  hintText: 'Paste Canva or Google Drive link',
                  prefixIcon: Icon(Icons.link, size: 20),
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Add a short note (optional)',
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: widget.isSubmitting ? null : widget.onSubmitWork,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: widget.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit for approval',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
