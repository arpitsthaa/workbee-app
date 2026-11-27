import 'package:flutter/material.dart';
import 'package:workbee_frontend/clients/student_client.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/format_utils.dart';
import 'package:workbee_frontend/helpers/alert_helper.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/services/token_service.dart';
import 'package:workbee_frontend/widgets/error_retry_state.dart';
import 'package:workbee_frontend/widgets/loading_state.dart';
import 'package:workbee_frontend/widgets/student_project_card.dart';

/// My Work page showing the student's applications and projects.
///
/// Has two tabs: Applications (gigs the student has applied to) and
/// Projects (gigs the student is currently working on).
class MyWorkPage extends StatefulWidget {
  const MyWorkPage({super.key});

  @override
  State<MyWorkPage> createState() => MyWorkPageState();
}

class MyWorkPageState extends State<MyWorkPage> {
  int _activeTab = 0;
  bool _applicationsLoading = true;
  bool _projectsLoading = true;
  int? _withdrawingAppId;
  String? _error;
  List<GigApplication> _applications = <GigApplication>[];
  List<Project> _projects = <Project>[];
  int? _selectedProjectId;
  int? _submittingProjectId;
  final Map<int, String> _selectedStatuses = <int, String>{};

  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWork();
  }

  @override
  void dispose() {
    _linkController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadWork() async {
    final result = await StudentClient.loadWorkFast();

    if (!mounted) return;

    if (result.containsKey('error')) {
      setState(() {
        _error = result['error'] as String?;
        _applicationsLoading = false;
        _projectsLoading = false;
      });
      return;
    }

    setState(() {
      _applications = (result['applications'] as List<dynamic>?)
              ?.map((a) => GigApplication.fromJson(a as Map<String, dynamic>))
              .toList() ??
          <GigApplication>[];
      _projects = (result['projects'] as List<dynamic>?)
              ?.map((p) => Project.fromJson(p as Map<String, dynamic>))
              .toList() ?? <Project>[];
      _applicationsLoading = false;
      _projectsLoading = false;
    });
  }

  Future<void> _refreshWork() async {
    setState(() {
      _applications = <GigApplication>[];
      _projects = <Project>[];
      _applicationsLoading = true;
      _projectsLoading = true;
      _error = null;
    });
    await _loadWork();
  }

  /// Public refresh method used by the dashboard's global key.
  Future<void> refresh() async {
    await _loadWork();
  }

  Future<void> _withdrawApplication(GigApplication app) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Application?'),
        content: Text(
          'Are you sure you want to withdraw your application for "${app.gigTitle}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _withdrawingAppId = app.id);

    final result = await StudentClient.withdrawApplication(app.id);

    if (!mounted) return;

    setState(() => _withdrawingAppId = null);

    if (result.containsKey('error')) {
      showAlert(
        context,
        message: result['error'] as String? ?? 'Failed to withdraw',
        isError: true,
      );
    } else {
      await TokenService.markWithdrawn(app.gig);
      await _loadWork();
      if (!mounted) return;
      showAlert(context, message: 'Application withdrawn');
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'recently';
    return formatDateDmy(dateStr);
  }

  bool _canWithdraw(String status) {
    final s = status.toUpperCase();
    return s == 'PENDING' || s == 'SHORTLISTED';
  }

  Future<void> _handleSaveStatus(Project project, String newStatus) async {
    if (newStatus == project.status) return;

    final result = await StudentClient.updateProjectStatus(
      project.id,
      newStatus,
    );

    if (!mounted) return;

    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Failed to update status'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status updated to ${newStatus.toLowerCase()}'),
        backgroundColor: AppColors.successGreen,
      ),
    );
    _selectedStatuses.remove(project.id);
    await _loadWork();
  }

  Future<void> _handleSubmitWork(Project project) async {
    final link = _linkController.text.trim();
    if (link.isEmpty) {
      showAlert(
        context,
        message: 'Please paste a Canva or Google Drive link first.',
        isError: true,
      );
      return;
    }

    setState(() => _submittingProjectId = project.id);

    final result = await StudentClient.submitProjectWork(
      project.id,
      {
        'submission_link': link,
        'submission_note': _noteController.text.trim(),
      },
    );

    if (!mounted) return;

    if (result.containsKey('error')) {
      setState(() => _submittingProjectId = null);
      showAlert(
        context,
        message: result['error'] as String? ?? 'Failed to submit work',
        isError: true,
      );
      return;
    }

    _linkController.clear();
    _noteController.clear();
    setState(() {
      _submittingProjectId = null;
      _selectedProjectId = null;
    });
    await _loadWork();
    if (!mounted) return;
    showAlert(context, message: 'Work submitted for business approval!');
  }

  void _showApplicationDetails(GigApplication app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.businessName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    app.gigTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      Text(
                        'Applied ${_formatDate(app.appliedAt)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                  if (app.coverMessage.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Cover Message',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      app.coverMessage,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.labelRegister,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Your Profile',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Name', value: app.studentName),
                  _InfoRow(label: 'College', value: app.studentCollege),
                  _InfoRow(label: 'Skills', value: app.studentSkills.join(', ')),
                  _InfoRow(label: 'Rating', value: app.studentRating.toString()),
                  _InfoRow(
                    label: 'Verified Projects',
                    value: app.verifiedProjectsCount.toString(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_applicationsLoading && _projectsLoading) {
      return const LoadingState();
    }

    if (_error != null) {
      return ErrorRetryState(
        error: _error!,
        onRetry: _loadWork,
      );
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: 'Applications',
                      selected: _activeTab == 0,
                      onTap: () => setState(() => _activeTab = 0),
                    ),
                  ),
                  Expanded(
                    child: _TabButton(
                      label: 'Projects',
                      selected: _activeTab == 1,
                      onTap: () => setState(() => _activeTab = 1),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: RefreshIndicator(
                onRefresh: _refreshWork,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_activeTab == 0) ...[
                        const Text(
                          'Application updates',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_applications.isEmpty)
                          const Text(
                            'No applications yet.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.mutedText,
                            ),
                          )
                        else
                          ..._applications.map((app) {
                            final canWithdraw = _canWithdraw(app.status);
                            return Column(
                              children: [
                                _SimpleAppCard(
                                  title: app.gigTitle,
                                  subtitle:
                                      '${app.businessName} · Applied ${_formatDate(app.appliedAt)}',
                                  status: app.status,
                                  onTap: () => _showApplicationDetails(app),
                                  trailingAction: canWithdraw
                                      ? _withdrawingAppId == app.id
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  AppColors.errorRed,
                                                ),
                                              ),
                                            )
                                          : IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                size: 20,
                                                color: AppColors.errorRed,
                                              ),
                                              onPressed: () =>
                                                  _withdrawApplication(app),
                                              tooltip: 'Withdraw application',
                                            )
                                      : null,
                                ),
                                const SizedBox(height: 12),
                              ],
                            );
                          }),
                      ] else ...[
                        if (_projects.isEmpty)
                          const Text(
                            'No projects yet. Get shortlisted for a gig to start working!',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.mutedText,
                            ),
                          )
                        else ...[
                          const Text(
                            'Active projects',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._projects.map((project) {
                            final isSelected = _selectedProjectId == project.id;
                            final isSubmitting =
                                _submittingProjectId == project.id;
                            return Column(
                              children: [
                                StudentProjectCard(
                                  project: project,
                                  isSelected: isSelected,
                                  onSelect: () {
                                    setState(() {
                                      _selectedProjectId = project.id;
                                    });
                                  },
                                  onStatusChanged: (newStatus) {
                                    setState(() {
                                      _selectedStatuses[project.id] = newStatus;
                                    });
                                  },
                                  onSave: () {
                                    final newStatus =
                                        _selectedStatuses[project.id];
                                    if (newStatus != null) {
                                      _handleSaveStatus(project, newStatus);
                                    }
                                  },
                                  onSubmitWork: () =>
                                      _handleSubmitWork(project),
                                  isSubmitting: isSubmitting,
                                  selectedStatus: _selectedStatuses[project.id],
                                ),
                              ],
                            );
                          }),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple tab button for Applications / Projects.
class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.softBlueBg : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.primaryBlue : AppColors.mutedText,
          ),
        ),
      ),
    );
  }
}

/// Simple application item card for the Applications tab.
class _SimpleAppCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final VoidCallback? onTap;
  final Widget? trailingAction;

  const _SimpleAppCard({
    required this.title,
    required this.subtitle,
    required this.status,
    this.onTap,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _bgColor(status),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _color(status)),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _color(status),
                ),
              ),
            ),
            if (trailingAction != null) ...[
              const SizedBox(width: 8),
              trailingAction!,
            ],
          ],
        ),
      ),
    );
  }

  Color _color(String s) {
    switch (s.toUpperCase()) {
      case 'PENDING':
      case 'SHORTLISTED':
        return const Color(0xFFF59E0B); // bright amber
      case 'ACCEPTED':
        return const Color(0xFF10B981); // bright green
      case 'REJECTED':
        return const Color(0xFFEF4444); // bright red
      default:
        return AppColors.borderColor;
    }
  }

  Color _bgColor(String s) {
    final c = _color(s);
    return c.withValues(alpha: 0.2);
  }
}

/// Simple label/value row used in the application details sheet.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.mutedText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
