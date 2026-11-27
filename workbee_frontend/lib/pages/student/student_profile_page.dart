import 'package:flutter/material.dart';
import 'package:workbee_frontend/clients/student_client.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/pages/auth/login_page.dart';
import 'package:workbee_frontend/pages/student/student_edit_profile_page.dart';
import 'package:workbee_frontend/pages/student/student_passport_page.dart';
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
  bool _isLoading = true;
  String? _error;
  ProfileResponse? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
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
        _isLoading = false;
      });
    }
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
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: _buildViewMode(),
          ),
        ),
      ),
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
    return Row(
      children: [
        const Icon(Icons.circle, size: 8, color: AppColors.primaryBlue),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
        ),
      ],
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
    final bio = TokenService.getBioSync() ?? _profile?.bio ?? '';
    if (bio.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: const Text(
          'No bio yet. Add a short introduction in your profile.',
          style: TextStyle(fontSize: 13, color: AppColors.mutedText),
        ),
      );
    }
    return Text(
      bio,
      style: const TextStyle(fontSize: 14, color: AppColors.mutedText),
    );
  }

  Widget _buildSkillsSection() {
    final skills = TokenService.getSkillsSync().isNotEmpty
        ? TokenService.getSkillsSync()
        : _profile?.skills ?? [];
    if (skills.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: const Text(
          'No skills added yet. Add skills to showcase your expertise.',
          style: TextStyle(fontSize: 13, color: AppColors.mutedText),
        ),
      );
    }
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
    final portfolioUrl =
        TokenService.getPortfolioUrlSync() ?? _profile?.portfolioUrl ?? '';
    if (portfolioUrl.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portfolio',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'No portfolio link yet.',
              style: TextStyle(fontSize: 13, color: AppColors.mutedText),
            ),
          ],
        ),
      );
    }
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
            portfolioUrl,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.primaryBlue,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StudentPassportPage(),
                        ),
                      );
                    },
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
        onPressed: () async {
          final saved = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const StudentEditProfilePage(),
            ),
          );
          if (saved == true) {
            _loadProfile();
          }
        },
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
