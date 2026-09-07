import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/models/doctor.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../auth/view/auth_provider.dart';
import '../services/availability_service.dart';
import '../services/booking_service.dart';
import '../view/availability_provider.dart';
import '../widgets/availability_section.dart';
import '../widgets/book_appointment_button.dart';
import '../widgets/doctor_about_section.dart';
import '../widgets/doctor_profile_hero.dart';
import '../widgets/quick_actions_row.dart';

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// The doctor profile screen: hero, quick actions, bio, availability, and
/// booking. AvailabilitySection and BookAppointmentButton both read the one
/// AvailabilityProvider created here, so selecting a slot in one is what
/// the other books.
class DoctorProfileView extends StatelessWidget {
  DoctorProfileView({
    super.key,
    required this.doctor,
    this.availabilityService,
    this.bookingService,
    DateTime? today,
  }) : today = _dateOnly(today ?? DateTime.now());

  final Doctor doctor;

  /// Injectable for tests, so they never talk to real Firestore.
  final AvailabilityService? availabilityService;
  final BookingService? bookingService;

  /// Overridable so tests get a deterministic "today" instead of depending
  /// on the real wall-clock date.
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final avatarColor =
        AppTheme.avatarPalette[doctor.id.hashCode.abs() %
            AppTheme.avatarPalette.length];
    final patientId = context.read<AuthProvider>().user?.uid;

    return ChangeNotifierProvider<AvailabilityProvider>(
      create: (_) => AvailabilityProvider(
        availabilityService: availabilityService ?? FirestoreAvailabilityService(),
        bookingService: bookingService ?? FirestoreBookingService(),
        doctorId: doctor.id,
        doctorName: doctor.name,
        patientId: patientId,
        initialDate: today,
      ),
      child: Scaffold(
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
                                icon: Icon(
                                  Directionality.of(context) == TextDirection.rtl
                                      ? Icons.arrow_forward
                                      : Icons.arrow_back,
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
                          AvailabilitySection(today: today),
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
      ),
    );
  }
}
