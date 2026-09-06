import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../models/doctor.dart';

/// A single row in the "Our doctors" list: avatar, name/specialty, and
/// rating, matching the design handoff's card layout.
class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
    required this.doctor,
    required this.avatarColor,
    required this.onTap,
  });

  final Doctor doctor;
  final Color avatarColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: avatarColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    doctor.name,
                    style: AppTheme.cardTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacing2),
                  Text(
                    doctor.specialty,
                    style: AppTheme.fieldLabel,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 11, color: AppTheme.ratingStar),
                const SizedBox(width: AppTheme.spacing3),
                Text(doctor.rating.toStringAsFixed(1), style: AppTheme.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
