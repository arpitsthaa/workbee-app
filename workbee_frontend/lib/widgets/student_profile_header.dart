import 'package:flutter/material.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/services/token_service.dart';

/// Consistent student profile header (avatar + name + college) used across all 5 student screens.
class StudentProfileHeader extends StatelessWidget {
  final String? displayName;
  final String? collegeProgram;
  final String? location;
  final String? email;
  final bool isVerified;
  final double avatarSize;

  const StudentProfileHeader({
    super.key,
    this.displayName,
    this.collegeProgram,
    this.location,
    this.email,
    this.isVerified = false,
    this.avatarSize = 52,
  });

  @override
  Widget build(BuildContext context) {
    final name = displayName ?? TokenService.getNameSync() ?? 'Student';
    final college = collegeProgram ?? TokenService.getCollegeUniversitySync() ?? '';
    final program = TokenService.getProgramSync() ?? '';
    final semester = TokenService.getSemesterSync() ?? '';
    final loc = location ?? TokenService.getLocationSync() ?? '';
    final em = email ?? '';

    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'A';
    final collegeProgramText = college.isNotEmpty
        ? '$college${program.isNotEmpty ? ' · $program' : ''}'
        : (program.isNotEmpty ? program : '');
    final collegeSemesterText = collegeProgramText.isNotEmpty
        ? '$collegeProgramText${semester.isNotEmpty ? ' · $semester' : ''}'
        : (semester.isNotEmpty ? semester : '');
    final subTitle = loc.isNotEmpty ? loc : collegeSemesterText;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: const BoxDecoration(
                color: AppColors.softBlueBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: avatarSize * 0.38,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isVerified) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.softBlueBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified,
                                  size: 12, color: AppColors.primaryBlue),
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
                  if (subTitle.isNotEmpty)
                    Text(
                      subTitle,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.mutedText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (em.isNotEmpty)
                    Text(
                      em,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.mutedText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
