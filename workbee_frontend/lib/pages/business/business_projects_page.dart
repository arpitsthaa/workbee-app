import 'package:flutter/material.dart';
import 'package:workbee_frontend/clients/business_client.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/widgets/applicant_card.dart';
import 'package:workbee_frontend/widgets/business_project_card.dart';
import 'package:workbee_frontend/widgets/common_app_bar.dart';

class BusinessProjectsScreen extends StatefulWidget {
  final String businessName;
  final String location;
  final bool showNavBar;
  final bool showAppBar;
  final int initialTab; // 0 = Applicants, 1 = Projects
  final ValueNotifier<int>? tabNotifier;

  const BusinessProjectsScreen({
    super.key,
    this.businessName = 'My Business',
    this.location = '',
    this.showNavBar = true,
    this.showAppBar = true,
    this.initialTab = 0,
    this.tabNotifier,
  });

  @override
  State<BusinessProjectsScreen> createState() => _BusinessProjectsScreenState();
}

class _BusinessProjectsScreenState extends State<BusinessProjectsScreen> {
  List<BusinessProject> _projects = [];
  List<GigApplication> _applications = [];
  late int _activeTab;
  bool _applicationsLoading = true;
  bool _projectsLoading = true;
  String? _applicationsError;
  String? _projectsError;
  int _selectedNavIndex = 2;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
    widget.tabNotifier?.addListener(_onTabNotifierChanged);
    _loadApplications();
    _loadProjects();
  }

  void _onTabNotifierChanged() {
    if (!mounted) return;
    final newTab = widget.tabNotifier?.value ?? _activeTab;
    if (newTab != _activeTab) {
      setState(() => _activeTab = newTab);
    }
  }

  @override
  void dispose() {
    widget.tabNotifier?.removeListener(_onTabNotifierChanged);
    super.dispose();
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

    _loadProjects();

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

    _loadProjects();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changes requested'),
        backgroundColor: AppColors.successGreen,
      ),
    );
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

  Future<void> _submitRating(int projectId, double rating, String comment) async {
    final result = await BusinessClient.rateStudentProject(
      projectId,
      {'rating': rating.toInt(), 'review_comment': comment},
    );

    if (!mounted) return;

    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] as String? ?? 'Failed to submit rating'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    _loadProjects();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Review submitted'),
        backgroundColor: AppColors.successGreen,
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
                            label: 'Applicants',
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
                    onRefresh: _activeTab == 0
                        ? _loadApplications
                        : _loadProjects,
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
                            if (_applicationsLoading && _applications.isEmpty)
                              const SizedBox(
                                height: 200,
                                child: Center(child: CircularProgressIndicator()),
                              )
                            else if (_applicationsError != null &&
                                _applications.isEmpty)
                              _ErrorText(_applicationsError ?? 'Something went wrong')
                            else if (_applications.isEmpty)
                              const Text(
                                'No applicants yet.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.mutedText,
                                ),
                              )
                            else
                              ..._applications.map((app) {
                                final canUpdate =
                                    app.status.toUpperCase() == 'PENDING' ||
                                        app.status.toUpperCase() == 'SHORTLISTED';
                                return Column(
                                  children: [
                                    ApplicantCard(
                                      app: app,
                                      canUpdate: canUpdate,
                                      onUpdateStatus: (status) =>
                                          _updateApplicationStatus(app.id, status),
                                      isUpdating: false,
                                      onApplicantTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.white,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20),
                                            ),
                                          ),
                                          builder: (context) =>
                                              ApplicantInfoBottomSheet(
                                            app: app,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                );
                              }),
                          ] else ...[
                            if (_projectsLoading && _projects.isEmpty)
                              const SizedBox(
                                height: 200,
                                child: Center(child: CircularProgressIndicator()),
                              )
                            else if (_projectsError != null &&
                                _projects.isEmpty)
                              _ErrorText(_projectsError ?? 'Something went wrong')
                            else if (_projects.isEmpty)
                              const Text(
                                'No projects yet.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.mutedText,
                                ),
                              )
                            else
                              ..._projects.map((project) {
                                final canReview =
                                    project.status.toUpperCase() == 'COMPLETED' &&
                                    project.submissionLink.isNotEmpty;
                                final canRate =
                                    project.status.toUpperCase() == 'APPROVED' &&
                                        !project.hasReview;
                                return Column(
                                  children: [
                                    BusinessProjectCard(
                                      project: project,
                                      canReview: canReview,
                                      canRate: canRate,
                                      onApprove: () => _approveProject(project.id),
                                      onRequestChanges: () =>
                                          _requestChanges(project.id),
                                      onSubmitRating: (rating, comment) =>
                                          _submitRating(
                                            project.id,
                                            rating,
                                            comment,
                                          ),
                                      onProjectTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.white,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20),
                                            ),
                                          ),
                                          builder: (context) =>
                                              StudentInfoBottomSheet(
                                            project: project,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                );
                              }),
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
                    top: BorderSide(color: AppColors.borderColor, width: 1),
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

/// Simple tab button for Applicants / Projects.
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

/// Simple error text widget.
class _ErrorText extends StatelessWidget {
  final String message;

  const _ErrorText(this.message);

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.mutedText,
      ),
    );
  }
}

/// Bottom navigation item.
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
