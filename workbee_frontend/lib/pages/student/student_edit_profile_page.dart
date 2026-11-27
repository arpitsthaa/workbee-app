import 'package:flutter/material.dart';
import 'package:workbee_frontend/clients/student_client.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/helpers/alert_helper.dart';
import 'package:workbee_frontend/services/token_service.dart';

/// Separate edit profile page opened from the profile page.
class StudentEditProfilePage extends StatefulWidget {
  const StudentEditProfilePage({super.key});

  @override
  State<StudentEditProfilePage> createState() => _StudentEditProfilePageState();
}

class _StudentEditProfilePageState extends State<StudentEditProfilePage> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _collegeController = TextEditingController();
  final _courseController = TextEditingController();
  final _aboutController = TextEditingController();
  final _skillsController = TextEditingController();
  final _portfolioController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadExistingValues();
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

  Future<void> _loadExistingValues() async {
    final name = await TokenService.getName() ?? '';
    final location = await TokenService.getLocation() ?? '';
    final college = await TokenService.getCollegeUniversity() ?? '';
    final program = await TokenService.getProgram() ?? '';
    final semester = await TokenService.getSemester() ?? '';
    final about = await TokenService.getBio() ?? '';
    final skills = await TokenService.getSkills();
    final portfolio = await TokenService.getPortfolioUrl() ?? '';

    if (!mounted) return;
    setState(() {
      _nameController.text = name;
      _locationController.text = location;
      _collegeController.text = college;
      _courseController.text = (program.isNotEmpty && semester.isNotEmpty)
          ? '$program · $semester'
          : (program.isNotEmpty ? program : (semester.isNotEmpty ? semester : ''));
      _aboutController.text = about;
      _skillsController.text = skills.join(', ');
      _portfolioController.text = portfolio;
    });
  }

  bool _isValidUrl(String url) {
    final regex = RegExp(
      r'^(https?://)?([\w-]+\.)+[\w-]+(/[\w-./?%&=]*)?$',
      caseSensitive: false,
    );
    return regex.hasMatch(url);
  }

  Future<void> _saveProfile() async {
    final portfolioUrl = _portfolioController.text.trim();

    if (portfolioUrl.isNotEmpty && !_isValidUrl(portfolioUrl)) {
      if (!mounted) return;
      showAlert(
        context,
        message:
            'Please enter a valid URL (e.g., example.com or https://example.com)',
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

    setState(() => _isSaving = true);

    final result = await StudentClient.updateProfile(data);

    if (!mounted) return;

    if (result.containsKey('error')) {
      setState(() => _isSaving = false);
      showAlert(
        context,
        message: result['error'] as String? ?? 'Save failed',
        isError: true,
      );
      return;
    }

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
    setState(() => _isSaving = false);
    showAlert(context, message: 'Profile saved');
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal Info',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full name',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _locationController,
                    label: 'Location',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _collegeController,
                    label: 'College / University',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _courseController,
                    label: 'Course · Semester',
                    hint: 'e.g. Computer Science · 5th',
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'About & Skills',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _aboutController,
                    label: 'About me',
                    maxLines: 3,
                    hint: 'Tell us a bit about yourself',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _skillsController,
                    label: 'Skills',
                    hint: 'e.g. Flutter, UI Design, Python',
                    helperText: 'Separate multiple skills with commas',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _portfolioController,
                    label: 'Portfolio link',
                    hint: 'https://your-portfolio.com',
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? helperText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.labelRegister,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            helperStyle: const TextStyle(
              fontSize: 11,
              color: AppColors.hintText,
            ),
            filled: true,
            fillColor: AppColors.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryBlue),
            ),
          ),
        ),
      ],
    );
  }
}
