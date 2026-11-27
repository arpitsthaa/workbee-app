import 'package:flutter/material.dart';
import 'package:workbee_frontend/clients/student_client.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/format_utils.dart';
import 'package:workbee_frontend/helpers/alert_helper.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/services/token_service.dart';
import 'package:workbee_frontend/widgets/error_retry_state.dart';
import 'package:workbee_frontend/widgets/loading_state.dart';

/// My Work page showing the student's applications and projects.
///
/// Has two tabs: Applications (gigs the student has applied to) and
/// Projects (gigs the student is currently working on).
/// Submit work form appears only when a project is tapped.
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

  Future<void> refresh() async {
    await _loadWork();
  }

  Future<void> _withdrawApplication(GigApplication app) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Application?'),
        content: Text('Are you sure you want to withdraw your application for "${app.gigTitle}"?'),
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

  Color _badgeColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return const Color(0xFFFEF3C7);
      case 'SHORTLISTED':
        return const Color(0xFFFEF3C7);
      case 'ACCEPTED':
        return const Color(0xFFD1FAE5);
      case 'REJECTED':
        return const Color(0xFFFEE2E2);
      default:
        return AppColors.borderColor;
    }
  }

  Color _getProjectStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'NOT_STARTED':
        return AppColors.mutedText;
      case 'IN_PROGRESS':
        return AppColors.primaryBlue;
      case 'COMPLETED':
        return AppColors.successGreen;
      case 'SUBMITTED':
        return const Color(0xFFF59E0B);
      case 'APPROVED':
        return const Color(0xFF10B981);
      default:
        return AppColors.mutedText;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'recently';
    return dateStr;
  }

  Future<void> _handleSubmitWork() async {
    final link = _linkController.text.trim();
    if (link.isEmpty) {
      showAlert(context, message: 'Please paste a Canva or Google Drive link first.', isError: true);
      return;
    }
    if (_selectedProjectId == null) return;

    setState(() => _submittingProjectId = _selectedProjectId);

    final result = await StudentClient.submitProjectWork(
      _selectedProjectId!,
      {
        'submission_link': link,
        'submission_note': _noteController.text.trim(),
      },
    );

    if (!mounted) return;

    if (result.containsKey('error')) {
      setState(() => _submittingProjectId = null);
      showAlert(context, message: result['error'] as String? ?? 'Failed to submit work', isError: true);
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _badgeColor(app.status),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Text(
                          app.status.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.labelDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                  _ProfileInfoRow(label: 'Name', value: app.studentName),
                  _ProfileInfoRow(label: 'College', value: app.studentCollege),
                  _ProfileInfoRow(label: 'Skills', value: app.studentSkills.join(', ')),
                  _ProfileInfoRow(label: 'Rating', value: app.studentRating.toString()),
                  _ProfileInfoRow(
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
                    child: _SegmentTab(
                      label: 'Applications',
                      selected: _activeTab == 0,
                      onTap: () {
                        setState(() => _activeTab = 0);
                        _loadWork();
                      },
                    ),
                  ),
                  Expanded(
                    child: _SegmentTab(
                      label: 'Projects',
                      selected: _activeTab == 1,
                      onTap: () {
                        setState(() => _activeTab = 1);
                        _loadWork();
                      },
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
                          _EmptyState(
                            icon: Icons.assignment_outlined,
                            title: 'No applications yet.',
                            subtitle: 'Browse gigs and apply to get started.',
                          )
                        else
                          ..._applications.map((app) {
                            final canWithdraw = app.status.toUpperCase() == 'PENDING' ||
                                app.status.toUpperCase() == 'SHORTLISTED';
                            return Column(
                              children: [
                                _SimpleItemCard(
                                  title: app.gigTitle,
                                  subtitle:
                                      '${app.businessName} · Applied ${_formatDate(app.appliedAt)}',
                                  badgeText: app.status.toUpperCase(),
                                  badgeBg: _badgeColor(app.status),
                                  badgeColor: const Color(0xFF1E293B),
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
                                              icon: const Icon(Icons.delete_outline,
                                                  size: 20, color: AppColors.errorRed),
                                              onPressed: () => _withdrawApplication(app),
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
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedProjectId = project.id;
                                    });
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFEFF6FF)
                                          : AppColors.softBlueBg,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primaryBlue
                                            : const Color(0xFFBFDBFE),
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
                                                project.gigTitle,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.darkText,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _getProjectStatusColor(project.status).withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: _getProjectStatusColor(project.status),
                                                ),
                                              ),
                                              child: Text(
                                                project.status.replaceAll('_', ' ').toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: _getProjectStatusColor(project.status),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${project.businessName} · Due ${project.deadline}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.mutedText,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          '${formatNpr(project.budgetNpr)} · ${project.deliverables.join(', ')}',
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryBlue,
                                          ),
                                        ),
                                        if (project.submissionLink.isNotEmpty) ...[
                                          const SizedBox(height: 10),
                                          Text(
                                            'Submitted: ${project.submissionLink}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.mutedText,
                                            ),
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
                                                  value: project.status,
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
                                                    DropdownMenuItem(
                                                      value: 'SUBMITTED',
                                                      child: Text('Submitted'),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: 'APPROVED',
                                                      child: Text('Approved'),
                                                    ),
                                                  ],
                                                onChanged: (newStatus) async {
                                                  if (newStatus == null) return;
                                                  final result = await StudentClient.updateProjectStatus(
                                                    project.id,
                                                    newStatus,
                                                  );
                                                  if (!mounted) return;
                                                  if (result.containsKey('error')) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          result['error'] ??
                                                              'Failed to update status',
                                                        ),
                                                        backgroundColor: AppColors.errorRed,
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Status updated to ${newStatus.toLowerCase()}'),
                                                      backgroundColor: AppColors.successGreen,
                                                    ),
                                                  );
                                                  await _loadWork();
                                                },
                                                decoration: InputDecoration(
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
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
                                          Text(
                                            'Paste your delivery link below.',
                                            style: TextStyle(fontSize: 13, color: AppColors.mutedText),
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: _linkController,
                                            decoration: InputDecoration(
                                              hintText: 'Paste Canva or Google Drive link',
                                              hintStyle: const TextStyle(color: AppColors.hintText),
                                              prefixIcon: const Icon(
                                                Icons.link,
                                                color: AppColors.mutedText,
                                                size: 20,
                                              ),
                                              filled: true,
                                              fillColor: AppColors.inputFill,
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 14,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: const BorderSide(color: AppColors.borderColor),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                  color: AppColors.primaryBlue,
                                                  width: 1.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: _noteController,
                                            maxLines: 2,
                                            decoration: InputDecoration(
                                              hintText: 'Add a short note (optional)',
                                              hintStyle: const TextStyle(color: AppColors.hintText),
                                              filled: true,
                                              fillColor: AppColors.inputFill,
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 12,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: const BorderSide(color: AppColors.borderColor),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                  color: AppColors.primaryBlue,
                                                  width: 1.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            width: double.infinity,
                                            height: 48,
                                            child: ElevatedButton(
                                              onPressed: _submittingProjectId == project.id
                                                  ? null
                                                  : _handleSubmitWork,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primaryBlue,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: _submittingProjectId == project.id
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

/// Empty state widget (used only by my work page).
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.mutedText),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.mutedText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Segment tab widget (used only by my work page).
class _SegmentTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentTab({
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

/// Simple item card widget (used only by my work page).
class _SimpleItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badgeText;
  final Color badgeBg;
  final Color badgeColor;
  final VoidCallback? onTap;
  final Widget? trailingAction;

  const _SimpleItemCard({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeBg,
    required this.badgeColor,
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
                color: badgeBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: badgeColor,
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
}

/// Profile info row widget (used only by my work page).
class _ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileInfoRow({required this.label, required this.value});

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
