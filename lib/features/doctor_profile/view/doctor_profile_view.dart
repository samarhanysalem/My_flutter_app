import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../home/models/doctor.dart';

/// Placeholder destination for tapping a doctor card on Home. The full
/// profile (bio, availability, booking entry point) comes next.
class DoctorProfileView extends StatelessWidget {
  const DoctorProfileView({super.key, required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.screenGround,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.ink,
        elevation: 0,
        title: Text(doctor.name, style: AppTheme.cardTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(doctor.specialty, style: AppTheme.subtitle),
              const SizedBox(height: AppTheme.spacing12),
              Text(
                'Doctor profile coming soon.',
                style: AppTheme.body,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
