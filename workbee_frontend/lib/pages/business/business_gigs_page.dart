import 'package:flutter/material.dart';
import 'package:workbee_frontend/clients/business_client.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/pages/auth/login_page.dart';
import 'package:workbee_frontend/pages/business/business_post_gig_page.dart';
import 'package:workbee_frontend/services/token_service.dart';
import 'package:workbee_frontend/widgets/common_app_bar.dart';

class BusinessGigsPage extends StatefulWidget {
  final String businessName;
  final String location;
  final bool showNavBar;
  final bool showAppBar;

  const BusinessGigsPage({
    super.key,
    this.businessName = 'My Business',
    this.location = '',
    this.showNavBar = true,
    this.showAppBar = true,
  });

  @override
  State<BusinessGigsPage> createState() => _BusinessGigsPageState();
}

class _BusinessGigsPageState extends State<BusinessGigsPage> {
  int _selectedNavIndex = 1;
  bool _isLoading = true;
  String? _errorMessage;
  List<Gig> _gigs = [];
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _loadGigs();
  }

  Future<void> _loadGigs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await BusinessClient.getGigs();

      if (!mounted) return;

      if (result.containsKey('error')) {
        setState(() {
          _errorMessage = result['error'] as String?;
          _isLoading = false;
        });
        return;
      }

      final gigsList = (result['gigs'] as List<dynamic>?)
          ?.map((g) => Gig.fromJson(g as Map<String, dynamic>))
          .toList() ?? [];

      setState(() {
        _gigs = gigsList;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Connection error: $e';
        _isLoading = false;
      });
    }
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

  List<Gig> get _filteredGigs {
    if (_filter == 'All') return _gigs;
    return _gigs
        .where((g) => g.status.toUpperCase() == _filter.toUpperCase())
        .toList();
  }

  (Color bgColor, Color textColor) _statusStyle(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return (AppColors.badgeShortlisted, AppColors.primaryBlue);
      case 'IN_PROGRESS':
        return (AppColors.badgePending, const Color(0xFFB45309));
      default:
        return (AppColors.cardLight, AppColors.mutedText);
    }
  }

  String _getEmptyMessage() {
    if (_filter == 'All') return 'No gigs yet.';
    return 'There is no $_filter gigs';
  }

  void _showManageGigDialog(Gig gig) {
    final titleCtrl = TextEditingController(text: gig.title);
    final descCtrl = TextEditingController(text: '');
    final skillsCtrl = TextEditingController(text: gig.requiredSkills.join(', '));
    final budgetCtrl = TextEditingController(text: gig.budgetNpr.toString());
    final deadlineCtrl = TextEditingController(text: gig.deadline);
    final locationCtrl = TextEditingController(text: gig.location);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Gig'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Gig Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: skillsCtrl,
                decoration: const InputDecoration(labelText: 'Required Skills'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: budgetCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Budget (NPR)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: deadlineCtrl,
                decoration: const InputDecoration(labelText: 'Deadline'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locationCtrl,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final result = await BusinessClient.updateGig(
                gig.id,
                {
                  'title': titleCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'required_skills': skillsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                  'budget_npr': int.tryParse(budgetCtrl.text.trim()) ?? 0,
                  'deadline': deadlineCtrl.text.trim(),
                  'location': locationCtrl.text.trim(),
                },
              );
              if (result.containsKey('error')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['error'] ?? 'Failed to update'),
                    backgroundColor: AppColors.errorRed,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              _loadGigs();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gig updated'),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            },
            child: const Text('Update'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Gig'),
                  content: const Text('Are you sure you want to delete this gig?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete', style: TextStyle(color: AppColors.errorRed)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                final result = await BusinessClient.deleteGig(gig.id);
                if (result.containsKey('error')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['error'] ?? 'Failed to delete'),
                      backgroundColor: AppColors.errorRed,
                    ),
                  );
                  return;
                }
                _loadGigs();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gig deleted'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              }
            },
            child: const Text('Delete Gig', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkText = AppColors.darkText;
    const mutedText = AppColors.mutedText;

    if (_isLoading && _gigs.isEmpty) {
      return _buildLoadingSkeleton();
    }

    if (_errorMessage != null && _gigs.isEmpty) {
      return _buildErrorState();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.showAppBar
          ? CommonAppBar(
              displayName: widget.businessName,
              role: 'business',
              onAvatarTap: _logout,
            )
          : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter chips (horizontal scroll, no dropdown icon)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: SizedBox(
                    height: 50,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['All', 'Open', 'In Progress', 'Closed']
                            .map((f) => Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: GestureDetector(
                                    onTap: () => setState(() => _filter = f),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 9),
                                      decoration: BoxDecoration(
                                        color: _filter == f
                                            ? AppColors.softBlueBg
                                            : Colors.white,
                                        border: Border.all(
                                          color: _filter == f
                                              ? AppColors.borderLight
                                              : AppColors.borderColor,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            f,
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: _filter == f
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              color: _filter == f
                                                  ? AppColors.primaryBlue
                                                  : AppColors.mutedText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Scrollable gigs list with pull-to-refresh
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadGigs,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Existing Gigs section header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Existing Gigs',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: darkText,
                                ),
                              ),
                              Text(
                                '${_filteredGigs.length} total',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: mutedText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Gig list or empty state
                          if (_filteredGigs.isEmpty)
                            _buildEmptyState()
                          else
                            ..._filteredGigs.map((gig) {
                              final (bgColor, textColor) =
                                  _statusStyle(gig.status);
                              final statusLabel =
                                  gig.status[0].toUpperCase() +
                                      gig.status.substring(1);
                              return Column(
                                children: [
                                  _GigCard(
                                    title: gig.title,
                                    meta:
                                        'NPR ${gig.budgetNpr} · ${gig.isRemote ? 'Remote' : 'On-site'} · ${gig.durationDays} days · Due ${gig.deadline}',
                                    statusText: statusLabel,
                                    statusBg: bgColor,
                                    statusColor: textColor,
                                    onManage: () => _showManageGigDialog(gig),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              );
                            }),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),

                // Post a Gig button compact at bottom
                Center(
                  child: SizedBox(
                    width: 260,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final posted = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostGigPage(
                              businessName: widget.businessName,
                              location: widget.location,
                            ),
                          ),
                        );
                        if (posted == true) {
                          _loadGigs();
                        }
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        'Post Gig',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: widget.showNavBar ? _bottomNav() : null,
    );
  }

  Widget _buildLoadingSkeleton() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: SizedBox(
                    height: 50,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['All', 'Open', 'In Progress', 'Closed']
                            .map((f) => Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 9),
                                    decoration: BoxDecoration(
                                      color: AppColors.softBlueBg,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          height: 16,
                                          width: 60,
                                          decoration: BoxDecoration(
                                            color: AppColors.softBlueBg,
                                            borderRadius: BorderRadius.circular(
                                                4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ...List.generate(3, (index) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: 140,
                          decoration: BoxDecoration(
                            color: AppColors.softBlueBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 13,
                          width: 260,
                          decoration: BoxDecoration(
                            color: AppColors.softBlueBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 14,
                              width: 100,
                              decoration: BoxDecoration(
                                color: AppColors.softBlueBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Container(
                              height: 13,
                              width: 120,
                              decoration: BoxDecoration(
                                color: AppColors.softBlueBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: widget.showNavBar ? _bottomNav() : null,
    );
  }

  Widget _buildErrorState() {
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
                    color: AppColors.errorRed, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Failed to load gigs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.mutedText, fontSize: 13),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _loadGigs,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Try again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
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
      bottomNavigationBar: widget.showNavBar ? _bottomNav() : null,
    );
  }

  Widget _buildEmptyState() {
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
          Icon(Icons.inbox_outlined,
              size: 56, color: AppColors.borderLight),
          const SizedBox(height: 16),
          Text(
            _getEmptyMessage(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _filter == 'All'
                ? 'Post your first gig to get started.'
                : 'Try selecting a different filter.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mutedText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
              onTap: () {
                setState(() => _selectedNavIndex = 0);
                Navigator.pop(context);
              },
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
    );
  }
}

class _GigCard extends StatelessWidget {
  final String title;
  final String meta;
  final String statusText;
  final Color statusBg;
  final Color statusColor;
  final VoidCallback onManage;

  const _GigCard({
    required this.title,
    required this.meta,
    required this.statusText,
    required this.statusBg,
    required this.statusColor,
    required this.onManage,
  });

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            meta,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.mutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ActionLink(
                label: 'Manage',
                icon: Icons.arrow_forward,
                onTap: onManage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionLink extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _ActionLink({
    required this.label,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlue,
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 4),
            Icon(icon, size: 14, color: AppColors.primaryBlue),
          ],
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

