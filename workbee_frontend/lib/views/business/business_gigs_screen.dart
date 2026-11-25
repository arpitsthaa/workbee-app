import 'package:flutter/material.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/services/auth_service.dart';

class BusinessGigsScreen extends StatefulWidget {
  final String businessName;
  final String location;

  const BusinessGigsScreen({
    super.key,
    this.businessName = 'My Business',
    this.location = '',
  });

  @override
  State<BusinessGigsScreen> createState() => _BusinessGigsScreenState();
}

class _BusinessGigsScreenState extends State<BusinessGigsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  int _selectedNavIndex = 1;
  bool _isLoading = true;
  bool _isPosting = false;
  String? _errorMessage;
  String? _postSuccessMessage;
  List<Gig> _gigs = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _skillsController.dispose();
    _budgetController.dispose();
    _deadlineController.dispose();
    _locationController.dispose();
    super.dispose();
  }

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
      final result = await AuthService().getBusinessGigs();

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
      setState(() {
        _errorMessage = 'Connection error: $e';
        _isLoading = false;
      });
    }
  }

  List<String> _parseSkills(String raw) {
    return raw
        .split(RegExp(r'[·,]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  // Convert common date inputs (YYYY-MM-DD, DD/MM/YYYY, DD-MM-YYYY, etc.) to YYYY-MM-DD.
  String? _formatDeadline(String raw) {
    final trimmed = raw.trim();
    final reg = RegExp(r'^(\d{1,2})[/-](\d{1,2})[/-](\d{4})$');
    final match = reg.firstMatch(trimmed);
    if (match == null) {
      // Already YYYY-MM-DD?
      final iso = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$');
      final isoMatch = iso.firstMatch(trimmed);
      if (isoMatch != null) return trimmed;
      return null;
    }
    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);
    // Validate ranges
    if (day < 1 || day > 31 || month < 1 || month > 12) return null;
    return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  // Open Flutter's built-in date picker to select the deadline date.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _deadlineController.text =
            '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  (Color bgColor, Color textColor) _statusStyle(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return (const Color(0xFFEFF6FF), const Color(0xFF1D61E7));
      case 'IN_PROGRESS':
        return (const Color(0xFFFEF3C7), const Color(0xFFB45309));
      case 'CLOSED':
        return (const Color(0xFFF1F5F9), const Color(0xFF64748B));
      default:
        return (const Color(0xFFF1F5F9), const Color(0xFF64748B));
    }
  }

  Future<void> _postGig() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final skillsRaw = _skillsController.text.trim();
    final budgetRaw = _budgetController.text.trim().replaceAll(',', '');
    final deadlineRaw = _deadlineController.text.trim();
    final locationRaw = _locationController.text.trim();

    if (title.isEmpty) {
      setState(() => _errorMessage = 'Please enter a gig title.');
      return;
    }
    if (description.isEmpty) {
      setState(() => _errorMessage = 'Please enter a description.');
      return;
    }
    if (skillsRaw.isEmpty) {
      setState(() => _errorMessage = 'Please enter required skills.');
      return;
    }
    if (locationRaw.isEmpty) {
      setState(() => _errorMessage = 'Please enter a location.');
      return;
    }
    if (budgetRaw.isEmpty || int.tryParse(budgetRaw) == null) {
      setState(() => _errorMessage = 'Please enter a valid budget (NPR).');
      return;
    }
    if (deadlineRaw.isEmpty) {
      setState(() => _errorMessage = 'Please enter a deadline.');
      return;
    }

    final deadline = _formatDeadline(deadlineRaw);
    if (deadline == null) {
      setState(() =>
          _errorMessage = 'Invalid deadline date. Use YYYY-MM-DD (e.g. 2026-10-23).');
      return;
    }

    setState(() {
      _isPosting = true;
      _errorMessage = null;
      _postSuccessMessage = null;
    });

    try {
      final result = await AuthService().postBusinessGig({
        'title': title,
        'description': description,
        'required_skills': _parseSkills(skillsRaw),
        'budget_npr': int.parse(budgetRaw),
        'duration_days': 7,
        'deadline': deadline,
        'location': locationRaw,
        'is_remote': true,
        'category': 'Design & creative',
        'deliverables': [],
      });

      if (result.containsKey('error')) {
        setState(() {
          _errorMessage = result['error'] as String?;
          _isPosting = false;
        });
        return;
      }

      setState(() {
        _isPosting = false;
        _postSuccessMessage = 'Gig posted successfully!';
        _errorMessage = null;
      });

      // Clear form
      _titleController.clear();
      _descriptionController.clear();
      _skillsController.clear();
      _budgetController.clear();
      _deadlineController.clear();
      _locationController.clear();

      // Refresh gig list
      _loadGigs();
    } catch (e) {
      setState(() {
        _isPosting = false;
        _errorMessage = 'Connection error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const darkText = Color(0xFF0F172A);
    const mutedText = Color(0xFF64748B);
    const borderColor = Color(0xFFE2E8F0);
    const inputFill = Color(0xFFF8FAFC);

    // Loading state
    if (_isLoading && _gigs.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading gigs...',
                      style: TextStyle(color: mutedText, fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _bottomNav(),
      );
    }

    // Error state (with gigs possibly empty)
    if (_errorMessage != null && _gigs.isEmpty) {
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
                    'Failed to load gigs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: mutedText, fontSize: 13),
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'My Gigs',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.businessName} · ${widget.location}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: mutedText,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section Title
                  const Text(
                    'Post New Gig',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Gig Title
                  _LabeledBoxField(
                    label: 'Gig title',
                    controller: _titleController,
                    fillColor: inputFill,
                    borderColor: borderColor,
                  ),
                  const SizedBox(height: 10),

                  // Description
                  _LabeledBoxField(
                    label: 'Description',
                    controller: _descriptionController,
                    fillColor: inputFill,
                    borderColor: borderColor,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),

                  // Required Skills
                  _LabeledBoxField(
                    label: 'Required skills',
                    controller: _skillsController,
                    fillColor: inputFill,
                    borderColor: borderColor,
                  ),
                  const SizedBox(height: 10),

                  // Budget (NPR)
                  _LabeledBoxField(
                    label: 'Budget (NPR)',
                    controller: _budgetController,
                    fillColor: inputFill,
                    borderColor: borderColor,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),

                  // Deadline (nicer date picker UI)
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Deadline',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _deadlineController.text.isEmpty
                                      ? 'Select a date'
                                      : _deadlineController.text,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    color: _deadlineController.text.isEmpty
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF0F172A),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            size: 20,
                            color: Color(0xFF64748B),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Location
                  _LabeledBoxField(
                    label: 'Location',
                    controller: _locationController,
                    fillColor: inputFill,
                    borderColor: borderColor,
                  ),
                  const SizedBox(height: 16),

                  // Post result message
                  if (_postSuccessMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Color(0xFF15803D), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _postSuccessMessage!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF166534),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_postSuccessMessage != null)
                    const SizedBox(height: 12),

                  // Error message
                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Color(0xFFB91C1C), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF991B1B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_errorMessage != null)
                    const SizedBox(height: 12),

                  // Post New Gig Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isPosting ? null : _postGig,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isPosting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text(
                              'Post New Gig',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Existing Gigs Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Existing Gigs',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: darkText,
                        ),
                      ),
                      Text(
                        '${_gigs.length} total',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: mutedText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Existing gigs list (live from API)
                  if (_gigs.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 48, color: const Color(0xFFCBD5E1)),
                          const SizedBox(height: 12),
                          Text(
                            'No gigs yet.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Post your first gig above to get started.',
                            style: TextStyle(
                              fontSize: 13,
                              color: mutedText,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._gigs.map((gig) {
                      final (bgColor, textColor) = _statusStyle(gig.status);
                      final statusLabel =
                          gig.status[0].toUpperCase() + gig.status.substring(1);
                      return Column(
                        children: [
                          _ExistingGigCard(
                            title: gig.title,
                            meta:
                                'NPR ${gig.budgetNpr} · ${gig.isRemote ? 'Remote' : 'On-site'} · ${gig.durationDays} days · Due ${gig.deadline}',
                            statusText: statusLabel,
                            statusBg: bgColor,
                            statusColor: textColor,
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _bottomNav(),
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

class _LabeledBoxField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color fillColor;
  final Color borderColor;
  final int maxLines;
  final TextInputType keyboardType;

  const _LabeledBoxField({
    required this.label,
    required this.controller,
    required this.fillColor,
    required this.borderColor,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 14.5,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 2),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExistingGigCard extends StatelessWidget {
  final String title;
  final String meta;
  final String statusText;
  final Color statusBg;
  final Color statusColor;

  const _ExistingGigCard({
    required this.title,
    required this.meta,
    required this.statusText,
    required this.statusBg,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);

    return Container(
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            meta,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: primaryBlue,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Row(
                  children: [
                    Text(
                      'Manage',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: primaryBlue,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 15, color: primaryBlue),
                  ],
                ),
              ),
            ],
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
