import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/models/appointment.dart';
import '../../../l10n/app_localizations.dart';
import '../../../navigation/nav_shell_controller.dart';
import '../../../theme/app_theme.dart';
import '../../auth/view/auth_provider.dart';
import '../../doctor_profile/services/booking_service.dart';
import '../../doctor_profile/view/doctor_profile_view.dart';
import '../../home/services/appointment_service.dart';
import '../widgets/appointment_card.dart';
import '../widgets/appointments_empty_state.dart';
import '../widgets/appointments_tab_toggle.dart';
import 'my_appointments_provider.dart';

/// My appointments: an Upcoming/Past toggle over the signed-in patient's
/// appointments, fetched from Firestore via `AppointmentService`.
class MyAppointmentsView extends StatelessWidget {
  const MyAppointmentsView({super.key, this.appointmentService, this.bookingService});

  /// Injectable for tests, so they never talk to real Firestore.
  final AppointmentService? appointmentService;
  final BookingService? bookingService;

  @override
  Widget build(BuildContext context) {
    final patientId = context.read<AuthProvider>().user?.uid;
    return ChangeNotifierProvider<MyAppointmentsProvider>(
      create: (_) => MyAppointmentsProvider(
        appointmentService: appointmentService ?? FirestoreAppointmentService(),
        bookingService: bookingService ?? FirestoreBookingService(),
        patientId: patientId,
      ),
      child: const _RefreshOnTabEnter(child: _MyAppointmentsScaffold()),
    );
  }
}

/// Re-fetches both tabs whenever the Appointments bottom-nav tab becomes
/// selected — e.g. after booking a new appointment from Home and then
/// switching here. `MainNavShell` keeps this screen alive in an
/// `IndexedStack` rather than rebuilding it on every tab switch, and
/// `MyAppointmentsProvider`'s lists are one-time fetches (see its doc
/// comment), so without this they'd otherwise only ever reflect whatever
/// was true when this screen was first built.
class _RefreshOnTabEnter extends StatefulWidget {
  const _RefreshOnTabEnter({required this.child});

  final Widget child;

  @override
  State<_RefreshOnTabEnter> createState() => _RefreshOnTabEnterState();
}

class _RefreshOnTabEnterState extends State<_RefreshOnTabEnter> {
  NavShellController? _navController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final navController = context.read<NavShellController>();
    if (!identical(_navController, navController)) {
      _navController?.removeListener(_onNavChanged);
      _navController = navController..addListener(_onNavChanged);
    }
  }

  @override
  void dispose() {
    _navController?.removeListener(_onNavChanged);
    super.dispose();
  }

  void _onNavChanged() {
    if (_navController?.selectedTab == MainTab.appointments) {
      context.read<MyAppointmentsProvider>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
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
        return ListView.separated(
          itemCount: upcoming.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppTheme.spacing12),
          itemBuilder: (context, index) {
            final appointment = upcoming[index];
            return AppointmentCard(
              appointment: appointment,
              isPast: false,
              lookupDoctor: context.read<MyAppointmentsProvider>().getDoctor,
              onCancel: () => _confirmAndCancel(context, appointment),
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

/// Confirms with the patient, then cancels [appointment] — releasing its
/// slot back into that doctor's availability for other patients to book —
/// and shows a confirmation or failure snackbar based on the result. The
/// provider's own `refresh()` (called from `cancelAppointment` on success)
/// takes care of dropping it from the Upcoming list.
Future<void> _confirmAndCancel(BuildContext context, Appointment appointment) async {
  final loc = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(loc.cancelAppointmentQuestion),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(loc.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(loc.cancelAppointment),
        ),
      ],
    ),
  );
  if (!(confirmed ?? false) || !context.mounted) return;

  final success = await context.read<MyAppointmentsProvider>().cancelAppointment(
    appointment,
  );
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(success ? loc.appointmentCancelled : loc.cancelAppointmentFailed),
    ),
  );
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
