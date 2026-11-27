import 'package:flutter/material.dart';
import 'package:workbee_frontend/clients/business_client.dart';
import 'package:workbee_frontend/constants/app_colors.dart';

/// Page for posting a new gig.
class PostGigPage extends StatefulWidget {
  final String businessName;
  final String location;

  const PostGigPage({
    super.key,
    required this.businessName,
    required this.location,
  });

  @override
  State<PostGigPage> createState() => _PostGigPageState();
}

class _PostGigPageState extends State<PostGigPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _proposalLinkController = TextEditingController();

  bool _isPosting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _skillsController.dispose();
    _budgetController.dispose();
    _deadlineController.dispose();
    _locationController.dispose();
    _proposalLinkController.dispose();
    super.dispose();
  }

  List<String> _parseSkills(String raw) {
    return raw
        .split(RegExp(r'[·,]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  String? _formatDeadline(String raw) {
    final trimmed = raw.trim();
    final reg = RegExp(r'^(\d{1,2})[/-](\d{1,2})[/-](\d{4})$');
    final match = reg.firstMatch(trimmed);
    if (match == null) {
      final iso = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$');
      final isoMatch = iso.firstMatch(trimmed);
      if (isoMatch != null) return trimmed;
      return null;
    }
    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);
    if (day < 1 || day > 31 || month < 1 || month > 12) return null;
    return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _deadlineController.text =
            '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _postGig() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final skillsRaw = _skillsController.text.trim();
    final budgetRaw = _budgetController.text.trim().replaceAll(',', '');
    final deadlineRaw = _deadlineController.text.trim();
    final locationRaw = _locationController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a gig title.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a description.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }
    if (skillsRaw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter required skills.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }
    if (locationRaw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a location.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }
    if (budgetRaw.isEmpty || int.tryParse(budgetRaw) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid budget (NPR).'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }
    if (deadlineRaw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a deadline.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final deadline = _formatDeadline(deadlineRaw);
    if (deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid deadline date. Use YYYY-MM-DD.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      final result = await BusinessClient.postGig({
        'title': title,
        'description': description,
        'required_skills': _parseSkills(skillsRaw),
        'budget_npr': int.parse(budgetRaw),
        'duration_days': 7,
        'deadline': deadline,
        'location': locationRaw,
        'is_remote': true,
        'category': 'Design & creative',
        'deliverables': [],
        'proposal_link': _proposalLinkController.text.trim(),
      });

      if (!mounted) return;

      if (result.containsKey('error')) {
        setState(() => _isPosting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                result['error'] as String? ?? 'Failed to post gig'),
            backgroundColor: AppColors.errorRed,
          ),
        );
        return;
      }

      _titleController.clear();
      _descriptionController.clear();
      _skillsController.clear();
      _budgetController.clear();
      _deadlineController.clear();
      _locationController.clear();
      _proposalLinkController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gig posted successfully!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPosting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Post a Gig',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _FormField(
                    label: 'Gig title',
                    controller: _titleController,
                    hint: 'e.g. Logo Design for Cafe',
                  ),
                  const SizedBox(height: 12),

                  // Description (scrollable if long)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 90,
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: TextField(
                          controller: _descriptionController,
                          maxLines: null,
                          keyboardType: TextInputType.text,
                          style: const TextStyle(
                            fontSize: 14.5,
                            color: AppColors.darkText,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Describe what you need...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: AppColors.hintText,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _FormField(
                    label: 'Required skills',
                    controller: _skillsController,
                    hint: 'e.g. Canva, Figma, Illustrator',
                  ),
                  const SizedBox(height: 12),

                  _FormField(
                    label: 'Budget (NPR)',
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    hint: '0',
                  ),
                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: AppColors.mutedText,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Deadline',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.mutedText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _deadlineController.text.isEmpty
                                      ? 'Select a date'
                                      : _deadlineController.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _deadlineController.text.isEmpty
                                        ? AppColors.hintText
                                        : AppColors.darkText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            size: 22,
                            color: AppColors.mutedText,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _FormField(
                    label: 'Location',
                    controller: _locationController,
                    hint: 'e.g. Baneshwor, Kathmandu',
                  ),
                  const SizedBox(height: 12),

                  _FormField(
                    label: 'Proposal / Document link',
                    controller: _proposalLinkController,
                    hint: 'e.g. https://docs.google.com/document/...',
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isPosting ? null : _postGig,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isPosting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Post Gig',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType keyboardType;
  final String hint;
  final bool enabled;

  const _FormField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.hint = '',
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.mutedText,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            enabled: enabled,
            style: TextStyle(
              fontSize: 14.5,
              color: enabled ? AppColors.darkText : AppColors.mutedText,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 14,
                color: AppColors.hintText,
              ),
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
