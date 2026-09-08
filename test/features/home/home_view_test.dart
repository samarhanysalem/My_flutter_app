import 'package:doctor_appointment_app/common/models/appointment.dart';
import 'package:doctor_appointment_app/common/models/doctor.dart';
import 'package:doctor_appointment_app/features/auth/models/app_user.dart';
import 'package:doctor_appointment_app/features/auth/view/auth_provider.dart';
import 'package:doctor_appointment_app/features/home/view/home_view.dart';
import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:doctor_appointment_app/navigation/nav_shell_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../auth/fake_auth_repository.dart';
import 'fake_appointment_service.dart';

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

const _doctors = [
  Doctor(
    id: '1',
    name: 'Dr. Sara Whitmore',
    specialty: 'Cardiologist',
    rating: 4.9,
  ),
  Doctor(
    id: '2',
    name: 'Dr. Marcus Cole',
    specialty: 'Orthopedic Surgeon',
    rating: 4.8,
  ),
];

Future<AuthProvider> _signedInAuthProvider(WidgetTester tester) async {
  final repository = FakeAuthRepository(
    initialUser: const AppUser(uid: 'u1', displayName: 'Alex Doe'),
  );
  final authProvider = AuthProvider(authRepository: repository);
  await tester.pump();
  return authProvider;
}

Future<void> _pumpHome(
  WidgetTester tester,
  AuthProvider authProvider,
  FakeAppointmentService appointmentService,
) async {
  await tester.pumpWidget(
    // The AuthProvider is provided above MaterialApp (not inside `home:`)
    // so it's still reachable from routes HomeView pushes via Navigator —
    // a route pushed later is a sibling of `home:`'s content in the
    // widget tree, not a descendant of it, so a provider placed inside
    // `home:` wouldn't be visible there.
    ChangeNotifierProvider<AuthProvider>.value(
      value: authProvider,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeView(appointmentService: appointmentService),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('shows a greeting with the signed-in user\'s first name', (
    tester,
  ) async {
    final authProvider = await _signedInAuthProvider(tester);
    final appointmentService = FakeAppointmentService();
    await _pumpHome(tester, authProvider, appointmentService);

    expect(find.textContaining('Alex'), findsOneWidget);

    appointmentService.dispose();
  });

  testWidgets('shows a loading indicator, then the fetched doctors', (
    tester,
  ) async {
    final authProvider = await _signedInAuthProvider(tester);
    final appointmentService = FakeAppointmentService();
    await _pumpHome(tester, authProvider, appointmentService);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    appointmentService.emitDoctors(_doctors);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Dr. Sara Whitmore'), findsOneWidget);
    expect(find.text('Dr. Marcus Cole'), findsOneWidget);

    appointmentService.dispose();
  });

  testWidgets('shows an empty state when there are no doctors', (
    tester,
  ) async {
    final authProvider = await _signedInAuthProvider(tester);
    final appointmentService = FakeAppointmentService();
    await _pumpHome(tester, authProvider, appointmentService);

    appointmentService.emitDoctors(const []);
    await tester.pump();

    expect(find.text('No doctors available yet.'), findsOneWidget);

    appointmentService.dispose();
  });

  testWidgets('search bar filters the doctor list by name', (tester) async {
    final authProvider = await _signedInAuthProvider(tester);
    final appointmentService = FakeAppointmentService();
    await _pumpHome(tester, authProvider, appointmentService);

    appointmentService.emitDoctors(_doctors);
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Cole');
    await tester.pump();

    // Dismiss the autocomplete suggestion overlay (which would otherwise
    // also render a "Dr. Marcus Cole" match) so this only checks the
    // filtered doctor list underneath.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    expect(find.text('Dr. Marcus Cole'), findsOneWidget);
    expect(find.text('Dr. Sara Whitmore'), findsNothing);

    appointmentService.dispose();
  });

  testWidgets('tapping a specialty shortcut filters the doctor list', (
    tester,
  ) async {
    final authProvider = await _signedInAuthProvider(tester);
    final appointmentService = FakeAppointmentService();
    await _pumpHome(tester, authProvider, appointmentService);

    appointmentService.emitDoctors(_doctors);
    await tester.pump();

    await tester.tap(find.text('Cardio'));
    await tester.pump();

    expect(find.text('Dr. Sara Whitmore'), findsOneWidget);
    expect(find.text('Dr. Marcus Cole'), findsNothing);

    appointmentService.dispose();
  });

  testWidgets('tapping All clears an active specialty filter', (
    tester,
  ) async {
    final authProvider = await _signedInAuthProvider(tester);
    final appointmentService = FakeAppointmentService();
    await _pumpHome(tester, authProvider, appointmentService);

    appointmentService.emitDoctors(_doctors);
    await tester.pump();

    await tester.tap(find.text('Cardio'));
    await tester.pump();
    expect(find.text('Dr. Marcus Cole'), findsNothing);

    await tester.tap(find.text('All'));
    await tester.pump();

    expect(find.text('Dr. Sara Whitmore'), findsOneWidget);
    expect(find.text('Dr. Marcus Cole'), findsOneWidget);

    appointmentService.dispose();
  });

  testWidgets('tapping a doctor card opens their profile', (tester) async {
    final authProvider = await _signedInAuthProvider(tester);
    final appointmentService = FakeAppointmentService();
    await _pumpHome(tester, authProvider, appointmentService);

    appointmentService.emitDoctors(_doctors);
    await tester.pump();

    await tester.tap(find.text('Dr. Sara Whitmore'));
    await tester.pumpAndSettle();

    expect(find.text('Doctor profile'), findsOneWidget);
    expect(
      find.text('Dr. Sara Whitmore'),
      findsOneWidget,
    ); // now the hero's name, not the list card
    expect(find.text('Available today'), findsOneWidget);

    appointmentService.dispose();
  });

  testWidgets(
    'hides the upcoming appointment card when there is none, shows it once one arrives',
    (tester) async {
      final authProvider = await _signedInAuthProvider(tester);
      final appointmentService = FakeAppointmentService();
      await _pumpHome(tester, authProvider, appointmentService);

      // No upcoming appointment yet — the layout collapses straight from
      // the search bar to the specialty shortcuts.
      expect(find.text('UPCOMING APPOINTMENT'), findsNothing);

      appointmentService.emitUpcomingAppointment(_upcomingAppointment);
      await tester.pump();

      expect(find.text('UPCOMING APPOINTMENT'), findsOneWidget);
      expect(find.text('Dr. Sara Whitmore'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('View details'), findsOneWidget);

      appointmentService.dispose();
    },
  );

  testWidgets(
    '"View details" on the upcoming appointment card switches to the Appointments tab',
    (tester) async {
      final authProvider = await _signedInAuthProvider(tester);
      final appointmentService = FakeAppointmentService();
      final navController = NavShellController();

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ChangeNotifierProvider<NavShellController>.value(
              value: navController,
              child: HomeView(appointmentService: appointmentService),
            ),
          ),
        ),
      );
      await tester.pump();

      appointmentService.emitUpcomingAppointment(_upcomingAppointment);
      await tester.pump();

      await tester.tap(find.text('View details'));
      await tester.pump();

      expect(navController.selectedTab, MainTab.appointments);
      expect(navController.appointmentToShow, _upcomingAppointment);

      appointmentService.dispose();
    },
  );
}
