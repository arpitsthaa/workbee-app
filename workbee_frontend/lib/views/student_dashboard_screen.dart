import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:workbee_frontend/services/auth_service.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/views/browse_gigs_screen.dart';
import 'package:workbee_frontend/views/login_screen.dart';
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
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final result = await _authService.getStudentDashboard();
    if (!mounted) return;
    final status = result['status'] as int?;
    if (status == 401 || status == 403) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
      return;
    }
    if (result.containsKey('error')) {
      setState(() {
        _error = 'Error (${status ?? '?' }): ${result['error'] as String?}';
        _isLoading = false;
      });
    } else {
      setState(() {
        _dashboard = DashboardResponse.fromJson(result as Map<String, dynamic>);
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadDashboard();
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

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const mutedText = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          RefreshIndicator(
            onRefresh: _onRefresh,
            color: primaryBlue,
            child: _buildHomeBody(),
          ),
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
    const shimmerBase = Color(0xFFEFF6FF);
    const shimmerHighlight = Color(0xFFDBEAFE);

    final studentName = _dashboard?.fullName ?? 'Student';
    final profileCompletion = _dashboard?.profileCompletion ?? 0;
    final isVerified = _dashboard?.isVerified ?? false;
    final recommendedGigs = _dashboard?.recommendedGigs ?? <Gig>[];
    final appsSummary = _dashboard?.applicationsSummary ?? <String, dynamic>{};
    final projectsSummary = _dashboard?.projectsSummary ?? <String, dynamic>{};

    if (_isLoading) {
      return _buildShimmerHomeBody(
        shimmerBase: shimmerBase,
        shimmerHighlight: shimmerHighlight,
      );
    }

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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/workbee_logo.png',
                          width: 44,
                          height: 44,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WorkBee',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: darkText,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              'Bee Busy Be Paid',
                              style: TextStyle(
                                fontSize: 12,
                                color: mutedText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: softBlueBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        studentName.isNotEmpty
                            ? studentName[0].toUpperCase()
                            : 'S',
                        style: const TextStyle(
                          color: primaryBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Hi, $studentName!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: darkText,
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
                Container(
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
                Container(
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
                      'Recommended gigs',
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
                ...recommendedGigs.take(3).map((gig) {
                  return Column(
                    children: [
                      _GigCard(
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
                }).toList(),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        countText: '${appsSummary['total'] ?? 0} applications',
                        subtitleText:
                            '${appsSummary['pending'] ?? 0} pending · ${appsSummary['shortlisted'] ?? 0} shortlisted',
                        borderColor: borderColor,
                        onTap: () => _onTabTapped(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        countText: '${projectsSummary['total'] ?? 0} projects',
                        subtitleText:
                            '${projectsSummary['active'] ?? 0} active · ${projectsSummary['approved'] ?? 0} approved',
                        borderColor: borderColor,
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
                      color: softBlueBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: primaryBlue, width: 1.5),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  Widget _buildShimmerHomeBody({
    required Color shimmerBase,
    required Color shimmerHighlight,
  }) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerRow(
                  shimmerBase: shimmerBase,
                  shimmerHighlight: shimmerHighlight,
                  children: [
                    _shimmerBox(width: 44, height: 44, borderRadius: 8),
                    const SizedBox(width: 12),
                    _shimmerBox(width: 100, height: 20, borderRadius: 4),
                    const SizedBox(height: 4),
                    _shimmerBox(width: 80, height: 12, borderRadius: 4),
                  ],
                ),
                const SizedBox(height: 24),
                _shimmerBox(width: 150, height: 28, borderRadius: 4),
                const SizedBox(height: 4),
                _shimmerBox(width: 200, height: 14, borderRadius: 4),
                const SizedBox(height: 12),
                _shimmerBox(width: 100, height: 24, borderRadius: 20),
                const SizedBox(height: 20),
                _shimmerBox(width: double.infinity, height: 80, borderRadius: 14),
                const SizedBox(height: 24),
                _shimmerBox(width: 150, height: 18, borderRadius: 4),
                const SizedBox(height: 14),
                ...List.generate(3, (index) => Column(
                  children: [
                    _shimmerBox(width: double.infinity, height: 80, borderRadius: 14),
                    const SizedBox(height: 12),
                  ],
                )),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: _shimmerBox(width: double.infinity, height: 60, borderRadius: 14)),
                    const SizedBox(width: 12),
                    Expanded(child: _shimmerBox(width: double.infinity, height: 60, borderRadius: 14)),
                  ],
                ),
                const SizedBox(height: 16),
                _shimmerBox(width: double.infinity, height: 60, borderRadius: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerRow({
    required Color shimmerBase,
    required Color shimmerHighlight,
    required List<Widget> children,
  }) {
    return Shimmer.fromColors(
      baseColor: shimmerBase,
      highlightColor: shimmerHighlight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class _GigCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String payText;
  final String metaText;
  final bool highlightMeta;
  final VoidCallback onTap;

  const _GigCard({
    required this.title,
    required this.subtitle,
    required this.payText,
    required this.metaText,
    required this.highlightMeta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const mutedText = Color(0xFF64748B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: mutedText,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  payText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: primaryBlue,
                  ),
                ),
                Text(
                  metaText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: highlightMeta ? FontWeight.w600 : FontWeight.w400,
                    color: highlightMeta ? primaryBlue : mutedText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String countText;
  final String subtitleText;
  final Color borderColor;
  final VoidCallback onTap;

  const _StatCard({
    required this.countText,
    required this.subtitleText,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              countText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitleText,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}