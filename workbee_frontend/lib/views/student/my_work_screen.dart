import 'package:flutter/material.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/format_utils.dart';
import 'package:workbee_frontend/services/auth_service.dart';
import 'package:workbee_frontend/services/user_session_service.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/widgets/segment_tab.dart';
import 'package:workbee_frontend/widgets/simple_item_card.dart';
import 'package:workbee_frontend/widgets/profile_info_row.dart';

class MyWorkScreen extends StatefulWidget {
  const MyWorkScreen({super.key});

  @override
  State<MyWorkScreen> createState() => MyWorkScreenState();
}

class MyWorkScreenState extends State<MyWorkScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  int _activeTab = 0;
  bool _applicationsLoading = true;
  bool _projectsLoading = true;
  int? _withdrawingAppId;
  String? _error;
  List<GigApplication> _applications = <GigApplication>[];
  List<Project> _projects = <Project>[];

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
    final result = await _authService.loadWorkFast();

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

    final result = await _authService.withdrawApplication(app.id);

    if (!mounted) return;

    setState(() => _withdrawingAppId = null);

    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] as String? ?? 'Failed to withdraw'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      UserSessionService().markWithdrawn(app.gig);
      await _loadWork();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application withdrawn'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: (_applicationsLoading && _projectsLoading)
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListenableBuilder(
                listenable: UserSessionService(),
                builder: (context, _) {
                  return Row(
                    children: [
                      Expanded(
                        child: SegmentTab(
                          label: 'Applications (${UserSessionService().appliedGigIds.length})',
                          selected: _activeTab == 0,
                          onTap: () {
                            setState(() => _activeTab = 0);
                            _loadWork();
                          },
                        ),
                      ),
                      Expanded(
                        child: SegmentTab(
                          label: 'Projects (${_projects.length})',
                          selected: _activeTab == 1,
                          onTap: () {
                            setState(() => _activeTab = 1);
                            _loadWork();
                          },
                        ),
                      ),
                    ],
                  );
                },
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
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.assignment_outlined,
                                size: 48,
                                color: Color(0xFFCBD5E1),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No applications yet.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkText,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Browse gigs and apply to get started.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.mutedText,
                                ),
                              ),
                            ],
                          )
                        else
                          ..._applications.map((app) {
                            final canWithdraw = app.status.toUpperCase() == 'PENDING' || app.status.toUpperCase() == 'SHORTLISTED';
                            return Column(
                              children: [
                                SimpleItemCard(
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
                                              icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.errorRed),
                                              onPressed: () => _withdrawApplication(app),
                                              tooltip: 'Withdraw application',
                                            )
                                      : null,
                                ),
                                const SizedBox(height: 12),
                              ],
                            );
                          }).toList(),
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
                            return Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.softBlueBg,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFBFDBFE)),
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
                                          Text(
                                            project.status.replaceAll('_', ' ').toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primaryBlue,
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
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),
                              ],
                            );
                          }).toList(),
                          const SizedBox(height: 22),
                          const Text(
                            'Submit work',
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
                              onPressed: _handleSubmitWork,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
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

Color _badgeColor(String status) {
  switch (status.toUpperCase()) {
    case 'PENDING':
      return AppColors.badgePending;
    case 'SHORTLISTED':
      return AppColors.badgeShortlisted;
    case 'ACCEPTED':
      return AppColors.badgeAccepted;
    case 'REJECTED':
      return AppColors.badgeRejected;
    default:
      return AppColors.borderColor;
  }
}

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'recently';
    return dateStr;
  }

  void _handleSubmitWork() {
    final link = _linkController.text.trim();
    if (link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please paste a Canva or Google Drive link first.'),
        ),
      );
      return;
    }
    _linkController.clear();
    _noteController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Work submitted for review!'),
      ),
    );
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
                      style: const TextStyle(
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
                  ProfileInfoRow(label: 'Name', value: app.studentName),
                  ProfileInfoRow(label: 'College', value: app.studentCollege),
                  ProfileInfoRow(label: 'Skills', value: app.studentSkills.join(', ')),
                  ProfileInfoRow(label: 'Rating', value: app.studentRating.toString()),
                  ProfileInfoRow(
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
}