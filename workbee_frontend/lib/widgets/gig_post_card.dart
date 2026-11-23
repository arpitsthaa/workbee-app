import 'package:flutter/material.dart';
import 'package:workbee_frontend/models/api_models.dart';

class GigPostCard extends StatelessWidget {
  final Gig gig;
  final String formattedBudget;
  final Color softBlueBg;
  final VoidCallback onDetailsTap;

  const GigPostCard({
    super.key,
    required this.gig,
    required this.formattedBudget,
    required this.softBlueBg,
    required this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const mutedText = Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
            ],
          ),
        ],
      ),
    );
  }
}
