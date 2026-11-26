import 'package:flutter/material.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/services/token_service.dart';

class DashboardAvatar extends StatelessWidget {
  final String studentName;
  final bool isVerified;

  const DashboardAvatar({
    super.key,
    required this.studentName,
    required this.isVerified,
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
        studentName.isNotEmpty ? studentName[0].toUpperCase() : 'S',
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}

class StudentAppBar extends StatelessWidget {
  final VoidCallback onAvatarTap;

  const StudentAppBar({super.key, required this.onAvatarTap});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TokenService(),
      builder: (context, _) {
        final studentName = TokenService.getNameSync() ?? '';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
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
                icon: DashboardAvatar(
                  studentName: studentName,
                  isVerified: false,
                ),
                splashRadius: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        );
      },
    );
  }
}
