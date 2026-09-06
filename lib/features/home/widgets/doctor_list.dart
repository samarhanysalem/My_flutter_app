import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../models/doctor.dart';
import 'doctor_card.dart';

/// Renders the "Our doctors" section body: a loading spinner, an error
/// message, an empty state, or the filtered list — never a blank screen.
class DoctorList extends StatelessWidget {
  const DoctorList({
    super.key,
    required this.doctors,
    required this.isLoading,
    required this.errorMessage,
    required this.hasActiveFilter,
    required this.onDoctorTap,
  });

  final List<Doctor> doctors;
  final bool isLoading;
  final String? errorMessage;

  /// Whether a search/specialty filter is active, so the empty state can
  /// say "no matches" instead of "no doctors" when the backend list isn't
  /// actually empty.
  final bool hasActiveFilter;
  final ValueChanged<Doctor> onDoctorTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppTheme.spacing24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing24),
        child: Center(
          child: Text(
            errorMessage!,
            style: AppTheme.subtitle,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (doctors.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing24),
        child: Center(
          child: Text(
            hasActiveFilter
                ? 'No doctors match your search.'
                : 'No doctors available yet.',
            style: AppTheme.subtitle,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: doctors.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppTheme.spacing12),
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        return DoctorCard(
          doctor: doctor,
          avatarColor:
              AppTheme.avatarPalette[index % AppTheme.avatarPalette.length],
          onTap: () => onDoctorTap(doctor),
        );
      },
    );
  }
}
