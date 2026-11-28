import 'package:flutter/material.dart';
import 'package:workbee_frontend/clients/business_client.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/helpers/alert_helper.dart';
import 'package:workbee_frontend/services/token_service.dart';

/// Separate edit profile page opened from the business profile page.
class BusinessEditProfilePage extends StatefulWidget {
  const BusinessEditProfilePage({super.key});

  @override
  State<BusinessEditProfilePage> createState() => _BusinessEditProfilePageState();
}

class _BusinessEditProfilePageState extends State<BusinessEditProfilePage> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _aboutController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadExistingValues();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _aboutController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingValues() async {
    final name = await TokenService.getName() ?? '';
    final category = await _categoryFromProfile();
    final about = await _aboutFromProfile();
    final location = await TokenService.getLocation() ?? '';

    if (!mounted) return;
    setState(() {
      _nameController.text = name;
      _categoryController.text = category;
      _aboutController.text = about;
      _locationController.text = location;
    });
  }

  Future<String> _categoryFromProfile() async {
    final result = await BusinessClient.getProfile();
    if (result.containsKey('error')) return '';
    return (result['business_type'] as String?) ?? '';
  }

  Future<String> _aboutFromProfile() async {
    final result = await BusinessClient.getProfile();
    if (result.containsKey('error')) return '';
    return (result['about'] as String?) ?? '';
  }

  Future<void> _saveProfile() async {
    final data = {
      'full_name': _nameController.text.trim(),
      'business_type': _categoryController.text.trim(),
      'about': _aboutController.text.trim(),
      'location': _locationController.text.trim(),
    };

    setState(() => _isSaving = true);

    final result = await BusinessClient.updateProfile(data);

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
                    'Business Info',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Business Name',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _categoryController,
                    label: 'Category',
                    hint: 'e.g. Restaurant, Design Agency',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _locationController,
                    label: 'Location',
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _aboutController,
                    label: 'About the business',
                    maxLines: 3,
                    hint: 'Tell us about your business',
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
