import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/format_utils.dart';
import 'package:workbee_frontend/models/api_models.dart';

class ProjectDetailsPage extends StatefulWidget {
  final Project project;
  final ValueChanged<String> onStatusChanged;
  final Future<void> Function(String link, String note) onSubmitWork;
  final bool isSubmitting;

  const ProjectDetailsPage({
    super.key,
    required this.project,
    required this.onStatusChanged,
    required this.onSubmitWork,
    this.isSubmitting = false,
  });

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  late String _status;
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _status = widget.project.status.toUpperCase();
    if (!['NOT_STARTED', 'IN_PROGRESS', 'COMPLETED'].contains(_status)) {
      _status = 'NOT_STARTED';
    }
    if (widget.project.submissionLink.isNotEmpty) {
      _linkController.text = widget.project.submissionLink;
      _noteController.text = widget.project.submissionNote;
    }
  }

  @override
  void dispose() {
    _linkController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        title: const Text('Project Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.gigTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                p.businessName,
                style: const TextStyle(fontSize: 14, color: AppColors.mutedText),
              ),
              const SizedBox(height: 12),
              Text(
                '${formatNpr(p.budgetNpr)} · Due ${formatDateDmy(p.deadline)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
              if (p.proposalLink.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Business Proposal',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.proposalLink,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryBlue,
                          decoration: TextDecoration.underline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: p.proposalLink));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link copied')),
                        );
                      },
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'Status',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _status,
                items: const [
                  DropdownMenuItem(value: 'NOT_STARTED', child: Text('Not Started')),
                  DropdownMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')),
                  DropdownMenuItem(value: 'COMPLETED', child: Text('Completed')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _status = v);
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    if (_status == 'COMPLETED' &&
                        _linkController.text.trim().isEmpty &&
                        widget.project.submissionLink.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please submit a link before completing.',
                          ),
                        ),
                      );
                      return;
                    }
                    widget.onStatusChanged(_status);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Status'),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Submit Work',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _linkController,
                decoration: const InputDecoration(
                  hintText: 'Paste Canva or Google Drive link',
                  prefixIcon: Icon(Icons.link),
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
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: widget.isSubmitting
                      ? null
                      : () => widget.onSubmitWork(
                            _linkController.text.trim(),
                            _noteController.text.trim(),
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
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
                      : const Text('Submit for approval'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
