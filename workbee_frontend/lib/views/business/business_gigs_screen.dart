import 'package:flutter/material.dart';

class BusinessGigsScreen extends StatefulWidget {
  final String businessName;
  final String location;

  const BusinessGigsScreen({
    super.key,
    this.businessName = 'Momo Junction',
    this.location = 'Baneshwor, Kathmandu',
  });

  @override
  State<BusinessGigsScreen> createState() => _BusinessGigsScreenState();
}

class _BusinessGigsScreenState extends State<BusinessGigsScreen> {
  final TextEditingController _titleController =
  TextEditingController(text: 'Tihar Offer Banner');
  final TextEditingController _descriptionController = TextEditingController(
    text:
    'Design a festive offer banner using our restaurant photos, logo and Tihar specials.',
  );
  final TextEditingController _skillsController =
  TextEditingController(text: 'Canva · Layout design');
  final TextEditingController _budgetController =
  TextEditingController(text: '2,000');
  final TextEditingController _deadlineController =
  TextEditingController(text: '23 Oct 2026');

  int _selectedNavIndex = 1;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _skillsController.dispose();
    _budgetController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const darkText = Color(0xFF0F172A);
    const mutedText = Color(0xFF64748B);
    const borderColor = Color(0xFFE2E8F0);
    const inputFill = Color(0xFFF8FAFC);

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

                  // Deadline
                  _LabeledBoxField(
                    label: 'Deadline',
                    controller: _deadlineController,
                    fillColor: inputFill,
                    borderColor: borderColor,
                  ),
                  const SizedBox(height: 16),

                  // Post New Gig Button (visual only for now)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
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
                  const Row(
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
                        '3 total',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: mutedText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Existing Gig 1: Open
                  const _ExistingGigCard(
                    title: 'Restaurant Social Media Design',
                    meta: 'NPR 3,000 · Remote · 7 days · Due 21 Oct 2026',
                    statusText: 'Open',
                    statusBg: Color(0xFFEFF6FF),
                    statusColor: primaryBlue,
                  ),
                  const SizedBox(height: 12),

                  // Existing Gig 2: In Progress
                  const _ExistingGigCard(
                    title: 'Festive Menu Flyer',
                    meta: 'NPR 1,500 · Suman Karki · Due 16 Oct 2026',
                    statusText: 'In Progress',
                    statusBg: Color(0xFFFEF3C7),
                    statusColor: Color(0xFFB45309),
                  ),
                  const SizedBox(height: 12),

                  // Existing Gig 3: Closed
                  const _ExistingGigCard(
                    title: 'Weekend Photo Shoot',
                    meta: 'NPR 2,500 · Closed without hiring',
                    statusText: 'Closed',
                    statusBg: Color(0xFFFEF3C7),
                    statusColor: Color(0xFFB45309),
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
                selected: _selectedNavIndex == 0,
                onTap: () => setState(() => _selectedNavIndex = 0),
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