import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/format_utils.dart';
import 'package:workbee_frontend/helpers/alert_helper.dart';
import 'package:workbee_frontend/models/api_models.dart';

class ProjectDetailsPage extends StatefulWidget {
  final Project project;
  final Future<bool> Function(String status, {bool silent}) onStatusChanged;
  final Future<bool> Function(String link, String note) onSubmitWork;

  const ProjectDetailsPage({
    super.key,
    required this.project,
    required this.onStatusChanged,
    required this.onSubmitWork,
  });

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  static const List<String> _statuses = ['NOT_STARTED', 'IN_PROGRESS', 'COMPLETED'];

  late String _status;
  bool _busy = false;
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _status = widget.project.status.toUpperCase();
    if (!_statuses.contains(_status)) {
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

  String _prettyStatus(String s) {
    final text = s.toLowerCase().replaceAll('_', ' ');
    return text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
  }

  void _onStatusChanged(String? value) {
    if (value == null || value == _status) return;
    setState(() => _status = value);
  }

  Future<void> _onSave() async {
    setState(() => _busy = true);
    final ok = await widget.onStatusChanged(_status);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) Navigator.of(context).pop();
  }

  Future<void> _onSaveAndSubmit() async {
    final link = _linkController.text.trim();
    if (link.isEmpty) {
      showAlert(
        context,
        message: 'Please paste a Canva or Google Drive link first.',
        isError: true,
      );
      return;
    }
    setState(() => _busy = true);
    final statusOk = await widget.onStatusChanged(_status, silent: true);
    final submitOk =
        await widget.onSubmitWork(link, _noteController.text.trim());
    if (!mounted) return;
    setState(() => _busy = false);
    if (statusOk && submitOk) Navigator.of(context).pop();
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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
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
              const SizedBox(height: 10),
              Text(
                '${formatNpr(p.budgetNpr)} · Due ${formatDateDmy(p.deadline)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
              if (p.description.isNotEmpty) ...[
                const SizedBox(height: 16),
                _SectionLabel('Description'),
                const SizedBox(height: 6),
                Text(
                  p.description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.darkText,
                  ),
                ),
              ],
              if (p.deliverables.isNotEmpty) ...[
                const SizedBox(height: 16),
                _SectionLabel('Deliverables'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: p.deliverables
                      .map(
                        (d) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.softBlueBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            d,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              if (p.proposalLink.isNotEmpty) ...[
                const SizedBox(height: 16),
                _SectionLabel('Business Proposal'),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: p.proposalLink),
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copied')),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy Proposal Link'),
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
              const SizedBox(height: 24),
              _SectionLabel('Status'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _status,
                      items: _statuses
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(_prettyStatus(s)),
                            ),
                          )
                          .toList(),
                      onChanged: _onStatusChanged,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  if (_status != 'COMPLETED') ...[
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _busy ? null : _onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _busy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save'),
                      ),
                    ),
                  ],
                ],
              ),
              if (_status == 'COMPLETED') ...[
                const SizedBox(height: 24),
                _SectionLabel('Submit Work'),
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
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _onSaveAndSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save & Submit'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.darkText,
      ),
    );
  }
}