import 'package:flutter/material.dart';

import '../../../common/models/doctor.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import 'doctor_card.dart';

/// Renders the "Our doctors" section body as a sliver — a loading spinner,
/// an error message, an empty state, or the filtered list — never a blank
/// screen. Returns a sliver (not a plain box widget) so it can sit directly
/// in `HomeView`'s `CustomScrollView`: that lets the doctor list build
/// lazily (only the on-screen cards) instead of the whole roster eagerly,
/// which a `shrinkWrap` list nested in a scroll view would force.
class DoctorList extends StatelessWidget {
  const DoctorList({
    super.key,
    required this.doctors,
    required this.isLoading,
    required this.hasError,
    required this.hasActiveFilter,
    required this.onDoctorTap,
  });

  final List<Doctor> doctors;
  final bool isLoading;
  final bool hasError;

  /// Whether a search/specialty filter is active, so the empty state can
  /// say "no matches" instead of "no doctors" when the backend list isn't
  /// actually empty.
  final bool hasActiveFilter;
  final ValueChanged<Doctor> onDoctorTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppTheme.spacing24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final loc = AppLocalizations.of(context)!;

    if (hasError) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing24),
          child: Center(
            child: Text(
              loc.loadDoctorsError,
              style: AppTheme.subtitle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (doctors.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing24),
          child: Center(
            child: Text(
              hasActiveFilter
                  ? loc.noDoctorsMatchSearch
                  : loc.noDoctorsAvailable,
              style: AppTheme.subtitle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return SliverList.separated(
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
