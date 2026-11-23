import 'package:flutter/material.dart';
import 'package:workbee_frontend/services/auth_service.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/widgets/student_dashboard_widgets.dart';
import 'package:workbee_frontend/views/browse_gigs_screen.dart';
import 'package:workbee_frontend/views/my_work_screen.dart';
import 'package:workbee_frontend/views/passport_screen.dart';
import 'package:workbee_frontend/views/profile_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();

  DashboardResponse? _dashboard;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _authService.warmUp();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final result = await _authService.getStudentDashboard();
    if (!mounted) return;
    if (result.containsKey('error')) {
      setState(() {
        _error = result['error'] as String?;
        _isLoading = false;
      });
    } else {
      setState(() {
        _dashboard = DashboardResponse.fromJson(result);
        _isLoading = false;
      });
    }
  }

  String _formatNpr(int amount) {
    final str = amount.toString();
    if (str.length <= 3) return 'NPR $str';
    final prefix = str.substring(0, str.length - 3);
    final suffix = str.substring(str.length - 3);
    return 'NPR $prefix,$suffix';
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  List<Widget> _buildLatestGigWidgets(List<Gig> recommendedGigs) {
    if (_isLoading) {
      return [GigCardSkeletons()];
    }
    return recommendedGigs.map((gig) {
      return Column(
        children: [
          GigCard(
            title: gig.title,
            subtitle: '${gig.businessName} · ${gig.location}',
            payText: _formatNpr(gig.budgetNpr),
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
    const primaryBlue = Color(0xFF1D61E7);
    const mutedText = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeBody(),
          const BrowseGigsScreen(),
          const MyWorkScreen(),
          const PassportScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: mutedText,
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
    const primaryBlue = Color(0xFF1D61E7);
    const softBlueBg = Color(0xFFEFF6FF);
    const darkText = Color(0xFF0F172A);
    const bodyText = Color(0xFF1E293B);
    const mutedText = Color(0xFF64748B);
    const borderColor = Color(0xFFE2E8F0);

    final studentName = _dashboard?.fullName ?? 'Student';
    final profileCompletion = _dashboard?.profileCompletion ?? 0;
    final isVerified = _dashboard?.isVerified ?? false;
    final recommendedGigs = _dashboard?.recommendedGigs ?? <Gig>[];
    final appsSummary = _dashboard?.applicationsSummary ?? <String, dynamic>{};
    final projectsSummary = _dashboard?.projectsSummary ?? <String, dynamic>{};

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: DashboardHeader(
              studentName: studentName,
              isVerified: isVerified,
              isLoading: _isLoading,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _isLoading
                        ? GreetingSkeleton()
                        : RichText(
                            text: TextSpan(
                              text: 'Hi, ',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: darkText,
                              ),
                              children: [
                                TextSpan(
                                  text: studentName,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: darkText,
                                  ),
                                ),
                                const TextSpan(
                                  text: '!',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: darkText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your next opportunity starts here.',
                      style: TextStyle(
                        fontSize: 14,
                        color: mutedText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _isLoading
                        ? VerifiedBadgeSkeleton()
                        : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: softBlueBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: primaryBlue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Student verified',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isVerified ? primaryBlue : mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? ProfileCompletionSkeleton()
                        : Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: softBlueBg,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Profile $profileCompletion% complete',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: bodyText,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _onTabTapped(4),
                                      child: const Text(
                                        'Edit',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: primaryBlue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: profileCompletion / 100,
                                    minHeight: 6,
                                    backgroundColor: const Color(0xFFDBEAFE),
                                    valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Complete your profile to stand out.',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: mutedText,
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
                            color: darkText,
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
                                  color: primaryBlue,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: primaryBlue,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ..._buildLatestGigWidgets(recommendedGigs.take(3).toList()),
                    const SizedBox(height: 18),
                    _isLoading
                        ? StatCardSkeletons()
                        : Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  countText:
                                      '${appsSummary['total'] ?? 0} applications',
                                  subtitleText:
                                      '${appsSummary['pending'] ?? 0} pending · ${appsSummary['shortlisted'] ?? 0} shortlisted',
                                  borderColor: borderColor,
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
                                  borderColor: borderColor,
                                  onTap: () => _onTabTapped(2),
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 16),
                    _isLoading
                        ? PassportCardSkeleton()
                        : InkWell(
                            onTap: () => _onTabTapped(3),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: softBlueBg,
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: primaryBlue, width: 1.5),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.verified_outlined,
                                    color: primaryBlue,
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
                                                color: primaryBlue,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Icon(
                                              Icons.arrow_forward,
                                              size: 16,
                                              color: primaryBlue,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Verified projects · Avg rating',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            color: mutedText,
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
