import 'package:doctor_appointment_app/common/models/appointment.dart';
import 'package:doctor_appointment_app/common/models/doctor.dart';
import 'package:doctor_appointment_app/features/appointments/view/my_appointments_view.dart';
import 'package:doctor_appointment_app/features/auth/models/app_user.dart';
import 'package:doctor_appointment_app/features/auth/view/auth_provider.dart';
import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:doctor_appointment_app/navigation/nav_shell_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../auth/fake_auth_repository.dart';
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
  NavShellController? navController,
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

  Widget child = MyAppointmentsView(appointmentService: appointmentService);
  if (navController != null) {
    child = ChangeNotifierProvider<NavShellController>.value(
      value: navController,
      child: child,
    );
  }

  await tester.pumpWidget(
    ChangeNotifierProvider<AuthProvider>.value(
      value: authProvider,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
}

void main() {
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
    expect(find.text('Get directions'), findsOneWidget);
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
      expect(find.text('Get directions'), findsNothing);
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
    'Get directions surfaces an error notice when it can\'t open maps',
    (tester) async {
      // url_launcher has no real platform implementation in a widget test —
      // its method channel is mocked to return false (can't launch) rather
      // than left unimplemented, since an unmocked call never resolves
      // inside a widget test (unlike the MissingPluginException it throws
      // outside one), which would hang this test instead of exercising the
      // try/catch fallback below.
      const channel = MethodChannel('plugins.flutter.io/url_launcher');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => false);
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });

      final appointmentService = FakeAppointmentService()
        ..upcomingAppointments = [_upcoming];
      addTearDown(appointmentService.dispose);

      await _pumpView(tester, appointmentService);
      await tester.pump();

      await tester.tap(find.text('Get directions'));
      await tester.pumpAndSettle();

      expect(find.text('Couldn\'t open maps. Please try again.'), findsOneWidget);
    },
  );
}
