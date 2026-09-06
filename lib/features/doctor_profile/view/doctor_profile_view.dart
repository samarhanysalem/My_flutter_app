import 'package:flutter/material.dart';

import '../../../common/models/doctor.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../services/availability_service.dart';
import '../widgets/availability_section.dart';
import '../widgets/book_appointment_button.dart';
import '../widgets/doctor_about_section.dart';
import '../widgets/doctor_profile_hero.dart';
import '../widgets/quick_actions_row.dart';

/// The doctor profile screen: hero, quick actions, bio, and availability,
/// from the design handoff. The booking flow itself is a separate feature
/// — "Book appointment" is wired up as an entry point stub for now.
class DoctorProfileView extends StatelessWidget {
  const DoctorProfileView({
    super.key,
    required this.doctor,
    this.availabilityService,
  });

  final Doctor doctor;

  /// Injectable for tests, so they never talk to real Firestore — see
  /// `AvailabilitySection`.
  final AvailabilityService? availabilityService;

  @override
  Widget build(BuildContext context) {
    final avatarColor =
        AppTheme.avatarPalette[doctor.id.hashCode.abs() %
            AppTheme.avatarPalette.length];

    return Scaffold(
      backgroundColor: AppTheme.screenGround,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacing20,
                  AppTheme.spacing20,
                  AppTheme.spacing20,
                  AppTheme.spacing16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.arrow_back,
                                size: 20,
                                color: AppTheme.ink,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacing12),
                            Text(
                              AppLocalizations.of(context)!.doctorProfileTitle,
                              style: AppTheme.screenTitle,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacing20),
                        Center(
                          child: DoctorProfileHero(
                            doctor: doctor,
                            avatarColor: avatarColor,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing20),
                        const QuickActionsRow(),
                        const SizedBox(height: AppTheme.spacing20),
                        DoctorAboutSection(
                          bio: doctor.localizedBio(Localizations.localeOf(context)),
                        ),
                        const SizedBox(height: AppTheme.spacing20),
                        AvailabilitySection(
                          doctorId: doctor.id,
                          availabilityService: availabilityService,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacing20,
                AppTheme.spacing14,
                AppTheme.spacing20,
                AppTheme.spacing20,
              ),
              color: AppTheme.screenGround,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: const BookAppointmentButton(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
