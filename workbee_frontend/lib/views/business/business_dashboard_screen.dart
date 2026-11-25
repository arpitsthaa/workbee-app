import 'package:flutter/material.dart';
import 'package:workbee_frontend/views/business/business_gigs_screen.dart';

class BusinessDashboardScreen extends StatefulWidget {
  final String businessName;
  final String location;

  const BusinessDashboardScreen({
    super.key,
    this.businessName = 'Momo Junction',
    this.location = 'Baneshwor, Kathmandu',
  });

  @override
  State<BusinessDashboardScreen> createState() =>
      _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState extends State<BusinessDashboardScreen> {
  int _selectedIndex = 0;

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'MJ';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  void _openGigsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessGigsScreen(
          businessName: widget.businessName,
          location: widget.location,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const softBlueBg = Color(0xFFEFF6FF);
    const darkText = Color(0xFF0F172A);
    const mutedText = Color(0xFF64748B);
    const borderColor = Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Brand Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: primaryBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.diamond_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
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
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: softBlueBg,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _getInitials(widget.businessName),
                          style: const TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Business Name & Subtitle
                  Text(
                    widget.businessName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Your business workspace',
                    style: TextStyle(fontSize: 14.5, color: mutedText),
                  ),
                  const SizedBox(height: 16),

                  // Verified Business Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: softBlueBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.check, size: 16, color: primaryBlue),
                                SizedBox(width: 6),
                                Text(
                                  'Verified business',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.location,
                              style: const TextStyle(
                                fontSize: 13,
                                color: mutedText,
                              ),
                            ),
                          ],
                        ),
                        const Row(
                          children: [
                            Text(
                              'Profile',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: primaryBlue,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              size: 15,
                              color: primaryBlue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2x2 Metric Grid
                  const Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          count: '1',
                          title: 'Active Gigs',
                          subtitle: 'Open for applications',
                          borderColor: borderColor,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          count: '2',
                          title: 'New Applicants',
                          subtitle: 'Ready to review',
                          borderColor: borderColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          count: '1',
                          title: 'Projects in Progress',
                          subtitle: 'Work awaiting review',
                          borderColor: borderColor,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          count: '0',
                          title: 'Completed Projects',
                          subtitle: 'After your approval',
                          borderColor: borderColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Recent Applications Header
                  const Row(
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
                      Row(
                        children: [
                          Text(
                            'View all',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: primaryBlue,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 15,
                            color: primaryBlue,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Grouped Recent Applications Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: const Column(
                      children: [
                        _RecentApplicationRow(
                          initials: 'AS',
                          name: 'Aayusha Shrestha',
                          skillsAndRating: 'Canva · Social media design · ★ 4.9',
                          gigTitle: 'Restaurant Social Media Design',
                        ),
                        Divider(height: 1, color: borderColor),
                        _RecentApplicationRow(
                          initials: 'RA',
                          name: 'Rohan Adhikari',
                          skillsAndRating: 'Canva · Illustration · ★ 4.7',
                          gigTitle: 'Restaurant Social Media Design',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Dual Action Buttons (+ Post a Gig | Manage Projects)
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _openGigsScreen,
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
                            onPressed: () {},
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
                  ),
                  const SizedBox(height: 16),

                  // Workflow Stepper Caption
                  const Center(
                    child: Text(
                      'Post  →  Review  →  Select  →  Manage  →  Approve  →  Rate',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: mutedText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
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
                onTap: _openGigsScreen,
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
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String count;
  final String title;
  final String subtitle;
  final Color borderColor;

  const _MetricCard({
    required this.count,
    required this.title,
    required this.subtitle,
    required this.borderColor,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

  const _RecentApplicationRow({
    required this.initials,
    required this.name,
    required this.skillsAndRating,
    required this.gigTitle,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const softBlueBg = Color(0xFFEFF6FF);

    return Padding(
      padding: const EdgeInsets.all(14),
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
      child: InkWell(
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