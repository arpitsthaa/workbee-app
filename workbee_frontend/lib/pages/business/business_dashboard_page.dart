import 'package:flutter/material.dart';
import 'package:workbee_frontend/clients/business_client.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/pages/auth/login_page.dart';
import 'package:workbee_frontend/pages/business/business_gigs_page.dart';
import 'package:workbee_frontend/pages/business/business_profile_screen.dart';
import 'package:workbee_frontend/pages/business/business_projects_page.dart';
import 'package:workbee_frontend/services/token_service.dart';
import 'package:workbee_frontend/widgets/common_app_bar.dart';

class BusinessDashboardPage extends StatefulWidget {
  final String businessName;
  final String location;

  const BusinessDashboardPage({
    super.key,
    this.businessName = 'Momo Junction',
    this.location = 'Baneshwor, Kathmandu',
  });

  @override
  State<BusinessDashboardPage> createState() => _BusinessDashboardPageState();
}

class _BusinessDashboardPageState extends State<BusinessDashboardPage> {
  static const softBlueBg = Color(0xFFEFF6FF);

  int _selectedIndex = 0;
  String? _errorMessage;
  BusinessDashboardResponse? _dashboard;
  final ValueNotifier<int> _projectsTabNotifier = ValueNotifier(0);

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'MJ';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _loadDashboard() async {
    try {
      final result = await BusinessClient.getDashboard();

      if (!mounted) return;

      if (result.containsKey('error')) {
        setState(() {
          _errorMessage = result['error'] as String?;
        });
        return;
      }

      final dashboard = BusinessDashboardResponse.fromJson(result);
      setState(() {
        _dashboard = dashboard;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Connection error: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  @override
  void dispose() {
    _projectsTabNotifier.dispose();
    super.dispose();
  }

  String _skillsAndRating(GigApplication app) {
    final skills = app.studentSkills.isNotEmpty
        ? app.studentSkills.join(' · ')
        : 'No skills listed';
    return '$skills · ★ ${app.studentRating.toStringAsFixed(1)}';
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const softBlueBg = Color(0xFFEFF6FF);
    const darkText = Color(0xFF0F172A);
    const mutedText = Color(0xFF64748B);
    const borderColor = Color(0xFFE2E8F0);

    if (_errorMessage != null) return _buildError(context, _errorMessage!);

    final rawBusinessName = _dashboard?.businessName ?? widget.businessName;
    final displayName = rawBusinessName.contains('@') ? widget.businessName : rawBusinessName;
    final displayLocation = _dashboard?.location ?? widget.location;
    final recentApplications = _dashboard?.recentApplications ?? const [];
    final isLoading = _dashboard == null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        displayName: displayName,
        role: 'business',
        onAvatarTap: _logout,
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeBody(
              primaryBlue,
              softBlueBg,
              darkText,
              mutedText,
              borderColor,
              _dashboard,
              displayName,
              displayLocation,
              recentApplications,
              isLoading,
            ),
            BusinessGigsPage(
              businessName: displayName,
              location: displayLocation,
              showNavBar: false,
              showAppBar: false,
            ),
            BusinessProjectsScreen(
              businessName: displayName,
              location: displayLocation,
              showNavBar: false,
              showAppBar: false,
              initialTab: 0,
              tabNotifier: _projectsTabNotifier,
            ),
            BusinessProfilePage(
              businessName: displayName,
              location: displayLocation,
              showNavBar: false,
              showAppBar: false,
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _buildHomeBody(
      Color primaryBlue,
      Color softBlueBg,
      Color darkText,
      Color mutedText,
      Color borderColor,
      BusinessDashboardResponse? dashboard,
      String displayName,
      String displayLocation,
      List<GigApplication> recentApplications,
      bool isLoading,
      ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi ',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: darkText,
                    ),
                  ),
                  if (isLoading)
                    const SizedBox(
                      height: 28,
                      width: 120,
                    )
                  else
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Your business workspace',
                style: TextStyle(fontSize: 14.5, color: mutedText),
              ),
              const SizedBox(height: 12),
              if (!isLoading && dashboard!.isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: softBlueBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check,
                        size: 14,
                        color: primaryBlue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Verified business',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              _buildActiveGigsCard(
                primaryBlue,
                softBlueBg,
                darkText,
                mutedText,
                borderColor,
                dashboard,
              ),
              const SizedBox(height: 22),
              _buildMetricGrid(
                primaryBlue,
                softBlueBg,
                darkText,
                mutedText,
                borderColor,
                dashboard,
              ),
              const SizedBox(height: 22),
              _buildRecentApplicationsHeader(
                primaryBlue,
                darkText,
                mutedText,
                recentApplications,
                isLoading,
              ),
              const SizedBox(height: 12),
              _buildRecentApplicationsCard(
                borderColor,
                mutedText,
                recentApplications,
                _getInitials,
                _skillsAndRating,
                isLoading,
              ),
              const SizedBox(height: 18),
              _buildActionButtons(primaryBlue),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNav() {
    return SafeArea(
      top: false,
      child: Container(
        height: 68,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
        ),
        child: Row(
          children: [
            _BottomNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Home',
              selected: _selectedIndex == 0,
              onTap: () => setState(() => _selectedIndex = 0),
            ),
            _BottomNavItem(
              icon: Icons.work_outline_rounded,
              activeIcon: Icons.work_rounded,
              label: 'Gigs',
              selected: _selectedIndex == 1,
              onTap: () => setState(() => _selectedIndex = 1),
            ),
            _BottomNavItem(
              icon: Icons.assignment_outlined,
              activeIcon: Icons.assignment_rounded,
              label: 'Projects',
              selected: _selectedIndex == 2,
              onTap: () => setState(() => _selectedIndex = 2),
            ),
            _BottomNavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Profile',
              selected: _selectedIndex == 3,
              onTap: () => setState(() => _selectedIndex = 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveGigsCard(
      Color primaryBlue,
      Color softBlueBg,
      Color darkText,
      Color mutedText,
      Color borderColor,
      BusinessDashboardResponse? dashboard,
      ) {
    final isLoading = dashboard == null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Gigs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedIndex = 1),
                child: Row(
                  children: [
                    Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 4),
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLoading)
                      Text(
                        '0',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: primaryBlue,
                        ),
                      )
                    else
                      Text(
                        dashboard.activeGigs.toString(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: primaryBlue,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'Open for applications',
                      style: TextStyle(
                        fontSize: 13,
                        color: mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: softBlueBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.work_outline,
                  size: 24,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricGrid(
      Color primaryBlue,
      Color softBlueBg,
      Color darkText,
      Color mutedText,
      Color borderColor,
      BusinessDashboardResponse? dashboard,
      ) {
    final isLoading = dashboard == null;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                count: dashboard?.newApplicants.toString() ?? '',
                title: 'New Applicants',
                subtitle: 'Ready to review',
                borderColor: borderColor,
                isLoading: isLoading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                count: dashboard?.projectsInProgress.toString() ?? '',
                title: 'Projects in Progress',
                subtitle: 'Work awaiting review',
                borderColor: borderColor,
                isLoading: isLoading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                count: dashboard?.completedProjects.toString() ?? '',
                title: 'Completed Projects',
                subtitle: 'After your approval',
                borderColor: borderColor,
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentApplicationsHeader(
      Color primaryBlue,
      Color darkText,
      Color mutedText,
      List<GigApplication> recentApplications,
      bool isLoading,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent applications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
        if (recentApplications.isNotEmpty)
          GestureDetector(
            onTap: () {
              _projectsTabNotifier.value = 0;
              setState(() => _selectedIndex = 2);
            },
            child: Row(
              children: [
                Text(
                  'View all',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  size: 15,
                  color: primaryBlue,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRecentApplicationsCard(
      Color borderColor,
      Color mutedText,
      List<GigApplication> recentApplications,
      String Function(String) getInitials,
      String Function(GigApplication) skillsAndRating,
      bool isLoading,
      ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: recentApplications.isEmpty
            ? [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'No recent applications.',
              style: TextStyle(
                color: mutedText,
                fontSize: 14,
              ),
            ),
          ),
        ]
            : recentApplications
            .asMap()
            .entries
            .expand((entry) {
          final index = entry.key;
          final app = entry.value;
          return [
            _RecentApplicationRow(
              initials: getInitials(app.studentName),
              name: app.studentName,
              skillsAndRating: skillsAndRating(app),
              gigTitle: app.gigTitle,
              onTap: () {
                _projectsTabNotifier.value = 0;
                setState(() => _selectedIndex = 2);
              },
            ),
            if (index < recentApplications.length - 1)
              Divider(height: 1, color: borderColor),
          ];
        })
            .toList(),
      ),
    );
  }

  Widget _buildActionButtons(Color primaryBlue) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _selectedIndex = 1),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'Post a Gig',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () => setState(() => _selectedIndex = 2),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryBlue,
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Manage Projects',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, String message) {
    const primaryBlue = Color(0xFF1D61E7);
    const mutedText = Color(0xFF64748B);
    const darkText = Color(0xFF0F172A);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Failed to load dashboard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: mutedText, fontSize: 13),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _loadDashboard,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Try again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
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
          ),
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Future<void> _logout() async {
    await TokenService.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String count;
  final String title;
  final String subtitle;
  final Color borderColor;
  final bool isLoading;

  const _MetricCard({
    required this.count,
    required this.title,
    required this.subtitle,
    required this.borderColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isLoading)
            Text(
              '0',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1D61E7),
                height: 1.1,
              ),
            )
          else
            Text(
              count,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1D61E7),
                height: 1.1,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentApplicationRow extends StatelessWidget {
  final String initials;
  final String name;
  final String skillsAndRating;
  final String gigTitle;
  final VoidCallback? onTap;

  const _RecentApplicationRow({
    required this.initials,
    required this.name,
    required this.skillsAndRating,
    required this.gigTitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const softBlueBg = Color(0xFFEFF6FF);

    return Padding(
      padding: const EdgeInsets.all(14),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: softBlueBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  skillsAndRating,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  gigTitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'New',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFB45309),
              ),
            ),
          ),
        ],
      ),
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
    const blue = Color(0xFF2563EB);

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
