import 'package:flutter/material.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/format_utils.dart';
import 'package:workbee_frontend/services/auth_service.dart';
import 'package:workbee_frontend/services/user_session_service.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/widgets/gig_card.dart';
import 'package:workbee_frontend/widgets/stat_card.dart';
import 'package:workbee_frontend/widgets/student_app_bar.dart';
import 'package:workbee_frontend/widgets/dashboard_skeletons.dart';
import 'package:workbee_frontend/views/student/browse_gigs_screen.dart';
import 'package:workbee_frontend/views/student/my_work_screen.dart';
import 'package:workbee_frontend/views/student/passport_screen.dart';
import 'package:workbee_frontend/views/student/profile_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  final GlobalKey<MyWorkScreenState> _myWorkKey = GlobalKey();

  // Per-section dashboard data (loaded in parallel split calls)
  Map<String, dynamic>? _profile;
  List<Gig> _recommendedGigs = <Gig>[];
  Map<String, dynamic> _appsSummary = <String, dynamic>{};
  Map<String, dynamic> _projectsSummary = <String, dynamic>{};
  Map<String, dynamic> _careerPassport = <String, dynamic>{};

  // Per-section loading state
  bool _profileLoading = true;
  bool _gigsLoading = true;
  bool _summaryLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _authService.warmUp();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    await Future.wait([
      _fetchProfile(),
      _fetchGigs(),
      _fetchSummary(),
    ]);
  }

  Future<void> _fetchProfile() async {
    final result = await _authService.getDashboardProfile();
    if (!mounted) return;
    if (result.containsKey('error')) {
      setState(() => _profileLoading = false);
    } else {
      setState(() {
        _profile = result;
        _profileLoading = false;
      });
    }
  }

  Future<void> _fetchGigs() async {
    final result = await _authService.getDashboardGigs();
    if (!mounted) return;
    if (result.containsKey('error')) {
      final fallback = await _authService.getStudentDashboard();
      if (!mounted) return;
      if (fallback.containsKey('error')) {
        setState(() => _gigsLoading = false);
        return;
      }
      final list = (fallback['recommended_gigs'] as List<dynamic>?)
          ?.map((g) => Gig.fromJson(g as Map<String, dynamic>))
          .toList() ?? <Gig>[];
      setState(() {
        _recommendedGigs = list;
        _gigsLoading = false;
      });
    } else {
      final list = (result['recommended_gigs'] as List<dynamic>?)
          ?.map((g) => Gig.fromJson(g as Map<String, dynamic>))
          .toList() ?? <Gig>[];
      setState(() {
        _recommendedGigs = list;
        _gigsLoading = false;
      });
    }
  }

  Future<void> _fetchSummary() async {
    final result = await _authService.getDashboardSummary();
    if (!mounted) return;
    if (result.containsKey('error')) {
      setState(() => _summaryLoading = false);
    } else {
      setState(() {
        _appsSummary = result['applications_summary'] ?? <String, dynamic>{};
        _projectsSummary = result['projects_summary'] ?? <String, dynamic>{};
        _careerPassport = result['career_passport'] ?? <String, dynamic>{};
        _summaryLoading = false;
      });
    }
  }

  void _refreshDashboard() async {
    setState(() {
      _profile = null;
      _recommendedGigs = <Gig>[];
      _appsSummary = <String, dynamic>{};
      _projectsSummary = <String, dynamic>{};
      _careerPassport = <String, dynamic>{};
      _profileLoading = true;
      _gigsLoading = true;
      _summaryLoading = true;
      _error = null;
    });
    await _loadDashboard();
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 2) {
      _myWorkKey.currentState?.refresh();
    }
  }

  void _onAvatarTapped() {
    _onTabTapped(4);
  }

  List<Widget> _buildLatestGigWidgets(List<Gig> recommendedGigs) {
    if (_gigsLoading) {
      return [GigCardSkeletons()];
    }
    return recommendedGigs.map((gig) {
      return Column(
        children: [
          GigCard(
            title: gig.title,
            subtitle: '${gig.businessName} · ${gig.location}',
            payText: formatNpr(gig.budgetNpr),
            metaText: '${gig.durationDays} days · ${gig.deadline}',
            highlightMeta: false,
            onTap: () => _onTabTapped(1),
          ),
          const SizedBox(height: 12),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeBody(),
          _ScreenWithAppBar(
            body: BrowseGigsScreen(
              onAppliedNavigate: () {
                _onTabTapped(2);
                _myWorkKey.currentState?.refresh();
              },
            ),
            onAvatarTap: _onAvatarTapped,
          ),
          _ScreenWithAppBar(
            body: MyWorkScreen(key: _myWorkKey),
            onAvatarTap: _onAvatarTapped,
          ),
          _ScreenWithAppBar(
            body: const PassportScreen(),
            onAvatarTap: _onAvatarTapped,
          ),
          _ScreenWithAppBar(
            body: const ProfileScreen(),
            onAvatarTap: _onAvatarTapped,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.mutedText,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Gigs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'My work',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_outlined),
            activeIcon: Icon(Icons.verified),
            label: 'Passport',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeBody() {
    final isVerified = _profile?['is_verified'] ?? false;
    final recommendedGigs = _recommendedGigs;
    final appsSummary = _appsSummary;
    final projectsSummary = _projectsSummary;

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadDashboard, child: const Text('Retry')),
          ],
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          StudentAppBar(onAvatarTap: _onAvatarTapped),
          const SizedBox(height: 24),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListenableBuilder(
                      listenable: UserSessionService(),
                      builder: (context, _) {
                        final studentName = UserSessionService().userName ?? 'Student';
                        return RichText(
                          text: TextSpan(
                            text: 'Hi, ',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkText,
                            ),
                            children: [
                              TextSpan(
                                text: studentName,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkText,
                                ),
                              ),
                              const TextSpan(
                                text: '!',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkText,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your next opportunity starts here.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _profileLoading
                        ? VerifiedBadgeSkeleton()
                        : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.softBlueBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: AppColors.primaryBlue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Student verified',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isVerified ? AppColors.primaryBlue : AppColors.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Latest gigs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _onTabTapped(1),
                          child: const Row(
                            children: [
                              Text(
                                'View all',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: AppColors.primaryBlue,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ..._buildLatestGigWidgets(recommendedGigs.take(3).toList()),
                    const SizedBox(height: 18),
                    _summaryLoading
                        ? StatCardSkeletons()
                        : Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  countText:
                                      '${appsSummary['total'] ?? 0} applications',
                                  subtitleText:
                                      '${appsSummary['pending'] ?? 0} pending · ${appsSummary['shortlisted'] ?? 0} shortlisted',
                                  borderColor: AppColors.borderColor,
                                  onTap: () => _onTabTapped(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  countText:
                                      '${projectsSummary['total'] ?? 0} projects',
                                  subtitleText:
                                      '${projectsSummary['active'] ?? 0} active · ${projectsSummary['approved'] ?? 0} approved',
                                  borderColor: AppColors.borderColor,
                                  onTap: () => _onTabTapped(2),
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 16),
                    InkWell(
                        onTap: () => _onTabTapped(3),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.softBlueBg,
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: AppColors.primaryBlue, width: 1.5),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.verified_outlined,
                                color: AppColors.primaryBlue,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Career Passport',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primaryBlue,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 16,
                                          color: AppColors.primaryBlue,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Verified projects · Avg rating',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: AppColors.mutedText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScreenWithAppBar extends StatelessWidget {
  final Widget body;
  final VoidCallback onAvatarTap;

  const _ScreenWithAppBar({
    required this.body,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          StudentAppBar(onAvatarTap: onAvatarTap),
          Expanded(child: body),
        ],
      ),
    );
  }
}
