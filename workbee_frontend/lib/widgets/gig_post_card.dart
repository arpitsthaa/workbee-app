import 'package:flutter/material.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/services/user_session_service.dart';

class GigPostCard extends StatelessWidget {
  final Gig gig;
  final String formattedBudget;
  final Color softBlueBg;
  final VoidCallback onDetailsTap;
  final VoidCallback? onApplyTap;
  final bool isApplying;

  const GigPostCard({
    super.key,
    required this.gig,
    required this.formattedBudget,
    required this.softBlueBg,
    required this.onDetailsTap,
    this.onApplyTap,
    this.isApplying = false,
  });

  bool get _isApplied => gig.hasApplied || UserSessionService().isApplied(gig.id);

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const mutedText = Color(0xFF64748B);
    const borderColor = Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            gig.businessName,
            style: const TextStyle(
              fontSize: 13,
              color: mutedText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            gig.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            gig.requiredSkills.join(' · '),
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedBudget,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: primaryBlue,
                ),
              ),
              Text(
                '${gig.durationDays} days · ${gig.deadline}',
                style: const TextStyle(
                  fontSize: 13,
                  color: mutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: mutedText,
              ),
              const SizedBox(width: 4),
              Text(
                gig.location,
                style: const TextStyle(
                  fontSize: 13,
                  color: mutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                gig.isRemote ? 'Remote-friendly' : 'On-site',
                style: const TextStyle(
                  fontSize: 13,
                  color: mutedText,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: onDetailsTap,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: softBlueBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Details',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: primaryBlue,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 15,
                            color: primaryBlue,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildApplyButton(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    const primaryBlue = Color(0xFF1D61E7);
    const borderColor = Color(0xFFE2E8F0);

    if (_isApplied) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 15, color: primaryBlue),
            const SizedBox(width: 4),
            Text(
              'Applied',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: primaryBlue,
              ),
            ),
          ],
        ),
      );
    }

    if (isApplying) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: primaryBlue.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 6),
            Text(
              'Applying...',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: onApplyTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: primaryBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.send, size: 15, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'Apply',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}