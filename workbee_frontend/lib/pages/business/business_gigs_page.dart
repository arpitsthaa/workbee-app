import 'package:flutter/material.dart';
import 'package:workbee_frontend/clients/business_client.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/format_utils.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/pages/auth/login_page.dart';
import 'package:workbee_frontend/pages/business/business_edit_gig_page.dart';
import 'package:workbee_frontend/pages/business/business_post_gig_page.dart';
import 'package:workbee_frontend/services/token_service.dart';
import 'package:workbee_frontend/widgets/common_app_bar.dart';
import 'package:flutter/services.dart';

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
  String _filter = 'Open';

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
    if (_filter == 'Open') {
      return _gigs.where((g) => g.status.toUpperCase() == 'OPEN').toList();
    }
    if (_filter == 'Closed') {
      return _gigs.where((g) => g.status.toUpperCase() == 'CLOSED').toList();
    }
    if (_filter == 'Rated') {
      return _gigs.where((g) => g.hasReview).toList();
    }
    return _gigs.where((g) => g.status.toUpperCase() == _filter.toUpperCase()).toList();
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

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
      ),
    );
  }

  Future<void> _openProposal(String raw) async {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      _showSnack('No proposal link available.');
      return;
    }
    var text = trimmed;
    final uri = Uri.tryParse(trimmed);
    if (uri == null || uri.scheme.isEmpty) {
      text = 'https://$trimmed';
    }
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  void _showReviewSheet(Gig gig) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ReviewSheet(gig: gig),
    );
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
        floatingActionButton: FloatingActionButton.extended(
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
          icon: const Icon(Icons.add, size: 20, color: Colors.white),
          label: const Text(
            'Post Gig',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primaryBlue,
        ),
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
                        children: ['All', 'Open', 'Closed', 'Rated']
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
                      physics: const AlwaysScrollableScrollPhysics(),
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
                              final statusLabel = gig.hasReview
                                  ? 'Rated'
                                  : gig.status[0].toUpperCase() +
                                      gig.status.substring(1);
                              final badgeBg =
                                  gig.hasReview ? AppColors.successGreen : bgColor;
                              final badgeColor = gig.hasReview
                                  ? Colors.white
                                  : textColor;
                              return Column(
                                children: [
                                  _GigCard(
                                    title: gig.title,
                                    meta:
                                        'NPR ${gig.budgetNpr} · ${gig.isRemote ? 'Remote' : 'On-site'} · ${gig.durationDays} days · Due ${formatDateDmy(gig.deadline)}',
                                    statusText: statusLabel,
                                    statusBg: badgeBg,
                                    statusColor: badgeColor,
                                    proposalLink: gig.proposalLink,
                                    hasReview: gig.hasReview,
                                    rating: gig.rating,
                                    reviewComment: gig.reviewComment,
                                    submissionLink: gig.submissionLink,
                                    studentName: gig.studentName,
                                    onManage: () => _openEditGig(gig),
                                    onViewProposal: () =>
                                        _openProposal(gig.proposalLink),
                                    onViewReview: () => _showReviewSheet(gig),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              );
                            }),

                          const SizedBox(height: 16),
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
      onTap: (i) {
        if (i == 0) {
          setState(() => _selectedNavIndex = 0);
          Navigator.pop(context);
          return;
        }
        setState(() => _selectedNavIndex = i);
      },
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

class _GigCard extends StatelessWidget {
  final String title;
  final String meta;
  final String statusText;
  final Color statusBg;
  final Color statusColor;
  final String proposalLink;
  final bool hasReview;
  final double rating;
  final String reviewComment;
  final String submissionLink;
  final String studentName;
  final VoidCallback onManage;
  final VoidCallback onViewProposal;
  final VoidCallback onViewReview;

  const _GigCard({
    required this.title,
    required this.meta,
    required this.statusText,
    required this.statusBg,
    required this.statusColor,
    required this.proposalLink,
    required this.hasReview,
    required this.rating,
    required this.reviewComment,
    required this.submissionLink,
    required this.studentName,
    required this.onManage,
    required this.onViewProposal,
    required this.onViewReview,
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
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.softBlueBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryBlue, width: 2),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.work_outline, size: 20, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 17,
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
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 13, color: AppColors.mutedText),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            meta,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.mutedText,
                              height: 1.4,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: onManage,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text(
                'Manage',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: const BorderSide(color: AppColors.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          if (proposalLink.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton.icon(
                onPressed: onViewProposal,
                icon: const Icon(Icons.description, size: 16),
                label: const Text(
                  'View Proposal',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
          if (hasReview) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton.icon(
                onPressed: onViewReview,
                icon: const Icon(Icons.star_rate, size: 16),
                label: const Text(
                  'View Review',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.successGreen,
                  side: const BorderSide(color: AppColors.successGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Bottom sheet showing the submitted file, rating, and comment for a rated gig.
class _ReviewSheet extends StatelessWidget {
  final Gig gig;

  const _ReviewSheet({required this.gig});

  static const Color _starGold = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final filledStars = gig.rating.round();
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                gig.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
              if (gig.studentName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  gig.studentName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  ...List.generate(
                    5,
                    (index) => Icon(
                      index < filledStars ? Icons.star : Icons.star_border,
                      color: index < filledStars ? _starGold : AppColors.mutedText,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    gig.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
              if (gig.reviewComment.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Review',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.softBlueBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    gig.reviewComment,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
              ],
              if (gig.submissionLink.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Project File',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final trimmed = gig.submissionLink.trim();
                      var text = trimmed;
                      final uri = Uri.tryParse(trimmed);
                      if (uri == null || uri.scheme.isEmpty) {
                        text = 'https://$trimmed';
                      }
                      await Clipboard.setData(ClipboardData(text: text));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Link copied'),
                          backgroundColor: AppColors.successGreen,
                        ),
                      );
                    },
                    icon: const Icon(Icons.description, size: 16),
                    label: Text(
                      gig.submissionLink,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
