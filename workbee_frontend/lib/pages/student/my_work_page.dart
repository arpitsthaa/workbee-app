import 'package:flutter/material.dart';
import 'package:workbee_frontend/clients/student_client.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/format_utils.dart';
import 'package:workbee_frontend/helpers/alert_helper.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/services/token_service.dart';
import 'package:workbee_frontend/pages/student/project_details_page.dart';
import 'package:workbee_frontend/widgets/student_project_card.dart';
import 'package:workbee_frontend/widgets/status_badge.dart';

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
      _projects = (result['projects'] as List<dynamic>? ?? const <dynamic>[])
              .map((p) => Project.fromJson(p as Map<String, dynamic>))
              .where((p) => !p.hasReview)
              .toList();
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

  Future<bool> _handleSaveStatus(
    Project project,
    String newStatus, {
    bool silent = false,
  }) async {
    if (newStatus == project.status) return true;

    final result = await StudentClient.updateProjectStatus(
      project.id,
      newStatus,
    );

    if (!mounted) return false;

    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Failed to update status'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return false;
    }

    if (!silent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${newStatus.toLowerCase()}'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
    await _loadWork();
    return true;
  }

  Future<bool> _handleSubmitWork(Project project) async {
    final link = _linkController.text.trim();
    if (link.isEmpty) {
      showAlert(
        context,
        message: 'Please paste a Canva or Google Drive link first.',
        isError: true,
      );
      return false;
    }

    final result = await StudentClient.submitProjectWork(
      project.id,
      {
        'submission_link': link,
        'submission_note': _noteController.text.trim(),
      },
    );

    if (!mounted) return false;

    if (result.containsKey('error')) {
      showAlert(
        context,
        message: result['error'] as String? ?? 'Failed to submit work',
        isError: true,
      );
      return false;
    }

    _linkController.clear();
    _noteController.clear();
    await _loadWork();
    if (!mounted) return true;
    showAlert(context, message: 'Work submitted for business approval!');
    return true;
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
                  Text(
                    'Applied ${_formatDate(app.appliedAt)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.mutedText,
                    ),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  child: RefreshIndicator(
                    onRefresh: _refreshWork,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
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
                            Builder(
                              builder: (context) {
                                final apps = _applications
                                    .where((a) =>
                                        a.status.toUpperCase() != 'ACCEPTED')
                                    .toList();
                                if (_applicationsLoading && apps.isEmpty) {
                                  return const SizedBox(
                                    height: 200,
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                                if (_error != null && apps.isEmpty) {
                                  return _InlineError(
                                    message: _error!,
                                    onRetry: _loadWork,
                                  );
                                }
                                if (apps.isEmpty) {
                                  return const _EmptyStateCard(
                                    title: 'No applications',
                                    subtitle:
                                        'Please apply for gigs to see the applications.',
                                  );
                                }
                                return Column(
                                  children: apps.map((app) {
                                    final canWithdraw = _canWithdraw(app.status);
                                    return Column(
                                      children: [
                                        _SimpleAppCard(
                                          title: app.gigTitle,
                                          subtitle:
                                              '${app.businessName} · Applied ${_formatDate(app.appliedAt)}',
                                          status: app.status,
                                          coverMessage: app.coverMessage,
                                          onTap: () => _showApplicationDetails(app),
                                          trailingAction: canWithdraw
                                              ? _withdrawingAppId == app.id
                                                  ? const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<Color>(
                                                          AppColors.errorRed,
                                                        ),
                                                      ),
                                                    )
                                                  : TextButton.icon(
                                                      onPressed: () =>
                                                          _withdrawApplication(app),
                                                      icon: const Icon(
                                                        Icons.delete_outline,
                                                        size: 16,
                                                        color: AppColors.errorRed,
                                                      ),
                                                      label: const Text(
                                                        'Withdraw',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          color: AppColors.errorRed,
                                                        ),
                                                      ),
                                                      style: TextButton.styleFrom(
                                                        foregroundColor:
                                                            AppColors.errorRed,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                      ),
                                                    )
                                              : null,
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ] else ...[
                            if (_projectsLoading && _projects.isEmpty)
                              const SizedBox(
                                height: 200,
                                child: Center(child: CircularProgressIndicator()),
                              )
                            else if (_error != null && _projects.isEmpty)
                              _InlineError(
                                message: _error!,
                                onRetry: _loadWork,
                              )
                            else if (_projects.isEmpty)
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
                                return Column(
                                  children: [
                                    StudentProjectCard(
                                      project: project,
                                      onSelect: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ProjectDetailsPage(
                                              project: project,
                                              onStatusChanged: (newStatus,
                                                  {bool silent = false}) {
                                                return _handleSaveStatus(
                                                  project,
                                                  newStatus,
                                                  silent: silent,
                                                );
                                              },
                                              onSubmitWork: (link, note) async {
                                                _linkController.text = link;
                                                _noteController.text = note;
                                                return _handleSubmitWork(project);
                                              },
                                            ),
                                          ),
                                        ).then((_) => _loadWork());
                                      },
                                    ),
                                    const SizedBox(height: 12),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyStateCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined,
              size: 56, color: AppColors.borderLight),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.mutedText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

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

class _SimpleAppCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final String? coverMessage;
  final VoidCallback? onTap;
  final Widget? trailingAction;

  const _SimpleAppCard({
    required this.title,
    required this.subtitle,
    required this.status,
    this.coverMessage,
    this.onTap,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
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
                color: Color(0x0F000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedText,
                ),
              ),
              if (coverMessage != null && coverMessage!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  coverMessage!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.labelRegister,
                  ),
                ),
              ],
              if (trailingAction != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: trailingAction!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

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

class _InlineError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _InlineError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 40, color: AppColors.errorRed),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.mutedText),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}