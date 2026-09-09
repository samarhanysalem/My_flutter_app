import 'package:doctor_appointment_app/common/models/appointment.dart';
import 'package:doctor_appointment_app/features/auth/models/app_user.dart';
import 'package:doctor_appointment_app/features/auth/view/auth_provider.dart';
import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:doctor_appointment_app/navigation/main_nav_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../features/auth/fake_auth_repository.dart';
import '../features/home/fake_appointment_service.dart';

const _upcomingAppointment = Appointment(
  id: 'a1',
  patientId: 'u1',
  doctorId: '1',
  doctorName: 'Dr. Sara Whitmore',
  doctorSpecialty: 'Cardiologist',
  date: '2024-01-02',
  slot: '10:30 AM',
  status: 'confirmed',
);

Future<FakeAppointmentService> _pumpShell(
  WidgetTester tester, {
  List<Appointment> upcomingAppointments = const [],
}) async {
  // The default 800x600 test surface is too short to fit the greeting,
  // search bar, upcoming-appointment card, and specialty shortcuts above
  // the fold — see widget_test.dart's _pumpAuthApp for the same fix.
  tester.view.physicalSize = const Size(400, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final authProvider = AuthProvider(
    authRepository: FakeAuthRepository(
      initialUser: const AppUser(
        uid: 'u1',
        displayName: 'Alex Doe',
        email: 'alex@example.com',
      ),
    ),
  );
  // Lets the fake repository's current-user stream resolve before HomeView
  // is even built, so `patientId` is already non-null the one time
  // HomeProvider is created (Provider's `create` only runs once) — see
  // home_view_test.dart's `_signedInAuthProvider` for the same fix.
  await tester.pump();
  final appointmentService = FakeAppointmentService()
    ..upcomingAppointments = upcomingAppointments;
  addTearDown(appointmentService.dispose);
  await tester.pumpWidget(
    ChangeNotifierProvider<AuthProvider>.value(
      value: authProvider,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MainNavShell(appointmentService: appointmentService),
      ),
    ),
  );
  await tester.pump();
  appointmentService.emitDoctors(const []);
  await tester.pumpAndSettle();
  return appointmentService;
}

void main() {
  testWidgets('starts on the Home tab and switches tabs via the bottom nav', (
    tester,
  ) async {
    await _pumpShell(tester);

    expect(find.text('Our doctors'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pump();

    expect(find.text('Our doctors'), findsNothing);
    expect(find.text('alex@example.com'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pump();

    expect(find.text('Our doctors'), findsOneWidget);
  });

  testWidgets(
    'View details on the upcoming appointment card switches to Appointments and shows it',
    (tester) async {
      // My appointments fetches its own Upcoming list (independent of
      // Home's upcoming-card stream below), so the fake needs it primed
      // before the shell — and therefore MyAppointmentsProvider — is built.
      final appointmentService = await _pumpShell(
        tester,
        upcomingAppointments: [_upcomingAppointment],
      );

      appointmentService.emitUpcomingAppointment(_upcomingAppointment);
      await tester.pumpAndSettle();

      await tester.tap(find.text('View details'));
      await tester.pumpAndSettle();

      expect(find.text('Dr. Sara Whitmore'), findsOneWidget);
      expect(find.textContaining('10:30 AM'), findsOneWidget);
    },
  );
}
