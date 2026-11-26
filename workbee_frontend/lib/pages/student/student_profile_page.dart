import 'package:flutter/material.dart';
import 'package:workbee_frontend/clients/student_client.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/helpers/alert_helper.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/pages/auth/login_page.dart';
import 'package:workbee_frontend/services/token_service.dart';
import 'package:workbee_frontend/widgets/error_retry_state.dart';
import 'package:workbee_frontend/widgets/loading_state.dart';
import 'package:workbee_frontend/widgets/student_profile_header.dart';

/// Student profile page showing read-only info with an editable form.
class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
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
    final session = TokenService();
    if (await _isInitialized(session)) {
      _nameController.text = (await TokenService.getName()) ?? '';
      _locationController.text = (await TokenService.getLocation()) ?? '';
      _collegeController.text = (await TokenService.getCollegeUniversity()) ?? '';
      final program = await TokenService.getProgram() ?? '';
      final semester = await TokenService.getSemester() ?? '';
      _courseController.text = (program.isNotEmpty && semester.isNotEmpty)
          ? '$program · $semester'
          : (program.isNotEmpty ? program : (semester.isNotEmpty ? semester : ''));
      _aboutController.text = (await TokenService.getBio()) ?? '';
      final skills = await TokenService.getSkills();
      _skillsController.text = skills.join(', ');
      _portfolioController.text = (await TokenService.getPortfolioUrl()) ?? '';
    }

    final result = await StudentClient.getProfile();
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
        _courseController.text =
            '${profile.program} · ${profile.semester}'.trim();
        _aboutController.text = profile.bio;
        _skillsController.text = profile.skills.join(', ');
        _portfolioController.text = profile.portfolioUrl;
        _isLoading = false;
      });
    }
  }

  static Future<bool> _isInitialized(TokenService session) async {
    return true;
  }

  Future<void> _saveProfile() async {
    final portfolioUrl = _portfolioController.text.trim();

    if (portfolioUrl.isNotEmpty && !_isValidUrl(portfolioUrl)) {
      if (!mounted) return;
      showAlert(
        context,
        message: 'Please enter a valid URL (e.g., example.com or https://example.com)',
        isError: true,
      );
      return;
    }

    final courseText = _courseController.text.trim();
    final courseParts = courseText.split(' · ');
    final program = courseParts.isNotEmpty ? courseParts.first : '';
    final semester = courseParts.length > 1 ? courseParts.last : '';

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

    final result = await StudentClient.updateProfile(data);
    if (!mounted) return;

    if (result.containsKey('error')) {
      showAlert(
        context,
        message: result['error'] as String? ?? 'Save failed',
        isError: true,
      );
    } else {
      await TokenService.updateProfile(
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
      showAlert(context, message: 'Profile saved');
    }
  }

  bool _isValidUrl(String url) {
    final regex = RegExp(
      r'^(https?://)?([\w-]+\.)+[\w-]+(/[\w-./?%&=]*)?$',
      caseSensitive: false,
    );
    return regex.hasMatch(url);
  }

  Future<void> _handleLogout() async {
    await TokenService.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState();
    }

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

  Widget _buildProfileHeader() {
    return ListenableBuilder(
      listenable: TokenService(),
      builder: (context, _) {
        return StudentProfileHeader(
          displayName: TokenService.getNameSync() ?? _profile?.fullName,
          location: TokenService.getLocationSync() ?? _profile?.location ?? '',
          email: _profile?.email,
          isVerified: _profile?.isVerified ?? false,
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
          Text(
            TokenService.getCollegeUniversitySync() ?? _profile?.collegeUniversity ?? '',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${TokenService.getProgramSync() ?? _profile?.program ?? ''} · ${TokenService.getSemesterSync() ?? _profile?.semester ?? ''}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Text(
      TokenService.getBioSync() ?? _profile?.bio ?? '',
      style: const TextStyle(fontSize: 14, color: AppColors.mutedText),
    );
  }

  Widget _buildSkillsSection() {
    final skills = TokenService.getSkillsSync().isNotEmpty
        ? TokenService.getSkillsSync()
        : _profile?.skills ?? [];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills
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
          Text(
            TokenService.getPortfolioUrlSync() ?? _profile?.portfolioUrl ?? '',
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

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
                    onPressed: () {},
                    child: const Text(
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
