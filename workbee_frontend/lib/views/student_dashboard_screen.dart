import 'package:flutter/material.dart';
import 'package:workbee_frontend/views/browse_gigs_screen.dart';
import 'package:workbee_frontend/views/my_work_screen.dart';
import 'package:workbee_frontend/views/passport_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  final String studentName;

  const StudentDashboardScreen({
    super.key,
    this.studentName = 'Anisha',
  });

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const softBlueBg = Color(0xFFEFF6FF);
    const darkText = Color(0xFF0F172A);
    const bodyText = Color(0xFF1E293B);
    const mutedText = Color(0xFF64748B);
    const borderColor = Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: _selectedIndex == 1
          ? const BrowseGigsScreen()
          : _selectedIndex == 2
          ? const MyWorkScreen()
          : _selectedIndex == 3
          ? const PassportScreen()
          : SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Brand Header & User Avatar
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
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: softBlueBg,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'AS',
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Greeting & Verified Pill
                  Text(
                    'Hi, ${widget.studentName}!',
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
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check,
                          size: 14,
                          color: primaryBlue,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Student verified',
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

                  // Profile Completion Card
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
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Profile 90% complete',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: bodyText,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // TODO: Open profile edit screen
                              },
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
                          child: const LinearProgressIndicator(
                            value: 0.9,
                            minHeight: 6,
                            backgroundColor: Color(0xFFDBEAFE),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              primaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Add one more portfolio sample to stand out.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recommended Gigs Header
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
                        onTap: () {
                          setState(() => _selectedIndex = 1);
                        },
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

                  // Reusable Gig Cards
                  _GigCard(
                    title: 'Restaurant Social Media Design',
                    subtitle: 'Momo Junction · Baneshwor, Kathmandu',
                    payText: 'NPR 3,000',
                    metaText: '7 days · Due 21 Oct',
                    highlightMeta: false,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                  const SizedBox(height: 12),
                  _GigCard(
                    title: 'Product Photo Editing',
                    subtitle: 'Local Loom · Patan, Lalitpur',
                    payText: 'NPR 2,500',
                    metaText: '5 days · Due 19 Oct',
                    highlightMeta: true,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                  const SizedBox(height: 18),

                  // Two Side-by-Side Stat Cards
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          countText: '2 applications',
                          subtitleText: '1 pending · 1 shortlisted',
                          borderColor: borderColor,
                          onTap: () => setState(() => _selectedIndex = 2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          countText: '3 projects',
                          subtitleText: '1 active · 2 approved',
                          borderColor: borderColor,
                          onTap: () => setState(() => _selectedIndex = 2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Career Passport Banner Card
                  InkWell(
                    onTap: () => setState(() => _selectedIndex = 3),
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
                                  '2 verified projects · 4.9/5 average rating',
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: mutedText,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
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
}

// ---------------------------------------------------------------------------
// REUSABLE DASHBOARD WIDGETS
// ---------------------------------------------------------------------------

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