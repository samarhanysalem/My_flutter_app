import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../common/models/doctor.dart';

/// Avatar, name, specialty, and rating at the top of the profile screen.
class DoctorProfileHero extends StatelessWidget {
  const DoctorProfileHero({
    super.key,
    required this.doctor,
    required this.avatarColor,
  });

  final Doctor doctor;
  final Color avatarColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(color: avatarColor, shape: BoxShape.circle),
        ),
        const SizedBox(height: AppTheme.spacing8),
        Text(doctor.name, style: AppTheme.greeting),
        const SizedBox(height: AppTheme.spacing4),
        Text(doctor.specialty, style: AppTheme.subtitle),
        const SizedBox(height: AppTheme.spacing4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, size: 13, color: AppTheme.ratingStar),
            const SizedBox(width: AppTheme.spacing3),
            Text(doctor.rating.toStringAsFixed(1), style: AppTheme.cardTitle),
          ],
        ),
      ],
    );
  }
}
