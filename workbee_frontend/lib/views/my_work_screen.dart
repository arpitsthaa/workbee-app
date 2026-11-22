import 'package:flutter/material.dart';
import 'package:workbee_frontend/services/auth_service.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/views/student_dashboard_screen.dart';
import 'package:workbee_frontend/views/browse_gigs_screen.dart';
import 'package:workbee_frontend/views/passport_screen.dart';
import 'package:workbee_frontend/views/profile_screen.dart';

class MyWorkScreen extends StatefulWidget {
  const MyWorkScreen({super.key});

  @override
  State<MyWorkScreen> createState() => _MyWorkScreenState();
}

class _MyWorkScreenState extends State<MyWorkScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  int _activeTab = 1;
  bool _isLoading = true;
  String? _error;
  WorkResponse? _work;

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
    final result = await _authService.getStudentWork();
    if (!mounted) return;
    if (result.containsKey('error')) {
      setState(() {
        _error = result['error'] as String?;
        _isLoading = false;
      });
    } else {
      setState(() {
        _work = WorkResponse.fromJson(result as Map<String, dynamic>);
        _isLoading = false;
      });
    }
  }

  List<GigApplication> get _applications => _work?.applications ?? [];
  List<Project> get _projects => _work?.projects ?? [];

  String _formatNpr(int amount) {
    final str = amount.toString();
    if (str.length <= 3) return 'NPR $str';
    final prefix = str.substring(0, str.length - 3);
    final suffix = str.substring(str.length - 3);
    return 'NPR $prefix,$suffix';
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const softBlueBg = Color(0xFFEFF6FF);
    const darkText = Color(0xFF0F172A);
    const mutedText = Color(0xFF64748B);
    const borderColor = Color(0xFFE2E8F0);
    const inputFill = Color(0xFFF8FAFC);

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My work',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Follow your progress. Keep work moving.',
                          style: TextStyle(
                            fontSize: 14,
                            color: mutedText,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: inputFill,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _SegmentTab(
                                  label: 'Applications (${_applications.length})',
                                  selected: _activeTab == 0,
                                  onTap: () => setState(() => _activeTab = 0),
                                ),
                              ),
                              Expanded(
                                child: _SegmentTab(
                                  label: 'Projects (${_projects.length})',
                                  selected: _activeTab == 1,
                                  onTap: () => setState(() => _activeTab = 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        if (_activeTab == 0) ...[
                          const Text(
                            'Application updates',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_applications.isEmpty)
                            const Text(
                              'No applications yet. Browse gigs and apply!',
                              style: TextStyle(
                                fontSize: 14,
                                color: mutedText,
                              ),
                            )
                          else
                            ..._applications.map((app) {
                              return Column(
                                children: [
                                  _SimpleItemCard(
                                    title: app.gigTitle,
                                    subtitle:
                                        '${app.businessName} · Applied ${_formatDate(app.appliedAt)}',
                                    badgeText: app.status.toUpperCase(),
                                    badgeBg: _badgeColor(app.status),
                                    badgeColor: Colors.white,
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
                                color: mutedText,
                              ),
                            )
                          else ...[
                            const Text(
                              'Active projects',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: darkText,
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
                                      color: softBlueBg,
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
                                                  color: darkText,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              project.status.replaceAll('_', ' ').toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: primaryBlue,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          '${project.businessName} · Due ${project.deadline}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: mutedText,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          '${_formatNpr(project.budgetNpr)} · ${project.deliverables.join(', ')}',
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                            color: primaryBlue,
                                          ),
                                        ),
                                        if (project.submissionLink.isNotEmpty) ...[
                                          SizedBox(height: 10),
                                          Text(
                                            'Submitted: ${project.submissionLink}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: mutedText,
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
                                color: darkText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Paste your delivery link below.',
                              style: TextStyle(fontSize: 13, color: mutedText),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _linkController,
                              decoration: InputDecoration(
                                hintText: 'Paste Canva or Google Drive link',
                                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                prefixIcon: const Icon(
                                  Icons.link,
                                  color: mutedText,
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: inputFill,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: primaryBlue,
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
                                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                filled: true,
                                fillColor: inputFill,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: primaryBlue,
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
                                  backgroundColor: primaryBlue,
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: mutedText,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const StudentDashboardScreen()),
              );
              break;
            case 1:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const BrowseGigsScreen()),
              );
              break;
            case 3:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const PassportScreen()),
              );
              break;
            case 4:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
              break;
          }
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

  Color _badgeColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return const Color(0xFFFEF3C7);
      case 'SHORTLISTED':
        return const Color(0xFFEFF6FF);
      case 'ACCEPTED':
        return const Color(0xFFD1FAE5);
      case 'REJECTED':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFE2E8F0);
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
}

class _SegmentTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentTab({
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
          color: selected ? const Color(0xFFEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: selected ? const Color(0xFF1D61E7) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _SimpleItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badgeText;
  final Color badgeBg;
  final Color badgeColor;

  const _SimpleItemCard({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeBg,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
