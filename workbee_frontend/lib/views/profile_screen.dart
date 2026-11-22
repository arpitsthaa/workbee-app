import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  String _name = 'Anisha Shrestha';
  String _location = 'Patan, Lalitpur';
  String _college = 'Patan Multiple Campus';
  String _course = 'BCA · Semester 4';
  String _about =
      'BCA student creating clear, thoughtful designs for local businesses.';
  String _skillsText = 'Canva, Figma, Social media design';
  String _portfolio = 'behance.net/aayushashrestha';

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _collegeController = TextEditingController();
  final _courseController = TextEditingController();
  final _aboutController = TextEditingController();
  final _skillsController = TextEditingController();
  final _portfolioController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _collegeController.dispose();
    _courseController.dispose();
    _aboutController.dispose();
    _skillsController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  void _openEdit() {
    _nameController.text = _name;
    _locationController.text = _location;
    _collegeController.text = _college;
    _courseController.text = _course;
    _aboutController.text = _about;
    _skillsController.text = _skillsText;
    _portfolioController.text = _portfolio;
    setState(() => _isEditing = true);
  }

  void _saveEdit() {
    setState(() {
      if (_nameController.text.trim().isNotEmpty) {
        _name = _nameController.text.trim();
      }
      _location = _locationController.text.trim();
      _college = _collegeController.text.trim();
      _course = _courseController.text.trim();
      _about = _aboutController.text.trim();
      _skillsText = _skillsController.text.trim();
      _portfolio = _portfolioController.text.trim();
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const softBlueBg = Color(0xFFEFF6FF);
    const darkText = Color(0xFF0F172A);
    const mutedText = Color(0xFF64748B);
    const borderColor = Color(0xFFE2E8F0);

    final skillsList = _skillsText
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My profile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your skills. Your student identity.',
                  style: TextStyle(fontSize: 14, color: mutedText),
                ),
                const SizedBox(height: 20),

                if (_isEditing) ...[
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _collegeController,
                    decoration: const InputDecoration(labelText: 'College'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _courseController,
                    decoration:
                    const InputDecoration(labelText: 'Course & semester'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _aboutController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'About me'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _skillsController,
                    decoration: const InputDecoration(
                      labelText: 'Skills (separate with commas)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _portfolioController,
                    decoration:
                    const InputDecoration(labelText: 'Portfolio link'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _isEditing = false),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveEdit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Name & Location
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: softBlueBg,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _name.isNotEmpty ? _name[0].toUpperCase() : 'A',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                            ),
                          ),
                          Text(
                            _location,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: mutedText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // College Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _college,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _course,
                          style: const TextStyle(
                            fontSize: 13,
                            color: mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // About Me
                  const Text(
                    'About me',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _about,
                    style: const TextStyle(fontSize: 14, color: mutedText),
                  ),
                  const SizedBox(height: 18),

                  // Skills
                  const Text(
                    'Skills',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: skillsList
                        .map(
                          (skill) => Chip(
                        label: Text(
                          skill,
                          style: const TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: softBlueBg,
                        side: BorderSide.none,
                      ),
                    )
                        .toList(),
                  ),
                  const SizedBox(height: 18),

                  // Portfolio
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Portfolio',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _portfolio,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _openEdit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Edit Profile'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}