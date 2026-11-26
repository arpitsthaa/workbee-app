import 'package:flutter/material.dart';

class BusinessProjectsScreen extends StatefulWidget {
  final String businessName;
  final String location;
  final bool showNavBar;

  const BusinessProjectsScreen({
    super.key,
    this.businessName = 'Momo Junction',
    this.location = 'Baneshwor, Kathmandu',
    this.showNavBar = true,
  });

  @override
  State<BusinessProjectsScreen> createState() => _BusinessProjectsScreenState();
}

class _BusinessProjectsScreenState extends State<BusinessProjectsScreen> {
  static const _primaryBlue = Color(0xFF1D61E7);
  static const _softBlueBg = Color(0xFFEFF6FF);
  static const _darkText = Color(0xFF0F172A);
  static const _mutedText = Color(0xFF64748B);
  static const _borderColor = Color(0xFFE2E8F0);
  static const _lightSurface = Color(0xFFF8FAFC);

  final TextEditingController _reviewController = TextEditingController();

  String _aayushaStatus = 'Shortlisted';
  String _rohanStatus = 'Pending';
  String _projectStatus = 'In Progress';
  int _rating = 0;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canRate = _projectStatus == 'Approved';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.showNavBar
          ? AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _darkText,
        elevation: 0,
        title: const Text(
          'Applicants & Projects',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      )
          : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.businessName} · ${widget.location}',
                    style: const TextStyle(fontSize: 13, color: _mutedText),
                  ),
                  const SizedBox(height: 20),

                  // 1. Applicants
                  const Text(
                    '1. Review Applicants',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _darkText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ApplicantCard(
                    initials: 'AS',
                    name: 'Aayusha Shrestha',
                    subtitle: 'Canva · Social media design · ★ 4.9/5',
                    status: _aayushaStatus,
                    onAccept: () {
                      setState(() => _aayushaStatus = 'Accepted');
                      _showMessage('Accepted Aayusha Shrestha');
                    },
                    onReject: () {
                      setState(() => _aayushaStatus = 'Rejected');
                      _showMessage('Rejected Aayusha Shrestha');
                    },
                  ),
                  const SizedBox(height: 10),
                  _ApplicantCard(
                    initials: 'RA',
                    name: 'Rohan Adhikari',
                    subtitle: 'Canva · Illustration · ★ 4.7/5',
                    status: _rohanStatus,
                    onAccept: () {
                      setState(() => _rohanStatus = 'Accepted');
                      _showMessage('Accepted Rohan Adhikari');
                    },
                    onReject: () {
                      setState(() => _rohanStatus = 'Rejected');
                      _showMessage('Rejected Rohan Adhikari');
                    },
                  ),
                  const SizedBox(height: 24),

                  // 2. Active Project
                  const Text(
                    '2. Active Project',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _darkText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Festive Menu Flyer',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  color: _darkText,
                                ),
                              ),
                            ),
                            _StatusPill(
                              label: _projectStatus,
                              isHighlight: _projectStatus == 'Approved',
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Suman Karki · NPR 1,500 · menu-flyer-v1.pdf',
                          style: TextStyle(fontSize: 12.5, color: _mutedText),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 42,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() => _projectStatus = 'Approved');
                                    _showMessage('Project approved');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryBlue,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text('Approve Work'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 42,
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _projectStatus = 'Changes Requested';
                                    });
                                    _showMessage('Requested changes');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _primaryBlue,
                                    side: const BorderSide(color: _borderColor),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text('Request Changes'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Rate Student
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '3. Rate Student',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _darkText,
                        ),
                      ),
                      Text(
                        canRate ? 'Ready' : 'Approve work first',
                        style: const TextStyle(fontSize: 12, color: _mutedText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            final starValue = index + 1;
                            return IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 34,
                                minHeight: 34,
                              ),
                              onPressed: canRate
                                  ? () => setState(() => _rating = starValue)
                                  : null,
                              icon: Icon(
                                starValue <= _rating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: starValue <= _rating
                                    ? const Color(0xFFF59E0B)
                                    : _mutedText,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _reviewController,
                          enabled: canRate,
                          decoration: InputDecoration(
                            hintText: 'Write a short review...',
                            filled: true,
                            fillColor: _lightSurface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: _borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: _borderColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 42,
                          child: ElevatedButton(
                            onPressed: canRate
                                ? () {
                              _reviewController.clear();
                              _showMessage(
                                'Review submitted ($_rating/5 stars)',
                              );
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Submit Review'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final String initials;
  final String name;
  final String subtitle;
  final String status;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _ApplicantCard({
    required this.initials,
    required this.name,
    required this.subtitle,
    required this.status,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const softBlueBg = Color(0xFFEFF6FF);
    const darkText = Color(0xFF0F172A);
    const mutedText = Color(0xFF64748B);
    const borderColor = Color(0xFFE2E8F0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: softBlueBg,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
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
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: mutedText),
                    ),
                  ],
                ),
              ),
              _StatusPill(
                label: status,
                isHighlight: status == 'Accepted' || status == 'Shortlisted',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: mutedText,
                      side: const BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Reject'),
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

class _StatusPill extends StatelessWidget {
  final String label;
  final bool isHighlight;

  const _StatusPill({
    required this.label,
    required this.isHighlight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFFEFF6FF) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color:
          isHighlight ? const Color(0xFF1D61E7) : const Color(0xFFB45309),
        ),
      ),
    );
  }
}