import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/models/appointment.dart';
import '../../../config/app_config.dart';
import '../../../l10n/app_localizations.dart';
import '../../../navigation/nav_shell_controller.dart';
import '../../../theme/app_theme.dart';
import '../../auth/view/auth_provider.dart';
import '../../doctor_profile/view/doctor_profile_view.dart';
import '../../home/services/appointment_service.dart';
import '../widgets/appointment_card.dart';
import '../widgets/appointments_empty_state.dart';
import '../widgets/appointments_tab_toggle.dart';
import 'my_appointments_provider.dart';

/// My appointments: an Upcoming/Past toggle over the signed-in patient's
/// appointments, fetched from Firestore via `AppointmentService`.
class MyAppointmentsView extends StatelessWidget {
  const MyAppointmentsView({super.key, this.appointmentService});

  /// Injectable for tests, so they never talk to real Firestore.
  final AppointmentService? appointmentService;

  @override
  Widget build(BuildContext context) {
    final patientId = context.read<AuthProvider>().user?.uid;
    return ChangeNotifierProvider<MyAppointmentsProvider>(
      create: (_) => MyAppointmentsProvider(
        appointmentService: appointmentService ?? FirestoreAppointmentService(),
        patientId: patientId,
      ),
      child: const _MyAppointmentsScaffold(),
    );
  }
}

class _MyAppointmentsScaffold extends StatelessWidget {
  const _MyAppointmentsScaffold();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final selectedTab = context.watch<MyAppointmentsProvider>().selectedTab;
    return Scaffold(
      backgroundColor: AppTheme.screenGround,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.myAppointmentsTitle, style: AppTheme.screenTitle),
                  const SizedBox(height: AppTheme.spacing16),
                  AppointmentsTabToggle(
                    selected: selectedTab,
                    onChanged: context.read<MyAppointmentsProvider>().selectTab,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  Expanded(
                    child: selectedTab == AppointmentsTab.upcoming
                        ? const _UpcomingList()
                        : const _PastList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UpcomingList extends StatelessWidget {
  const _UpcomingList();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Selector<MyAppointmentsProvider, (List<Appointment>, bool, bool)>(
      selector: (_, provider) =>
          (provider.upcoming, provider.isLoadingUpcoming, provider.hasUpcomingError),
      builder: (context, state, _) {
        final (upcoming, isLoading, hasError) = state;
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (hasError) {
          return Center(
            child: Text(
              loc.loadAppointmentsError,
              style: AppTheme.subtitle,
              textAlign: TextAlign.center,
            ),
          );
        }
        if (upcoming.isEmpty) {
          return AppointmentsEmptyState(
            message: loc.noUpcomingAppointments,
            actionLabel: loc.bookNow,
            onAction: () =>
                context.read<NavShellController>().selectTab(MainTab.home),
          );
        }
        final locale = Localizations.localeOf(context);
        return ListView.separated(
          itemCount: upcoming.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppTheme.spacing12),
          itemBuilder: (context, index) {
            final appointment = upcoming[index];
            return AppointmentCard(
              appointment: appointment,
              isPast: false,
              lookupDoctor: context.read<MyAppointmentsProvider>().getDoctor,
              onGetDirections: () => _openDirections(
                context,
                AppConfig.clinicAddressFor(locale),
              ),
              onReschedule: () => _openReschedule(context, appointment),
            );
          },
        );
      },
    );
  }
}

class _PastList extends StatelessWidget {
  const _PastList();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Selector<MyAppointmentsProvider, (List<Appointment>, bool, bool)>(
      selector: (_, provider) =>
          (provider.past, provider.isLoadingPast, provider.hasPastError),
      builder: (context, state, _) {
        final (past, isLoading, hasError) = state;
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (hasError) {
          return Center(
            child: Text(
              loc.loadAppointmentsError,
              style: AppTheme.subtitle,
              textAlign: TextAlign.center,
            ),
          );
        }
        if (past.isEmpty) {
          return AppointmentsEmptyState(message: loc.noPastAppointments);
        }
        return ListView.separated(
          itemCount: past.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppTheme.spacing12),
          itemBuilder: (context, index) => AppointmentCard(
            appointment: past[index],
            isPast: true,
            lookupDoctor: context.read<MyAppointmentsProvider>().getDoctor,
          ),
        );
      },
    );
  }
}

/// Opens the device's maps app centered on [address] — a universal
/// `google.com/maps` link so this works whether or not a native Maps app is
/// installed, rather than a scheme (`geo:`/`maps:`) that isn't.
Future<void> _openDirections(BuildContext context, String address) async {
  final uri = Uri.https('www.google.com', '/maps/search/', {
    'api': '1',
    'query': address,
  });
  var launched = false;
  try {
    launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    launched = false;
  }
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.couldNotOpenMaps)),
    );
  }
}

/// Looks up the appointment's doctor and, if found, pushes
/// `DoctorProfileView` in reschedule mode for it — picking a slot there
/// moves this same appointment rather than booking a new one alongside it
/// (see `AvailabilityProvider.isRescheduling`). Mirrors
/// `HomeView._openDoctorProfile`'s pop-with-a-confirmation-message flow, so
/// a reschedule that completes shows its confirmation here rather than on
/// the (about to be popped) profile screen — and refreshes both tabs here,
/// since they're one-time fetches that wouldn't otherwise pick up the
/// appointment's new date/slot.
Future<void> _openReschedule(BuildContext context, Appointment appointment) async {
  final provider = context.read<MyAppointmentsProvider>();
  final doctor = await provider.getDoctor(appointment.doctorId);
  if (!context.mounted) return;
  if (doctor == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.rescheduleDoctorNotFound),
      ),
    );
    return;
  }
  final confirmationMessage = await Navigator.of(context).push<String>(
    MaterialPageRoute(
      builder: (_) => DoctorProfileView(
        doctor: doctor,
        reschedulingAppointment: appointment,
      ),
    ),
  );
  if (confirmationMessage == null || !context.mounted) return;
  provider.refresh();
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(confirmationMessage)));
}
