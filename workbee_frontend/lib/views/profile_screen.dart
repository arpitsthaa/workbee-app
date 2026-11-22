import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workbee_frontend/services/auth_service.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/views/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  bool _isEditing = false;
  bool _isLoading = true;
  String? _error;

  ProfileResponse? _profile;

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _collegeController = TextEditingController();
  final _programController = TextEditingController();
  final _semesterController = TextEditingController();
  final _aboutController = TextEditingController();
  final _skillsController = TextEditingController();
  final _interestsController = TextEditingController();
  final _portfolioController = TextEditingController();

  List<String> _selectedInterests = [];
  final List<String> _interestOptions = [
    'Design & Creative',
    'Development & IT',
    'Content & Marketing',
    'Data & Analytics',
    'Admin & Operations',
    'Finance & Accounting',
    'Sales & Business Development',
    'Product Management',
    'UI/UX Design',
    'Video & Animation',
    'Writing & Translation',
    'Social Media',
    'SEO & SEM',
    'Photography',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _collegeController.dispose();
    _programController.dispose();
    _semesterController.dispose();
    _aboutController.dispose();
    _skillsController.dispose();
    _interestsController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final result = await _authService.getStudentProfile();
    if (!mounted) return;
    if (result.containsKey('error')) {
      setState(() {
        _error = result['error'] as String?;
        _isLoading = false;
      });
    } else {
      final profile = ProfileResponse.fromJson(result as Map<String, dynamic>);
      setState(() {
        _profile = profile;
        _nameController.text = profile.fullName;
        _locationController.text = profile.location ?? '';
        _collegeController.text = profile.collegeUniversity ?? '';
        _programController.text = profile.program;
        _semesterController.text = profile.semester;
        _aboutController.text = profile.bio;
        _skillsController.text = profile.skills.join(', ');
        _selectedInterests = List<String>.from(profile.interests);
        _portfolioController.text = profile.portfolioUrl;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    final data = {
      'full_name': _nameController.text.trim(),
      'location': _locationController.text.trim(),
      'college_university': _collegeController.text.trim(),
      'program': _programController.text.trim(),
      'semester': _semesterController.text.trim(),
      'bio': _aboutController.text.trim(),
      'skills': _skillsController.text.trim()
          .split(',')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim())
          .toList(),
      'interests': _selectedInterests,
      'portfolio_url': _portfolioController.text.trim(),
    };

    final result = await _authService.updateStudentProfile(data);
    if (!mounted) return;
    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] as String? ?? 'Save failed'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      setState(() => _isEditing = false);
      _loadProfile();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved')),
      );
    }
  }

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const softBlueBg = Color(0xFFEFF6FF);
    const darkText = Color(0xFF0F172A);
    const mutedText = Color(0xFF64748B);
    const borderColor = Color(0xFFE2E8F0);
    const inputFill = Color(0xFFF8FAFC);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadProfile,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final profile = _profile!;
    final skillsList = profile.skills;

    return SafeArea(
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
              const SizedBox(height: 24),

              // Profile Header with large avatar
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: softBlueBg,
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryBlue, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            profile.fullName.isNotEmpty
                                ? profile.fullName[0].toUpperCase()
                                : 'A',
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              color: primaryBlue,
                            ),
                          ),
                        ),
                        if (_isEditing)
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          profile.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                        if (profile.isVerified) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: softBlueBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified, size: 14, color: primaryBlue),
                                const SizedBox(width: 4),
                                const Text(
                                  'Verified',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.location ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: mutedText,
                      ),
                    ),
                    if (profile.email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        profile.email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: mutedText,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (!_isEditing)
                      TextButton.icon(
                        onPressed: () => setState(() => _isEditing = true),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: primaryBlue,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Education Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school_outlined, size: 18, color: mutedText),
                        const SizedBox(width: 8),
                        const Text(
                          'Education',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_isEditing) ...[
                      TextField(
                        controller: _collegeController,
                        decoration: InputDecoration(
                          labelText: 'College / University',
                          hintText: 'e.g., Tribhuvan University',
                          filled: true,
                          fillColor: inputFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: primaryBlue, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _programController,
                              decoration: InputDecoration(
                                labelText: 'Program',
                                hintText: 'e.g., BCA',
                                filled: true,
                                fillColor: inputFill,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: primaryBlue, width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _semesterController,
                              decoration: InputDecoration(
                                labelText: 'Semester',
                                hintText: 'e.g., Semester 4',
                                filled: true,
                                fillColor: inputFill,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: primaryBlue, width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        profile.collegeUniversity ?? 'Not set',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${profile.program} · ${profile.semester}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: mutedText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Profile Completion
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: softBlueBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Profile Completion',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: darkText,
                          ),
                        ),
                        Text(
                          '${profile.profileCompletion}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: profile.profileCompletion / 100,
                        minHeight: 6,
                        backgroundColor: borderColor,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.profileCompletion == 100
                          ? 'Profile complete! Ready for verification.'
                          : 'Complete your profile to stand out and get verified.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: mutedText,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // About Me
              _buildSectionHeader('About me'),
              const SizedBox(height: 8),
              if (_isEditing)
                TextField(
                  controller: _aboutController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Tell us about yourself...',
                    filled: true,
                    fillColor: inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryBlue, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                )
              else
                Text(
                  profile.bio.isEmpty ? 'No bio added yet.' : profile.bio,
                  style: const TextStyle(fontSize: 14, color: mutedText, height: 1.5),
                ),

              const SizedBox(height: 20),

              // Skills
              _buildSectionHeader('Skills'),
              const SizedBox(height: 8),
              if (_isEditing)
                TextField(
                  controller: _skillsController,
                  decoration: InputDecoration(
                    labelText: 'Skills (separate with commas)',
                    hintText: 'e.g., Figma, Canva, Photoshop',
                    filled: true,
                    fillColor: inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryBlue, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skillsList.isEmpty
                      ? [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'No skills added',
                              style: TextStyle(fontSize: 13, color: mutedText),
                            ),
                          ),
                        ]
                      : skillsList
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

              const SizedBox(height: 20),

              // Interests
              _buildSectionHeader('Interests'),
              const SizedBox(height: 8),
              if (_isEditing) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _interestOptions.map((interest) {
                    final isSelected = _selectedInterests.contains(interest);
                    return FilterChip(
                      label: Text(interest),
                      selected: isSelected,
                      onSelected: (_) => _toggleInterest(interest),
                      selectedColor: softBlueBg,
                      checkmarkColor: primaryBlue,
                      labelStyle: TextStyle(
                        color: isSelected ? primaryBlue : mutedText,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      backgroundColor: inputFill,
                      side: BorderSide(
                        color: isSelected ? primaryBlue : borderColor,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _interestsController,
                  decoration: InputDecoration(
                    labelText: 'Add custom interest',
                    hintText: 'Type and press Enter',
                    filled: true,
                    fillColor: inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryBlue, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                  onSubmitted: (value) {
                    final trimmed = value.trim();
                    if (trimmed.isNotEmpty && !_selectedInterests.contains(trimmed)) {
                      setState(() => _selectedInterests.add(trimmed));
                      _interestsController.clear();
                    }
                  },
                ),
              ] else ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedInterests.isEmpty
                      ? [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'No interests selected',
                              style: TextStyle(fontSize: 13, color: mutedText),
                            ),
                          ),
                        ]
                      : _selectedInterests
                          .map(
                            (interest) => Chip(
                              label: Text(
                                interest,
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
              ],

              const SizedBox(height: 20),

              // Portfolio
              _buildSectionHeader('Portfolio'),
              const SizedBox(height: 8),
              if (_isEditing)
                TextField(
                  controller: _portfolioController,
                  decoration: InputDecoration(
                    labelText: 'Portfolio URL',
                    hintText: 'https://your-portfolio.com',
                    filled: true,
                    fillColor: inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryBlue, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    prefixIcon: const Icon(Icons.link, color: mutedText),
                  ),
                  keyboardType: TextInputType.url,
                )
              else
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
                        profile.portfolioUrl.isEmpty ? 'No portfolio link added' : profile.portfolioUrl,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Recent Activity
              _buildSectionHeader('Recent Activity'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Verified Projects',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to passport screen - handled by bottom nav
                          },
                          child: Text(
                            'View all',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete gigs to build your verified work history',
                      style: TextStyle(
                        fontSize: 13,
                        color: mutedText,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              if (_isEditing) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _isEditing = false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: borderColor),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _isEditing = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text(
                    'Log out',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFFECACA)),
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
    );
  }

  Widget _buildSectionHeader(String title) {
    const darkText = Color(0xFF0F172A);
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: darkText,
      ),
    );
  }
}