import 'package:flutter/material.dart';
import 'package:workbee_frontend/clients/business_client.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/pages/auth/login_page.dart';
import 'package:workbee_frontend/pages/business/business_edit_gig_page.dart';
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

  void _openEditGig(Gig gig) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessEditGigPage(gig: gig),
      ),
    );
    if (updated == true) {
      _loadGigs();
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkText = AppColors.darkText;
    const mutedText = AppColors.mutedText;

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

                          // Gig list area — dynamic content only
                          if (_isLoading && _gigs.isEmpty)
                            _buildLoadingSkeleton()
                          else if (_errorMessage != null && _gigs.isEmpty)
                            _buildErrorState()
                          else if (_filteredGigs.isEmpty)
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
                                    onManage: () => _openEditGig(gig),
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
    return Column(
      children: List.generate(3, (index) {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    );
  }

  Widget _buildErrorState() {
    return Center(
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
            mainAxisAlignment: MainAxisAlignment.end,
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

