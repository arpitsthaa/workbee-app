import 'dart:async';
import 'package:flutter/material.dart';
import 'package:workbee_frontend/services/auth_service.dart';
import 'package:workbee_frontend/services/user_session_service.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/widgets/gig_post_card.dart';

class BrowseGigsScreen extends StatefulWidget {
  final VoidCallback? onAppliedNavigate;

  const BrowseGigsScreen({super.key, this.onAppliedNavigate});

  @override
  State<BrowseGigsScreen> createState() => _BrowseGigsScreenState();
}

class _BrowseGigsScreenState extends State<BrowseGigsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();

  String _searchQuery = '';
  String _selectedCategory = 'All categories';
  String _selectedBudget = 'Any budget';
  String _sortBy = 'Newest first';

  final List<String> _categories = [
    'All categories',
    'Design & creative',
    'Development & IT',
    'Content & marketing',
    'Data & admin',
  ];

  final List<String> _budgets = [
    'Any budget',
    'Under NPR 3,000',
    'NPR 3,000 - 5,000',
    'Above NPR 5,000',
  ];

  late Future<List<Gig>> _gigsFuture;
  late StreamSubscription _gigSubscription;

  @override
  void initState() {
    super.initState();
    _gigsFuture = _fetchGigs();
    _gigSubscription = AuthService.onGigCreated.listen((_) => _reload());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _gigSubscription.cancel();
    super.dispose();
  }

  Future<List<Gig>> _fetchGigs() async {
    int? maxBudget;
    if (_selectedBudget == 'Under NPR 3,000') {
      maxBudget = 3000;
    } else if (_selectedBudget == 'NPR 3,000 - 5,000') {
      maxBudget = 5000;
    } else if (_selectedBudget == 'Above NPR 5,000') {
      maxBudget = 999999;
    }

    final result = await _authService.browseGigs(
      search: _searchQuery.isEmpty ? null : _searchQuery,
      category: _selectedCategory == 'All categories' ? null : _selectedCategory,
      maxBudget: maxBudget,
    );

    if (result.containsKey('error')) {
      throw Exception(result['error'] as String?);
    }

    final list = result['gigs'] as List<dynamic>;
    return list.map((g) => Gig.fromJson(g as Map<String, dynamic>)).toList();
  }

  void _reload() {
    setState(() {
      _gigsFuture = _fetchGigs();
    });
  }

  List<Gig> _filterAndSort(List<Gig> gigs) {
    final query = _searchQuery.toLowerCase().trim();

    var results = gigs.where((gig) {
      final matchesSearch = query.isEmpty ||
          gig.title.toLowerCase().contains(query) ||
          gig.businessName.toLowerCase().contains(query) ||
          gig.location.toLowerCase().contains(query);

      final matchesCategory = _selectedCategory == 'All categories' ||
          gig.category.toLowerCase() == _selectedCategory.toLowerCase();

      bool matchesBudget = true;
      if (_selectedBudget == 'Under NPR 3,000') {
        matchesBudget = gig.budgetNpr < 3000;
      } else if (_selectedBudget == 'NPR 3,000 - 5,000') {
        matchesBudget = gig.budgetNpr >= 3000 && gig.budgetNpr <= 5000;
      } else if (_selectedBudget == 'Above NPR 5,000') {
        matchesBudget = gig.budgetNpr > 5000;
      }

      return matchesSearch && matchesCategory && matchesBudget;
    }).toList();

    if (_sortBy == 'Newest first') {
      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_sortBy == 'Highest budget') {
      results.sort((a, b) => b.budgetNpr.compareTo(a.budgetNpr));
    }

    return results;
  }

  String _formatNpr(int amount) {
    final str = amount.toString();
    if (str.length <= 3) return 'NPR $str';
    final prefix = str.substring(0, str.length - 3);
    final suffix = str.substring(str.length - 3);
    return 'NPR $prefix,$suffix';
  }

  void _pickFilter({
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                ...options.map((option) {
                  final isSelected = option == currentValue;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      option,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF1D61E7)
                            : const Color(0xFF1E293B),
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Color(0xFF1D61E7))
                        : null,
                    onTap: () {
                      onSelected(option);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGigDetails(Gig gig) {
    const primaryBlue = Color(0xFF1D61E7);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            bool isApplying = false;
            bool hasApplied = false;

            Future<void> handleApply() async {
              setModalState(() => isApplying = true);

              final result =
                  await _authService.applyForGig(gig.id, coverMessage: '');

              if (!mounted || !context.mounted) return;

              if (result.containsKey('error')) {
                setModalState(() => isApplying = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['error'] as String? ?? 'Failed to apply',
                    ),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              await UserSessionService().markApplied(gig.id);
              if (!mounted || !context.mounted) return;

              setModalState(() {
                isApplying = false;
                hasApplied = true;
              });

              await Future.delayed(const Duration(milliseconds: 800));
              if (!mounted || !context.mounted) return;

              Navigator.pop(context);
              widget.onAppliedNavigate?.call();
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gig.businessName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      gig.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      gig.requiredSkills.join(' · '),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatNpr(gig.budgetNpr),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: primaryBlue,
                          ),
                        ),
                        Text(
                          '${gig.durationDays} days · ${gig.deadline}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${gig.location} · ${gig.isRemote ? 'Remote-friendly' : 'On-site'}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Project Description',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Apply to see full project details and deliverables.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isApplying || hasApplied ? null : handleApply,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isApplying
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : hasApplied
                                ? const Text(
                                    'Applied',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                : const Text(
                                    'Apply for this Gig',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const softBlueBg = Color(0xFFEFF6FF);
    const darkText = Color(0xFF0F172A);
    const mutedText = Color(0xFF64748B);
    const borderColor = Color(0xFFE2E8F0);
    const errorColor = Color(0xFFEF4444);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          _reload();
        },
        child: FutureBuilder<List<Gig>>(
          future: _gigsFuture,
          builder: (context, snapshot) {
            final waiting = snapshot.connectionState == ConnectionState.waiting;
            final hasError = snapshot.hasError;
            final gigs = (waiting || hasError)
                ? <Gig>[]
                : _filterAndSort(snapshot.data ?? []);

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() => _searchQuery = value);
                              },
                              decoration: InputDecoration(
                                hintText: 'Search gigs or businesses',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 14.5,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: mutedText,
                                  size: 22,
                                ),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.close, size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _searchQuery = '');
                                        },
                                      )
                                    : null,
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
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
                            const SizedBox(height: 14),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _FilterChipButton(
                                    label: _selectedCategory,
                                    isActive: _selectedCategory != 'All categories',
                                    onTap: () => _pickFilter(
                                      title: 'Select Category',
                                      options: _categories,
                                      currentValue: _selectedCategory,
                                      onSelected: (val) {
                                        setState(() => _selectedCategory = val);
                                        _reload();
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  _FilterChipButton(
                                    label: _selectedBudget,
                                    isActive: _selectedBudget != 'Any budget',
                                    onTap: () => _pickFilter(
                                      title: 'Select Budget',
                                      options: _budgets,
                                      currentValue: _selectedBudget,
                                      onSelected: (val) {
                                        setState(() => _selectedBudget = val);
                                        _reload();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (waiting)
                      const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (hasError)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: errorColor, size: 40),
                              const SizedBox(height: 8),
                              Text(
                                snapshot.error.toString(),
                                style: const TextStyle(color: errorColor),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                  onPressed: _reload,
                                  child: const Text('Retry')),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${gigs.length} ${gigs.length == 1 ? 'gig' : 'gigs'} for your skills',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: mutedText,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _sortBy = _sortBy == 'Newest first'
                                        ? 'Highest budget'
                                        : 'Newest first';
                                  });
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      _sortBy,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: primaryBlue,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_downward,
                                      size: 15,
                                      color: primaryBlue,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (gigs.isEmpty)
                        SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'No matching gigs found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: darkText,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                      _selectedCategory = 'All categories';
                                      _selectedBudget = 'Any budget';
                                    });
                                    _reload();
                                  },
                                  child: const Text('Reset filters'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final gig = gigs[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: GigPostCard(
                                    gig: gig,
                                    formattedBudget: _formatNpr(gig.budgetNpr),
                                    softBlueBg: softBlueBg,
                                    onDetailsTap: () => _showGigDetails(gig),
                                  ),
                                );
                              },
                              childCount: gigs.length,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? const Color(0xFFDBEAFE) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? primaryBlue : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: isActive ? primaryBlue : const Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }
}
