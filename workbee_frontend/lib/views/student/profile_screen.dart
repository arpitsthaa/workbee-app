import 'package:flutter/material.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/services/auth_service.dart';
import 'package:workbee_frontend/services/user_session_service.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/views/auth/login_screen.dart';

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
  final _courseController = TextEditingController();
  final _aboutController = TextEditingController();
  final _skillsController = TextEditingController();
  final _portfolioController = TextEditingController();

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
    _courseController.dispose();
    _aboutController.dispose();
    _skillsController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    // First, populate from local session for instant display
    final session = UserSessionService();
    if (session.isInitialized) {
      _nameController.text = session.userName ?? '';
      _locationController.text = session.location ?? '';
      _collegeController.text = session.collegeUniversity ?? '';
      final program = session.program ?? '';
      final semester = session.semester ?? '';
      _courseController.text = (program.isNotEmpty && semester.isNotEmpty)
          ? '$program · $semester'
          : (program.isNotEmpty ? program : (semester.isNotEmpty ? semester : ''));
      _aboutController.text = session.bio ?? '';
      _skillsController.text = session.skills.join(', ');
      _portfolioController.text = session.portfolioUrl ?? '';
    }

    // Then fetch fresh data from API
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
        _courseController.text = '${profile.program} · ${profile.semester}'.trim();
        _aboutController.text = profile.bio;
        _skillsController.text = profile.skills.join(', ');
        _portfolioController.text = profile.portfolioUrl;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    final portfolioUrl = _portfolioController.text.trim();
    if (portfolioUrl.isNotEmpty && !_isValidUrl(portfolioUrl)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid URL (e.g., example.com or https://example.com)'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final data = {
      'full_name': _nameController.text.trim(),
      'location': _locationController.text.trim(),
      'college_university': _collegeController.text.trim(),
      'program': _courseController.text.trim().split(' · ').first,
      'semester': _courseController.text.trim().split(' · ').length > 1
          ? _courseController.text.trim().split(' · ').last
          : '',
      'bio': _aboutController.text.trim(),
      'skills': _skillsController.text.trim().split(',').where((s) => s.trim().isNotEmpty).map((s) => s.trim()).toList(),
      'portfolio_url': portfolioUrl,
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
      final skillsList = _skillsController.text.trim().split(',').where((s) => s.trim().isNotEmpty).map((s) => s.trim()).toList();
      await UserSessionService().updateProfile(
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        collegeUniversity: _collegeController.text.trim(),
        program: _courseController.text.trim().split(' · ').first,
        semester: _courseController.text.trim().split(' · ').length > 1
            ? _courseController.text.trim().split(' · ').last
            : '',
        bio: _aboutController.text.trim(),
        skills: skillsList,
        portfolioUrl: portfolioUrl,
      );
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved')),
      );
    }
  }

  bool _isValidUrl(String url) {
    // Lenient URL validation: accepts http://, https://, or just domain.tld
    final regex = RegExp(
      r'^(https?://)?([\w-]+\.)+[\w-]+(/[\w-./?%&=]*)?$',
      caseSensitive: false,
    );
    return regex.hasMatch(url);
  }

  void _handleLogout() async {
    await UserSessionService().clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
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

    return SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isEditing) _buildEditForm() else _buildViewMode(),
                ],
              ),
            ),
          ),
        );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          decoration: const InputDecoration(
            labelText: 'Course & semester',
          ),
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
          decoration: const InputDecoration(
            labelText: 'Portfolio link',
          ),
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
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileHeader(),
        const SizedBox(height: 18),
        _buildCollegeInfoCard(),
        const Text(
          'About me',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 6),
        _buildAboutSection(),
        const SizedBox(height: 18),
        const Text(
          'Skills',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 8),
        _buildSkillsSection(),
        const SizedBox(height: 18),
        _buildPortfolioSection(),
        const SizedBox(height: 18),
        _buildRecentActivity(),
        const SizedBox(height: 22),
        _buildEditProfileButton(),
        const SizedBox(height: 12),
        _buildLogoutButton(),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return ListenableBuilder(
      listenable: UserSessionService(),
      builder: (context, _) {
        final session = UserSessionService();
        final displayName = session.userName ?? _profile!.fullName;
        final displayLocation = session.location ?? _profile!.location ?? '';
        return Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.softBlueBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    displayName.isNotEmpty
                        ? displayName[0].toUpperCase()
                        : 'A',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                        if (_profile!.isVerified) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.softBlueBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified, size: 12, color: AppColors.primaryBlue),
                                const SizedBox(width: 4),
                                const Text(
                                  'Verified',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayLocation,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.mutedText,
                      ),
                    ),
                    if (_profile!.email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        _profile!.email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildCollegeInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListenableBuilder(
            listenable: UserSessionService(),
            builder: (context, _) {
              final session = UserSessionService();
              final displayCollege = session.collegeUniversity ?? _profile!.collegeUniversity ?? '';
              final displayProgram = session.program ?? _profile!.program;
              final displaySemester = session.semester ?? _profile!.semester;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayCollege,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$displayProgram · $displaySemester',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return ListenableBuilder(
      listenable: UserSessionService(),
      builder: (context, _) {
        final session = UserSessionService();
        final displayBio = session.bio ?? _profile!.bio;
        return Text(
          displayBio,
          style: const TextStyle(fontSize: 14, color: AppColors.mutedText),
        );
      },
    );
  }

  Widget _buildSkillsSection() {
    return ListenableBuilder(
      listenable: UserSessionService(),
      builder: (context, _) {
        final session = UserSessionService();
        final displaySkills = session.skills.isNotEmpty ? session.skills : _profile!.skills;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: displaySkills
              .map(
                (skill) => Chip(
                  label: Text(
                    skill,
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: AppColors.softBlueBg,
                  side: BorderSide.none,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildPortfolioSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Portfolio',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          ListenableBuilder(
            listenable: UserSessionService(),
            builder: (context, _) {
              final session = UserSessionService();
              final displayPortfolio = session.portfolioUrl ?? _profile!.portfolioUrl;
              return Text(
                displayPortfolio,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.primaryBlue,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
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
                      color: AppColors.darkText,
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
                        color: AppColors.primaryBlue,
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
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditProfileButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => setState(() => _isEditing = true),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
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
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
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
          foregroundColor: AppColors.errorRedDark,
          side: const BorderSide(color: AppColors.errorRedLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
