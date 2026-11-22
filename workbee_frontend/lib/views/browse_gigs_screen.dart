import 'package:flutter/material.dart';

class GigItem {
  final String id;
  final String businessName;
  final String title;
  final String category;
  final String skillsTag;
  final int budgetNpr;
  final String duration;
  final String dueDate;
  final String location;
  final String workMode;
  final String description;
  final DateTime postedAt;

  const GigItem({
    required this.id,
    required this.businessName,
    required this.title,
    required this.category,
    required this.skillsTag,
    required this.budgetNpr,
    required this.duration,
    required this.dueDate,
    required this.location,
    required this.workMode,
    required this.description,
    required this.postedAt,
  });
}

class BrowseGigsScreen extends StatefulWidget {
  const BrowseGigsScreen({super.key});

  @override
  State<BrowseGigsScreen> createState() => _BrowseGigsScreenState();
}

class _BrowseGigsScreenState extends State<BrowseGigsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'Design & creative';
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

  // Sample dynamic data (replace with API response later)
  final List<GigItem> _allGigs = [
    GigItem(
      id: '1',
      businessName: 'Momo Junction',
      title: 'Restaurant Social Media Design',
      category: 'Design & creative',
      skillsTag: 'Canva · Social media design',
      budgetNpr: 3000,
      duration: '7 days',
      dueDate: 'Due 21 Oct',
      location: 'Baneshwor, Kathmandu',
      workMode: 'Remote-friendly',
      description:
      'Create 6 engaging Instagram & Facebook promotional posts for our Dashain & Tihar combo menu using Canva.',
      postedAt: DateTime(2026, 10, 14),
    ),
    GigItem(
      id: '2',
      businessName: 'Local Loom',
      title: 'Product Photo Editing',
      category: 'Design & creative',
      skillsTag: 'Canva · Photo editing',
      budgetNpr: 2500,
      duration: '5 days',
      dueDate: 'Due 19 Oct',
      location: 'Patan, Lalitpur',
      workMode: 'Remote-friendly',
      description:
      'Clean up backgrounds, adjust lighting, and resize 20 handwoven product photos for our online store.',
      postedAt: DateTime(2026, 10, 13),
    ),
    GigItem(
      id: '3',
      businessName: 'Himalayan Roast Coffee',
      title: 'Menu & Flyer Layout',
      category: 'Design & creative',
      skillsTag: 'Figma · Print layout',
      budgetNpr: 4500,
      duration: '6 days',
      dueDate: 'Due 24 Oct',
      location: 'Jhamsikhel, Lalitpur',
      workMode: 'Hybrid',
      description:
      'Redesign our A4 café menu and takeaway promotional flyer with clean typography and product photos.',
      postedAt: DateTime(2026, 10, 12),
    ),
    GigItem(
      id: '4',
      businessName: 'TechNova Nepal',
      title: 'Landing Page UI Fix',
      category: 'Development & IT',
      skillsTag: 'HTML/CSS · Responsive UI',
      budgetNpr: 6000,
      duration: '5 days',
      dueDate: 'Due 22 Oct',
      location: 'Putalisadak, Kathmandu',
      workMode: 'Remote-friendly',
      description:
      'Fix mobile responsiveness issues and improve button spacing on our company landing page.',
      postedAt: DateTime(2026, 10, 15),
    ),
    GigItem(
      id: '5',
      businessName: 'Kathmandu Books',
      title: 'Instagram Reels Caption & Copy',
      category: 'Content & marketing',
      skillsTag: 'Copywriting · Social media',
      budgetNpr: 2000,
      duration: '4 days',
      dueDate: 'Due 18 Oct',
      location: 'Thamel, Kathmandu',
      workMode: 'Remote-friendly',
      description:
      'Write 10 short, catchy Nepali-English captions for our upcoming book review reels.',
      postedAt: DateTime(2026, 10, 11),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<GigItem> get _filteredGigs {
    final query = _searchQuery.toLowerCase().trim();

    final results = _allGigs.where((gig) {
      // Search filter
      final matchesSearch = query.isEmpty ||
          gig.title.toLowerCase().contains(query) ||
          gig.businessName.toLowerCase().contains(query) ||
          gig.skillsTag.toLowerCase().contains(query) ||
          gig.location.toLowerCase().contains(query);

      // Category filter
      final matchesCategory = _selectedCategory == 'All categories' ||
          gig.category == _selectedCategory;

      // Budget filter
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

    // Sort logic
    if (_sortBy == 'Newest first') {
      results.sort((a, b) => b.postedAt.compareTo(a.postedAt));
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

  void _showGigDetails(GigItem gig) {
    const primaryBlue = Color(0xFF1D61E7);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                  gig.skillsTag,
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
                      '${gig.duration} · ${gig.dueDate}',
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
                      '${gig.location} · ${gig.workMode}',
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
                Text(
                  gig.description,
                  style: const TextStyle(
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
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text('Applied to "${gig.title}"!'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
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
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const softBlueBg = Color(0xFFEFF6FF);
    const darkText = Color(0xFF0F172A);
    const mutedText = Color(0xFF64748B);
    const borderColor = Color(0xFFE2E8F0);

    final gigs = _filteredGigs;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text(
                      'Browse gigs',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Small projects. Real experience.',
                      style: TextStyle(
                        fontSize: 14,
                        color: mutedText,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Search Bar
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

                    // Filter Pills Row
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
                              onSelected: (val) =>
                                  setState(() => _selectedCategory = val),
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
                              onSelected: (val) =>
                                  setState(() => _selectedBudget = val),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Count & Sort Row
                    Row(
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
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // Dynamic Gig List
              Expanded(
                child: gigs.isEmpty
                    ? Center(
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
                        },
                        child: const Text('Reset filters'),
                      ),
                    ],
                  ),
                )
                    : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  itemCount: gigs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final gig = gigs[index];
                    return _BrowseGigCard(
                      gig: gig,
                      formattedBudget: _formatNpr(gig.budgetNpr),
                      softBlueBg: softBlueBg,
                      onDetailsTap: () => _showGigDetails(gig),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// REUSABLE WIDGETS
// ---------------------------------------------------------------------------

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

class _BrowseGigCard extends StatelessWidget {
  final GigItem gig;
  final String formattedBudget;
  final Color softBlueBg;
  final VoidCallback onDetailsTap;

  const _BrowseGigCard({
    required this.gig,
    required this.formattedBudget,
    required this.softBlueBg,
    required this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const mutedText = Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            gig.businessName,
            style: const TextStyle(
              fontSize: 13,
              color: mutedText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            gig.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            gig.skillsTag,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedBudget,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: primaryBlue,
                ),
              ),
              Text(
                '${gig.duration} · ${gig.dueDate}',
                style: const TextStyle(
                  fontSize: 13,
                  color: mutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: mutedText,
              ),
              const SizedBox(width: 4),
              Text(
                gig.location,
                style: const TextStyle(
                  fontSize: 13,
                  color: mutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                gig.workMode,
                style: const TextStyle(
                  fontSize: 13,
                  color: mutedText,
                ),
              ),
              InkWell(
                onTap: onDetailsTap,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: softBlueBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Details',
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}