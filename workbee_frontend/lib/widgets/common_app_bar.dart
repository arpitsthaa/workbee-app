import 'package:flutter/material.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/services/token_service.dart';

/// Reusable app bar widget used across all dashboards (student + business).
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String displayName;
  final String role; // 'student' or 'business'
  final VoidCallback onAvatarTap;
  final VoidCallback? onBack;

  const CommonAppBar({
    super.key,
    required this.displayName,
    this.role = 'student',
    required this.onAvatarTap,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: ListenableBuilder(
        listenable: TokenService(),
        builder: (context, _) {
          final name = TokenService.getNameSync() ?? displayName;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                if (onBack != null)
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.darkText,
                    ),
                  ),
                Row(
                  children: [
                    Image.asset(
                      'assets/workbee_logo.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'WorkBee',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Bee Busy Be Paid',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: onAvatarTap,
                  icon: _DashboardAvatar(
                    name: name,
                    role: role,
                  ),
                  splashRadius: 24,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Dashboard avatar widget used across all dashboards.
class _DashboardAvatar extends StatelessWidget {
  final String name;
  final String role;

  const _DashboardAvatar({
    required this.name,
    this.role = 'student',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.softBlueBg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}
