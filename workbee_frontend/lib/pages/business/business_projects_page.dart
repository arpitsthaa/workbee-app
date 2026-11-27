import 'package:flutter/material.dart';
import 'package:workbee_frontend/clients/business_client.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/widgets/common_app_bar.dart';

class BusinessProjectsScreen extends StatefulWidget {
  final String businessName;
  final String location;
  final bool showNavBar;
  final bool showAppBar;
  final int initialTab; // 0 = Applicants, 1 = Projects

  const BusinessProjectsScreen({
    super.key,
    this.businessName = 'My Business',
    this.location = '',
    this.showNavBar = true,
    this.showAppBar = true,
    this.initialTab = 1,
  });

  @override
  State<BusinessProjectsScreen> createState() => _BusinessProjectsScreenState();
}

class _BusinessProjectsScreenState extends State<BusinessProjectsScreen> {
  static const _primaryBlue = AppColors.primaryBlue;
  static const _softBlueBg = AppColors.softBlueBg;
  static const _darkText = AppColors.darkText;
  static const _mutedText = AppColors.mutedText;
  static const _borderColor = AppColors.borderColor;
  static const _badgePending = AppColors.badgePending;
  static const _badgeRejected = AppColors.badgeRejected;
  static const _badgeShortlisted = AppColors.badgeShortlisted;

  List<BusinessProject> _projects = [];
  List<GigApplication> _applications = [];
  late int _activeTab; // 0 = Applicants, 1 = Projects
  bool _applicationsLoading = true;
  bool _projectsLoading = true;
  String? _applicationsError;
  String? _projectsError;
  int _selectedNavIndex = 2;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
    _loadApplications();
    _loadProjects();
  }

  Future<void> _loadApplications() async {
    setState(() {
      _applicationsLoading = true;
      _applicationsError = null;
    });

    try {
      final result = await BusinessClient.getApplications();

      if (!mounted) return;

      if (result.containsKey('error')) {
        setState(() {
          _applicationsError = result['error'] as String?;
          _applicationsLoading = false;
        });
        return;
      }

      final list = (result['applications'] as List<dynamic>?)
          ?.map((a) => GigApplication.fromJson(a as Map<String, dynamic>))
          .toList() ?? [];

      setState(() {
        _applications = list;
        _applicationsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _applicationsError = 'Connection error: $e';
        _applicationsLoading = false;
      });
    }
  }

  Future<void> _loadProjects() async {
    setState(() {
      _projectsLoading = true;
      _projectsError = null;
    });

    try {
      final result = await BusinessClient.getProjects();

      if (!mounted) return;

      if (result.containsKey('error')) {
        setState(() {
          _projectsError = result['error'] as String?;
          _projectsLoading = false;
        });
        return;
      }

      final list = (result['projects'] as List<dynamic>?)
          ?.map((p) => BusinessProject.fromJson(p as Map<String, dynamic>))
          .toList() ?? [];

      setState(() {
        _projects = list;
        _projectsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _projectsError = 'Connection error: $e';
        _projectsLoading = false;
      });
    }
  }

  Future<void> _approveProject(int projectId) async {
    final result = await BusinessClient.reviewProjectWork(projectId, 'approve');

    if (!mounted) return;

    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] as String? ?? 'Failed to approve'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _loadProjects();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Project approved'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  Future<void> _requestChanges(int projectId) async {
    final result = await BusinessClient.reviewProjectWork(
      projectId,
      'request_changes',
    );

    if (!mounted) return;

    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] as String? ?? 'Failed to request changes'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _loadProjects();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changes requested'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return AppColors.successGreenDark;
      case 'IN_PROGRESS':
        return _primaryBlue;
      case 'CHANGES_REQUESTED':
        return const Color(0xFFF59E0B);
      case 'PENDING':
        return _mutedText;
      default:
        return _mutedText;
    }
  }

  Color _statusBgColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return AppColors.badgeAccepted;
      case 'IN_PROGRESS':
        return _badgeShortlisted;
      case 'CHANGES_REQUESTED':
        return _badgePending;
      case 'PENDING':
        return _badgeRejected;
      default:
        return _badgePending;
    }
  }

  Widget _buildProjectCard(BusinessProject project) {
    final canReview =
        project.status.toUpperCase() == 'IN_PROGRESS' ||
        project.status.toUpperCase() == 'CHANGES_REQUESTED';
    final canRate =
        project.status.toUpperCase() == 'APPROVED' && !project.hasReview;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
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
                      project.gigTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${project.studentName} · NPR ${project.budgetNpr}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: _mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusBgColor(project.status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  project.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(project.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (project.deliverables.isNotEmpty) ...[
            const Text(
              'Deliverables',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _mutedText,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: project.deliverables
                  .map(
                    (d) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _softBlueBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        d,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: _primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
          ],
          if (project.submissionLink.isNotEmpty ||
              project.submissionNote.isNotEmpty) ...[
            if (project.submissionNote.isNotEmpty) ...[
              const Text(
                'Submission note',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _mutedText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                project.submissionNote,
                style: const TextStyle(
                  fontSize: 13,
                  color: _darkText,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (project.submissionLink.isNotEmpty) ...[
              const Text(
                'Submission link',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _mutedText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                project.submissionLink,
                style: const TextStyle(
                  fontSize: 13,
                  color: _primaryBlue,
                  decoration: TextDecoration.underline,
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
                      onPressed: () => _approveProject(project.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
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
                      onPressed: () => _requestChanges(project.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primaryBlue,
                        side: const BorderSide(color: _borderColor),
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
                color: _darkText,
              ),
            ),
            const SizedBox(height: 8),
            _RatingSection(
              projectId: project.id,
              onRated: _loadProjects,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProjectsSkeleton() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderColor),
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
                        Container(
                          height: 16,
                          width: 180,
                          decoration: BoxDecoration(
                            color: _softBlueBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 13,
                          width: 140,
                          decoration: BoxDecoration(
                            color: _softBlueBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _softBlueBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Container(
                      width: 80,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _softBlueBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _softBlueBg,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: _softBlueBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: _softBlueBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState({
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.assignment_outlined,
            size: 64,
            color: _mutedText,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: _mutedText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsSkeleton() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _softBlueBg,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 15,
                          width: 120,
                          decoration: BoxDecoration(
                            color: _softBlueBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 12.5,
                          width: 200,
                          decoration: BoxDecoration(
                            color: _softBlueBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 12.5,
                          width: 150,
                          decoration: BoxDecoration(
                            color: _softBlueBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildApplicationsErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.errorRed, size: 48),
          const SizedBox(height: 16),
          Text(
            'Failed to load applicants',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _applicationsError ?? 'Something went wrong',
            style: TextStyle(color: _mutedText, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _loadApplications,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(GigApplication app) {
    final canUpdate = app.status.toUpperCase() == 'PENDING' ||
        app.status.toUpperCase() == 'SHORTLISTED';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
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
                      app.studentName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${app.gigTitle} · Applied ${app.appliedAt.isNotEmpty ? app.appliedAt : 'recently'}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: _mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _badgeColor(app.status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  app.status.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _darkText,
                  ),
                ),
              ),
            ],
          ),
          if (canUpdate) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _updateApplicationStatus(app.id, 'accepted'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _updateApplicationStatus(app.id, 'rejected'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Reject',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _badgeColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return _badgePending;
      case 'SHORTLISTED':
        return _badgeShortlisted;
      case 'ACCEPTED':
        return AppColors.badgeAccepted;
      case 'REJECTED':
        return _badgeRejected;
      default:
        return _borderColor;
    }
  }

  Future<void> _updateApplicationStatus(int applicationId, String status) async {
    final result = await BusinessClient.updateApplicationStatus(applicationId, status);
    if (!mounted) return;
    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] as String? ?? 'Failed to update status'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }
    _loadApplications();
    _loadProjects();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Application $status'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.errorRed, size: 48),
          const SizedBox(height: 16),
          Text(
            'Failed to load projects',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _projectsError ?? 'Something went wrong',
            style: TextStyle(color: _mutedText, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _loadProjects,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.showAppBar
          ? CommonAppBar(
              displayName: widget.businessName,
              role: 'business',
              onAvatarTap: () {},
            )
          : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Segment tabs: Applicants | Projects
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
                          child: GestureDetector(
                            onTap: () => setState(() => _activeTab = 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _activeTab == 0
                                    ? AppColors.softBlueBg
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Applicants',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: _activeTab == 0
                                      ? _primaryBlue
                                      : _mutedText,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _activeTab = 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _activeTab == 1
                                    ? AppColors.softBlueBg
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Projects',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: _activeTab == 1
                                      ? _primaryBlue
                                      : _mutedText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _activeTab == 0
                        ? _loadApplications
                        : _loadProjects,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_activeTab == 0) ...[
                            if (_applicationsLoading && _applications.isEmpty)
                              _buildApplicationsSkeleton()
                            else if (_applicationsError != null &&
                                _applications.isEmpty)
                              _buildApplicationsErrorState()
                            else if (_applications.isEmpty)
                              _buildEmptyState(
                                title: 'No applicants yet.',
                                subtitle:
                                    'Students will appear here when they apply to your gigs.',
                              )
                            else
                              ..._applications.map(_buildApplicationCard),
                          ] else ...[
                            if (_projectsLoading && _projects.isEmpty)
                              _buildProjectsSkeleton()
                            else if (_projectsError != null &&
                                _projects.isEmpty)
                              _buildErrorState()
                            else if (_projects.isEmpty)
                              _buildEmptyState(
                                title: 'No projects yet.',
                                subtitle:
                                    'Once you accept an applicant, a project will appear here.',
                              )
                            else
                              Column(
                                children: _projects.map(_buildProjectCard).toList(),
                              ),
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
      bottomNavigationBar: widget.showNavBar
          ? SafeArea(
              top: false,
              child: Container(
                height: 68,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: _borderColor, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    _BottomNavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: 'Home',
                      selected: _selectedNavIndex == 0,
                      onTap: () => setState(() => _selectedNavIndex = 0),
                    ),
                    _BottomNavItem(
                      icon: Icons.work_outline_rounded,
                      activeIcon: Icons.work_rounded,
                      label: 'Gigs',
                      selected: _selectedNavIndex == 1,
                      onTap: () => setState(() => _selectedNavIndex = 1),
                    ),
                    _BottomNavItem(
                      icon: Icons.assignment_outlined,
                      activeIcon: Icons.assignment_rounded,
                      label: 'Projects',
                      selected: _selectedNavIndex == 2,
                      onTap: () => setState(() => _selectedNavIndex = 2),
                    ),
                    _BottomNavItem(
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: 'Profile',
                      selected: _selectedNavIndex == 3,
                      onTap: () => setState(() => _selectedNavIndex = 3),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class _RatingSection extends StatefulWidget {
  final int projectId;
  final VoidCallback onRated;

  const _RatingSection({
    required this.projectId,
    required this.onRated,
  });

  @override
  State<_RatingSection> createState() => _RatingSectionState();
}

class _RatingSectionState extends State<_RatingSection> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
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

    // Use BusinessClient.rateStudentProject via a static callback is not
    // available here; instead we call it through a global key pattern is
    // overkill. We expose submission through the parent by calling the
    // client directly since BusinessClient is a static class.
    try {
      final result = await BusinessClient.rateStudentProject(
        widget.projectId,
        {'rating': _rating, 'review_comment': _commentController.text.trim()},
      );

      if (!mounted) return;

      if (result.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] as String? ?? 'Failed to submit'),
            backgroundColor: AppColors.errorRed,
          ),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      _commentController.clear();
      setState(() => _isSubmitting = false);
      widget.onRated();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection error'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
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
            decoration: InputDecoration(
              hintText: 'Write a short review...',
              filled: true,
              fillColor: AppColors.inputFill,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
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
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                    )
                  : const Text('Submit Review'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const blue = AppColors.primaryBlue;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 32,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFEFF6FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Icon(
                selected ? activeIcon : icon,
                size: 22,
                color: selected ? blue : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? blue : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
