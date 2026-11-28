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
  bool _sortByRating = false;

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

  List<GigApplication> get _visibleApplications => _applications
      .where((a) {
        final s = a.status.toUpperCase();
        return s != 'ACCEPTED' && s != 'REJECTED';
      })
      .toList();
  List<BusinessProject> get _visibleProjects => _projects
      .where((p) {
        final s = p.status.toUpperCase();
        if (s == 'COMPLETED') return false;
        if (s == 'APPROVED' && p.hasReview) return false;
        return true;
      })
      .toList();

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
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           if (_activeTab == 0) ...[
                             Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 const Text(
                                   'Application updates',
                                   style: TextStyle(
                                     fontSize: 16,
                                     fontWeight: FontWeight.w700,
                                     color: AppColors.darkText,
                                   ),
                                 ),
                                 GestureDetector(
                                   onTap: () => setState(() => _sortByRating = !_sortByRating),
                                   child: Container(
                                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                     decoration: BoxDecoration(
                                       color: _sortByRating ? AppColors.softBlueBg : Colors.transparent,
                                       borderRadius: BorderRadius.circular(8),
                                       border: Border.all(color: AppColors.borderColor),
                                     ),
                                     child: Text(
                                       'Sort by rating',
                                       style: TextStyle(
                                         fontSize: 12.5,
                                         fontWeight: FontWeight.w600,
                                         color: _sortByRating ? AppColors.primaryBlue : AppColors.mutedText,
                                       ),
                                     ),
                                   ),
                                 ),
                               ],
                             ),
                             const SizedBox(height: 12),
                             Builder(
                               builder: (context) {
                                 final apps = [..._visibleApplications];
                                 if (_sortByRating) {
                                   apps.sort((a, b) => b.studentRating.compareTo(a.studentRating));
                                 }
                                 if (_applicationsLoading && apps.isEmpty) {
                                   return const SizedBox(
                                     height: 200,
                                     child: Center(child: CircularProgressIndicator()),
                                   );
                                 }
                                 if (_applicationsError != null && apps.isEmpty) {
                                   return _ErrorText(_applicationsError ?? 'Something went wrong');
                                 }
                                 if (apps.isEmpty) {
                                   return const _EmptyStateCard(
                                     title: 'No applicants yet.',
                                     subtitle:
                                         'Share your gigs to start receiving applications.',
                                   );
                                 }
                                 return Column(
                                   children: apps.map((app) {
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
                                   }).toList(),
                                 );
                               },
                             ),
                          ] else ...[
                           if (_projectsLoading && _visibleProjects.isEmpty)
                               const SizedBox(
                                 height: 200,
                                 child: Center(child: CircularProgressIndicator()),
                               )
                             else if (_projectsError != null &&
                                 _visibleProjects.isEmpty)
                               _ErrorText(_projectsError ?? 'Something went wrong')
                             else if (_visibleProjects.isEmpty)
                               const _EmptyStateCard(
                                 title: 'No projects yet.',
                                 subtitle:
                                     'Approve an applicant to start your first project.',
                               )
                             else
                               ..._visibleProjects.map((project) {
                                 final canReview =
                                     (project.status.toUpperCase() == 'SUBMITTED' ||
                                         project.status.toUpperCase() == 'COMPLETED') &&
                                     project.submissionLink.isNotEmpty;
                                 final canRate =
                                     (project.status.toUpperCase() == 'SUBMITTED' ||
                                         project.status.toUpperCase() == 'COMPLETED' ||
                                         project.status.toUpperCase() == 'APPROVED') &&
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
      bottomNavigationBar: widget.showNavBar ? _buildBottomNav() : null,
    );
  }

  Widget _buildBottomNav() {
    const blue = AppColors.primaryBlue;
    const muted = AppColors.mutedText;
    return BottomNavigationBar(
      currentIndex: _selectedNavIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: blue,
      unselectedItemColor: muted,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      onTap: (i) => setState(() => _selectedNavIndex = i),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.work_outline_rounded),
          activeIcon: Icon(Icons.work_rounded),
          label: 'Gigs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment_rounded),
          label: 'Projects',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
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

/// Card-style empty state matching the gigs page design.
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
