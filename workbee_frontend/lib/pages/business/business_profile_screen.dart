import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workbee_frontend/clients/business_client.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/pages/auth/login_page.dart';
import 'package:workbee_frontend/services/supabase_service.dart';
import 'package:workbee_frontend/services/token_service.dart';
import 'package:workbee_frontend/widgets/common_app_bar.dart';

class BusinessProfilePage extends StatefulWidget {
  final String businessName;
  final String location;
  final bool showNavBar;
  final bool showAppBar;

  const BusinessProfilePage({
    super.key,
    this.businessName = 'My Business',
    this.location = '',
    this.showNavBar = true,
    this.showAppBar = true,
  });

  @override
  State<BusinessProfilePage> createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends State<BusinessProfilePage> {
  static const _primaryBlue = AppColors.primaryBlue;
  static const _softBlueBg = AppColors.softBlueBg;
  static const _darkText = AppColors.darkText;
  static const _mutedText = AppColors.mutedText;
  static const _borderColor = AppColors.borderColor;

  BusinessProfileResponse? _profile;
  bool _isLoading = true;
  int _selectedNavIndex = 3;

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'B';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await BusinessClient.getProfile();

      if (!mounted) return;

      if (result.containsKey('error')) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final profile = BusinessProfileResponse.fromJson(result);
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfileFromDialog(Map<String, dynamic> data) async {
    Map<String, dynamic> result;
    try {
      result = await BusinessClient.updateProfile(data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update failed: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (!mounted) return;

    // A failed/empty response must not wipe the existing profile.
    if (result.containsKey('error') || !result.containsKey('id')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['error'] as String? ?? 'Update failed. Please try again.',
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final profile = BusinessProfileResponse.fromJson(result);
    setState(() {
      _profile = profile;
    });

    // Keep the cached display name in sync with the saved profile.
    if (profile.displayName.isNotEmpty) {
      TokenService.updateProfile(name: profile.displayName);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  Future<void> _logout() async {
    await TokenService.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _openEditProfileDialog() {
    if (_profile == null) return;

    final nameCtrl = TextEditingController(
      text: TokenService.getNameSync() ?? _profile!.email.split('@').first,
    );
    final categoryCtrl = TextEditingController(text: _profile!.businessType ?? '');
    final aboutCtrl = TextEditingController(text: _profile!.about ?? '');
    final locationCtrl = TextEditingController(text: _profile!.location ?? '');
    final phoneCtrl = TextEditingController(text: _profile!.phone ?? '');
    final websiteCtrl = TextEditingController(text: _profile!.website ?? '');
    final regCtrl = TextEditingController(text: _profile!.registrationNumber ?? '');
    final foundedCtrl = TextEditingController(text: _profile!.foundedYear ?? '');
    final teamCtrl = TextEditingController(text: _profile!.teamSize ?? '');
    File? logoFile;
    final picker = ImagePicker();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Edit Business Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _darkText,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogInput(
                label: 'Business Name',
                controller: nameCtrl,
              ),
              const SizedBox(height: 12),
              _DialogInput(
                label: 'Category',
                controller: categoryCtrl,
              ),
              const SizedBox(height: 12),
              _DialogInput(
                label: 'About the business',
                controller: aboutCtrl,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              _DialogInput(
                label: 'Location',
                controller: locationCtrl,
              ),
              const SizedBox(height: 12),
              _DialogInput(
                label: 'Phone',
                controller: phoneCtrl,
              ),
              const SizedBox(height: 12),
              _DialogInput(
                label: 'Website',
                controller: websiteCtrl,
              ),
              const SizedBox(height: 12),
              _DialogInput(
                label: 'Registration Number',
                controller: regCtrl,
              ),
              const SizedBox(height: 12),
              _DialogInput(
                label: 'Founded Year',
                controller: foundedCtrl,
              ),
              const SizedBox(height: 12),
              _DialogInput(
                label: 'Team Size',
                controller: teamCtrl,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Logo: '),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final picked = await picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          if (SupabaseService.isFileTooLarge(picked.path, maxMb: 5)) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('File too large. Max 5 MB allowed.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          logoFile = File(picked.path);
                        }
                      },
                      icon: const Icon(Icons.image, size: 18),
                      label: const Text('Choose'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: _mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              String? logoUrl;
              if (logoFile != null) {
                final fileName = 'logos/${DateTime.now().millisecondsSinceEpoch}.jpg';
                logoUrl = await SupabaseService().upload(logoFile!.path, fileName);
                if (logoUrl == null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logo upload failed.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
              }
              final dialogContext = context;
              await _updateProfileFromDialog({
                'full_name': nameCtrl.text.trim(),
                'business_type': categoryCtrl.text.trim(),
                'about': aboutCtrl.text.trim(),
                'location': locationCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
                'website': websiteCtrl.text.trim(),
                'registration_number': regCtrl.text.trim(),
                'founded_year': foundedCtrl.text.trim(),
                'team_size': teamCtrl.text.trim(),
                if (logoUrl != null) 'logo_url': logoUrl,
              });
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildProfileSkeleton();
    }

    final displayName =
        _profile != null
            ? (TokenService.getNameSync()?.isNotEmpty ?? false
                ? TokenService.getNameSync()!
                : _profile!.email.split('@').first)
            : widget.businessName;
    final displayLocation = _profile?.location ?? widget.location;
    final isVerified = _profile?.isVerified ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.showAppBar
          ? CommonAppBar(
              displayName: displayName,
              role: 'business',
              onAvatarTap: _openEditProfileDialog,
            )
          : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Logo Box + Business Title + Verified Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: _softBlueBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getInitials(displayName),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: _primaryBlue,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'LOGO',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: _primaryBlue,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: _darkText,
                              ),
                            ),
                            const SizedBox(height: 3),
                            if (_profile?.businessType != null &&
                                _profile!.businessType!.isNotEmpty)
                              Text(
                                _profile!.businessType!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: _mutedText,
                                ),
                              ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _softBlueBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: _primaryBlue,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    isVerified ? 'Business verified' : 'Verify business',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // About the business
                  const Text(
                    'About the business',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _profile?.about?.isNotEmpty == true
                        ? _profile!.about!
                        : 'No description yet. Edit your profile to add one.',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: _profile?.about?.isNotEmpty == true
                          ? _mutedText
                          : AppColors.hintText,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Business details
                  const Text(
                    'Business details',
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
                        const Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 12,
                            color: _mutedText,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          displayLocation.isNotEmpty
                              ? displayLocation
                              : 'Not set',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _darkText,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 12,
                            color: _mutedText,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _profile?.email ?? 'Not set',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Verified by WorkBee Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _softBlueBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.verified_outlined,
                            size: 22,
                            color: _primaryBlue,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verified by WorkBee',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _primaryBlue,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Business identity and contact details checked. Students can apply to your gigs with confidence.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: _mutedText,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Edit Profile Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _openEditProfileDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _logout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.errorRed,
                        side: const BorderSide(color: AppColors.errorRed),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: widget.showNavBar
          ? SafeArea(
              top: false,
              child: Container(
                height: 68,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: _borderColor, width: 1),
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
            )
          : null,
    );
  }

  Widget _buildProfileSkeleton() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header skeleton
                  Container(
                    height: 28,
                    width: 200,
                    decoration: BoxDecoration(
                      color: _softBlueBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 14,
                    width: 150,
                    decoration: BoxDecoration(
                      color: _softBlueBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Logo + Name + Category skeleton
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: _softBlueBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 22,
                              width: 180,
                              decoration: BoxDecoration(
                                color: _softBlueBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              height: 13,
                              width: 120,
                              decoration: BoxDecoration(
                                color: _softBlueBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _softBlueBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: _softBlueBg,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    width: 120,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _softBlueBg,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // About section skeleton
                  Container(
                    height: 16,
                    width: 140,
                    decoration: BoxDecoration(
                      color: _softBlueBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _softBlueBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Business details card skeleton
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
                        Container(
                          height: 12,
                          width: 80,
                          decoration: BoxDecoration(
                            color: _softBlueBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          height: 14,
                          width: 120,
                          decoration: BoxDecoration(
                            color: _softBlueBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          height: 12,
                          width: 60,
                          decoration: BoxDecoration(
                            color: _softBlueBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          height: 14,
                          width: 160,
                          decoration: BoxDecoration(
                            color: _softBlueBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Verified card skeleton
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _softBlueBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: _softBlueBg,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 14,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: _softBlueBg,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 12.5,
                                width: 250,
                                decoration: BoxDecoration(
                                  color: _softBlueBg,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Edit button skeleton
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _softBlueBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: widget.showNavBar
          ? SafeArea(
              top: false,
              child: Container(
                height: 68,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: _borderColor, width: 1),
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
            )
          : null,
    );
  }
}

class _DialogInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;

  const _DialogInput({
    required this.label,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
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
    const blue = AppColors.primaryBlue;

    return Expanded(
      child: GestureDetector(
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
