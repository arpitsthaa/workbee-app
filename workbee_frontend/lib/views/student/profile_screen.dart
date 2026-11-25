import 'package:flutter/material.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/services/auth_service.dart';
import 'package:workbee_frontend/services/user_session_service.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/views/auth/login_screen.dart';
import 'package:workbee_frontend/widgets/app_message.dart';
import 'package:workbee_frontend/widgets/loading_state.dart';
import 'package:workbee_frontend/widgets/error_retry_state.dart';
import 'package:workbee_frontend/widgets/student_profile_header.dart';

/// The student profile screen.
///
/// Shows read-only profile info by default. Tapping "Edit Profile" opens an
/// editable form. Changes are saved to the API and the local session.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Service used to fetch/update profile data from the API.
  final AuthService _authService = AuthService();

  // -------------------------------------------------------------------------
  // UI STATE
  // -------------------------------------------------------------------------
  // When true, shows the edit form. When false, shows the read-only view.
  bool _isEditing = false;

  // When true, data is being fetched from the API.
  bool _isLoading = true;

  // Error message if the API call fails.
  String? _error;

  // The profile data fetched from the API.
  ProfileResponse? _profile;

  // -------------------------------------------------------------------------
  // TEXT CONTROLLERS (one per editable field)
  // -------------------------------------------------------------------------
  // These hold what the user types. Must be disposed in dispose().
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
    // Dispose all text controllers to free memory.
    _nameController.dispose();
    _locationController.dispose();
    _collegeController.dispose();
    _courseController.dispose();
    _aboutController.dispose();
    _skillsController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  // =========================================================================
  // DATA LOADING
  // =========================================================================

  /// Loads the profile: first shows session data (instant), then fetches fresh data from the API.
  Future<void> _loadProfile() async {
    // Step 1: Populate fields from local session for instant display.
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

    // Step 2: Fetch fresh data from the API and overwrite the fields.
    final result = await _authService.getStudentProfile();
    if (!mounted) return;
    if (result.containsKey('error')) {
      setState(() {
        _error = result['error'] as String?;
        _isLoading = false;
      });
    } else {
      final profile = ProfileResponse.fromJson(result);
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

  // =========================================================================
  // SAVE PROFILE
  // =========================================================================

  /// Saves the edited profile to the API and updates the local session.
  Future<void> _saveProfile() async {
    final portfolioUrl = _portfolioController.text.trim();

    // Validate the portfolio URL if it's not empty.
    if (portfolioUrl.isNotEmpty && !_isValidUrl(portfolioUrl)) {
      if (!mounted) return;
      showWorkBeeMessage(
        context,
        message: 'Please enter a valid URL (e.g., example.com or https://example.com)',
        isError: true,
      );
      return;
    }

    // Build the data map to send to the API.
    // The "Course & semester" field stores both values separated by " · ",
    // so we split them back into separate program/semester fields for the API.
    final courseText = _courseController.text.trim();
    final courseParts = courseText.split(' · ');
    final program = courseParts.isNotEmpty ? courseParts.first : '';
    final semester = courseParts.length > 1 ? courseParts.last : '';

    // Build the skills list from the comma-separated input.
    final skillsList = _skillsController.text.trim().split(',')
        .where((s) => s.trim().isNotEmpty)
        .map((s) => s.trim())
        .toList();

    final data = {
      'full_name': _nameController.text.trim(),
      'location': _locationController.text.trim(),
      'college_university': _collegeController.text.trim(),
      'program': program,
      'semester': semester,
      'bio': _aboutController.text.trim(),
      'skills': skillsList,
      'portfolio_url': portfolioUrl,
    };

    // Send the update to the API.
    final result = await _authService.updateStudentProfile(data);
    if (!mounted) return;

    if (result.containsKey('error')) {
      if (!mounted) return;
      showWorkBeeMessage(
        context,
        message: result['error'] as String? ?? 'Save failed',
        isError: true,
      );
    } else {
      // Update the local session so the change shows up instantly elsewhere.
      await UserSessionService().updateProfile(
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        collegeUniversity: _collegeController.text.trim(),
        program: program,
        semester: semester,
        bio: _aboutController.text.trim(),
        skills: skillsList,
        portfolioUrl: portfolioUrl,
      );
      if (!mounted) return;
      setState(() => _isEditing = false);
      showWorkBeeMessage(
        context,
        message: 'Profile saved',
      );
    }
  }

  /// Simple check: accepts http://, https://, or just domain.tld
  bool _isValidUrl(String url) {
    final regex = RegExp(
      r'^(https?://)?([\w-]+\.)+[\w-]+(/[\w-./?%&=]*)?$',
      caseSensitive: false,
    );
    return regex.hasMatch(url);
  }

  // =========================================================================
  // LOGOUT
  // =========================================================================

  /// Clears the session and sends the user back to the login screen.
  void _handleLogout() async {
    await UserSessionService().clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  // =========================================================================
  // UI BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    // Show loading spinner while fetching data.
    if (_isLoading) {
      return const LoadingState();
    }

    // Show error state if loading failed.
    if (_error != null) {
      return ErrorRetryState(
        error: _error!,
        onRetry: _loadProfile,
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
              // Show either the edit form or the read-only view.
              if (_isEditing) _buildEditForm() else _buildViewMode(),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // EDIT FORM (shown when _isEditing is true)
  // -------------------------------------------------------------------------

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

  // -------------------------------------------------------------------------
  // VIEW MODE (read-only profile)
  // -------------------------------------------------------------------------

  Widget _buildViewMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileHeader(),
        const SizedBox(height: 18),
        _buildCollegeInfoCard(),
        const SizedBox(height: 18),
        _buildSectionTitle('About me'),
        const SizedBox(height: 6),
        _buildAboutSection(),
        const SizedBox(height: 18),
        _buildSectionTitle('Skills'),
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

  /// Builds a section title (e.g. "About me", "Skills").
  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.darkText,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PROFILE HEADER (avatar + name + verified badge + location + email)
  // -------------------------------------------------------------------------

  Widget _buildProfileHeader() {
    return ListenableBuilder(
      listenable: UserSessionService(),
      builder: (context, _) {
        final session = UserSessionService();
        final displayName = session.userName ?? _profile!.fullName;
        final displayLocation = session.location ?? _profile!.location ?? '';
        return StudentProfileHeader(
          displayName: displayName,
          location: displayLocation,
          email: _profile!.email,
          isVerified: _profile!.isVerified,
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // COLLEGE INFO CARD
  // -------------------------------------------------------------------------

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

  // -------------------------------------------------------------------------
  // ABOUT SECTION
  // -------------------------------------------------------------------------

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

  // -------------------------------------------------------------------------
  // SKILLS SECTION (chips)
  // -------------------------------------------------------------------------

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

  // -------------------------------------------------------------------------
  // PORTFOLIO SECTION
  // -------------------------------------------------------------------------

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

  // -------------------------------------------------------------------------
  // RECENT ACTIVITY SECTION
  // -------------------------------------------------------------------------

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Recent Activity'),
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
                    style: const TextStyle(
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
                      style: const TextStyle(
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
                style: const TextStyle(
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

  // -------------------------------------------------------------------------
  // BUTTONS
  // -------------------------------------------------------------------------

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
