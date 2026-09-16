import 'package:doctor_appointment_app/common/models/appointment.dart';
import 'package:doctor_appointment_app/common/models/doctor.dart';
import 'package:doctor_appointment_app/features/appointments/view/my_appointments_view.dart';
import 'package:doctor_appointment_app/features/auth/models/app_user.dart';
import 'package:doctor_appointment_app/features/auth/view/auth_provider.dart';
import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:doctor_appointment_app/navigation/nav_shell_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../auth/fake_auth_repository.dart';
import '../doctor_profile/fake_booking_service.dart';
import '../home/fake_appointment_service.dart';

const _upcoming = Appointment(
  id: 'a1',
  patientId: 'u1',
  doctorId: '1',
  doctorName: 'Dr. Sara Whitmore',
  doctorSpecialty: 'Cardiologist',
  date: '2099-01-02',
  slot: '10:30 AM',
  status: 'confirmed',
);

const _past = Appointment(
  id: 'a2',
  patientId: 'u1',
  doctorId: '2',
  doctorName: 'Dr. Marcus Cole',
  doctorSpecialty: 'Orthopedic Surgeon',
  date: '2020-01-02',
  slot: '9:00 AM',
  status: 'confirmed',
);

Future<void> _pumpView(
  WidgetTester tester,
  FakeAppointmentService appointmentService, {
  FakeBookingService? bookingService,
  NavShellController? navController,
  Locale? locale,
}) async {
  final authProvider = AuthProvider(
    authRepository: FakeAuthRepository(
      initialUser: const AppUser(uid: 'u1', displayName: 'Alex Doe'),
    ),
  );
  // Lets the fake repository's current-user stream resolve before
  // MyAppointmentsView is built, so `patientId` is already non-null the one
  // time MyAppointmentsProvider is created — see home_view_test.dart's
  // `_signedInAuthProvider` for the same fix.
  await tester.pump();

  // MyAppointmentsView always lives inside MainNavShell in production,
  // which provides this above it — including a throwaway one here when a
  // test doesn't care about tab-switching lets _RefreshOnTabEnter (which
  // unconditionally reads it) find one.
  final child = ChangeNotifierProvider<NavShellController>.value(
    value: navController ?? NavShellController(),
    child: MyAppointmentsView(
      appointmentService: appointmentService,
      bookingService: bookingService ?? FakeBookingService(),
    ),
  );

  await tester.pumpWidget(
    ChangeNotifierProvider<AuthProvider>.value(
      value: authProvider,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
}

void main() {
  testWidgets(
    'refreshes the Upcoming list when the Appointments tab becomes selected',
    (tester) async {
      // Simulates booking a new appointment from Home while this screen
      // sits alive-but-unselected in MainNavShell's IndexedStack: nothing
      // tells this already-constructed MyAppointmentsProvider about it
      // directly, so switching to the Appointments tab is what has to
      // pick up the change — the exact bug this guards against ("book a
      // new appointment, it doesn't show up until I refresh the screen").
      final appointmentService = FakeAppointmentService();
      addTearDown(appointmentService.dispose);
      final navController = NavShellController();

      await _pumpView(tester, appointmentService, navController: navController);
      await tester.pump();

      expect(find.text('No upcoming appointments'), findsOneWidget);

      appointmentService.upcomingAppointments = [_upcoming];
      navController.selectTab(MainTab.appointments);
      await tester.pump();

      expect(find.text('Dr. Sara Whitmore'), findsOneWidget);
      expect(find.text('No upcoming appointments'), findsNothing);
    },
  );

  testWidgets('shows a loading indicator, then the Upcoming list', (
    tester,
  ) async {
    final appointmentService = FakeAppointmentService()
      ..upcomingAppointments = [_upcoming];
    addTearDown(appointmentService.dispose);

    await _pumpView(tester, appointmentService);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Dr. Sara Whitmore'), findsOneWidget);
    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.text('Cancel appointment'), findsOneWidget);
    expect(find.text('Reschedule'), findsOneWidget);
  });

  testWidgets(
    'shows "No upcoming appointments" with a Book now button when empty',
    (tester) async {
      final appointmentService = FakeAppointmentService();
      addTearDown(appointmentService.dispose);
      final navController = NavShellController();

      await _pumpView(tester, appointmentService, navController: navController);
      await tester.pump();

      expect(find.text('No upcoming appointments'), findsOneWidget);

      await tester.tap(find.text('Book now'));
      await tester.pump();

      expect(navController.selectedTab, MainTab.home);
    },
  );

  testWidgets(
    'switching to the Past tab shows a dimmed, action-less Completed card',
    (tester) async {
      final appointmentService = FakeAppointmentService()
        ..pastAppointments = [_past];
      addTearDown(appointmentService.dispose);

      await _pumpView(tester, appointmentService);
      await tester.pump();

      await tester.tap(find.text('Past'));
      await tester.pump();

      expect(find.text('Dr. Marcus Cole'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Cancel appointment'), findsNothing);
      expect(find.text('Reschedule'), findsNothing);
      expect(find.byType(Opacity), findsWidgets);
    },
  );

  testWidgets('shows "No past appointments" on an empty Past tab', (
    tester,
  ) async {
    final appointmentService = FakeAppointmentService();
    addTearDown(appointmentService.dispose);

    await _pumpView(tester, appointmentService);
    await tester.pump();

    await tester.tap(find.text('Past'));
    await tester.pump();

    expect(find.text('No past appointments'), findsOneWidget);
    // Unlike the Upcoming tab's empty state, there's no action here.
    expect(find.text('Book now'), findsNothing);
  });

  testWidgets('Reschedule looks up the doctor and opens their profile', (
    tester,
  ) async {
    final appointmentService = FakeAppointmentService()
      ..upcomingAppointments = [_upcoming]
      ..doctorToReturn = const Doctor(
        id: '1',
        name: 'Dr. Sara Whitmore',
        specialty: 'Cardiologist',
        rating: 4.9,
      );
    addTearDown(appointmentService.dispose);

    await _pumpView(tester, appointmentService);
    await tester.pump();

    await tester.tap(find.text('Reschedule'));
    await tester.pumpAndSettle();

    expect(find.text('Doctor profile'), findsOneWidget);
    expect(find.text('Available today'), findsOneWidget);
    // Confirms the tapped appointment reached DoctorProfileView as
    // `reschedulingAppointment` (not observable directly, but this label
    // only renders when it did — see book_appointment_button.dart) — the
    // regression guard for "Reschedule creates a new appointment instead
    // of editing the existing one".
    expect(find.text('Confirm reschedule'), findsOneWidget);
    expect(find.text('Book appointment'), findsNothing);
  });

  testWidgets(
    'Reschedule shows an error notice when the doctor can\'t be found',
    (tester) async {
      final appointmentService = FakeAppointmentService()
        ..upcomingAppointments = [_upcoming];
      addTearDown(appointmentService.dispose);

      await _pumpView(tester, appointmentService);
      await tester.pump();

      await tester.tap(find.text('Reschedule'));
      await tester.pump();

      expect(find.text('Couldn\'t find that doctor. Please try again.'), findsOneWidget);
    },
  );

  testWidgets(
    'Cancel appointment asks for confirmation, then cancels and refreshes',
    (tester) async {
      final appointmentService = FakeAppointmentService()
        ..upcomingAppointments = [_upcoming];
      addTearDown(appointmentService.dispose);
      final bookingService = FakeBookingService();

      await _pumpView(tester, appointmentService, bookingService: bookingService);
      await tester.pump();

      await tester.tap(find.text('Cancel appointment'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel this appointment?'), findsOneWidget);
      expect(bookingService.cancelledAppointmentId, isNull);

      // The dialog's "Cancel appointment" is the confirming action; its
      // "Cancel" is the dismiss action that backs out without cancelling.
      appointmentService.upcomingAppointments = const [];
      await tester.tap(find.widgetWithText(TextButton, 'Cancel appointment'));
      await tester.pumpAndSettle();

      expect(bookingService.cancelledAppointmentId, 'a1');
      expect(bookingService.cancelledDoctorId, '1');
      expect(bookingService.cancelledDate, '2099-01-02');
      expect(bookingService.cancelledSlot, '10:30 AM');
      expect(find.text('Appointment cancelled.'), findsOneWidget);
      // refresh() picked up the appointment no longer being upcoming.
      expect(find.text('Dr. Sara Whitmore'), findsNothing);
    },
  );

  testWidgets('Dismissing the cancel confirmation dialog cancels nothing', (
    tester,
  ) async {
    final appointmentService = FakeAppointmentService()
      ..upcomingAppointments = [_upcoming];
    addTearDown(appointmentService.dispose);
    final bookingService = FakeBookingService();

    await _pumpView(tester, appointmentService, bookingService: bookingService);
    await tester.pump();

    await tester.tap(find.text('Cancel appointment'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(bookingService.cancelledAppointmentId, isNull);
    expect(find.text('Dr. Sara Whitmore'), findsOneWidget);
  });

  testWidgets('Cancel appointment shows an error notice when it fails', (
    tester,
  ) async {
    final appointmentService = FakeAppointmentService()
      ..upcomingAppointments = [_upcoming];
    addTearDown(appointmentService.dispose);
    final bookingService = FakeBookingService()
      ..errorToThrow = Exception('permission-denied');

    await _pumpView(tester, appointmentService, bookingService: bookingService);
    await tester.pump();

    await tester.tap(find.text('Cancel appointment'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel appointment'));
    await tester.pumpAndSettle();

    expect(
      find.text('Couldn\'t cancel the appointment. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'falls back to a live doctor lookup for the Arabic name when the '
    'appointment\'s own doctorNameAr is missing',
    (tester) async {
      // _upcoming has no doctorNameAr — e.g. it was booked before the
      // doctor's Arabic name was added to their record.
      final appointmentService = FakeAppointmentService()
        ..upcomingAppointments = [_upcoming]
        ..doctorToReturn = const Doctor(
          id: '1',
          name: 'Dr. Sara Whitmore',
          nameAr: 'د. سارة ويتمور',
          specialty: 'Cardiologist',
          rating: 4.9,
        );
      addTearDown(appointmentService.dispose);

      await _pumpView(tester, appointmentService, locale: const Locale('ar'));
      await tester.pump();
      // The lookup resolves one microtask after the card first builds.
      await tester.pump();

      expect(find.text('د. سارة ويتمور'), findsOneWidget);
    },
  );
}
