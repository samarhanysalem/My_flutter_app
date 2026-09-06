import 'package:doctor_appointment_app/features/auth/widgets/terms_checkbox.dart';
import 'package:doctor_appointment_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'features/auth/fake_auth_repository.dart';
import 'features/home/fake_appointment_service.dart';

/// The login/register forms are taller than the default 800x600 test
/// surface; widgets below the fold fail to hit-test inside the
/// SingleChildScrollView unless the surface is made tall enough to fit them.
///
/// Returns the fake `AppointmentService` a signed-in user's Home screen
/// will fetch doctors from — swapped in so these auth-flow tests never
/// touch real Firestore. Once a test reaches Home, it must call
/// `emitDoctors(...)` on it (see `_settleOnHome`) before `pumpAndSettle()`:
/// Home's loading spinner animates indefinitely until doctors arrive, and
/// pumpAndSettle() never returns while something is still animating.
Future<FakeAppointmentService> _pumpAuthApp(
  WidgetTester tester,
  FakeAuthRepository repository,
) async {
  tester.view.physicalSize = const Size(400, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final appointmentService = FakeAppointmentService();
  addTearDown(appointmentService.dispose);
  await tester.pumpWidget(
    MyApp(authRepository: repository, appointmentService: appointmentService),
  );
  await tester.pump();
  return appointmentService;
}

/// Call right after an action that lands on Home (sign in / sign up) and
/// before asserting on it — see `_pumpAuthApp` for why.
Future<void> _settleOnHome(
  WidgetTester tester,
  FakeAppointmentService appointmentService,
) async {
  await tester.pump();
  appointmentService.emitDoctors(const []);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Signed-out user sees the login form', (
    WidgetTester tester,
  ) async {
    await _pumpAuthApp(tester, FakeAuthRepository());

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('Password field visibility toggle shows and hides the password', (
    WidgetTester tester,
  ) async {
    await _pumpAuthApp(tester, FakeAuthRepository());

    final passwordField = find.descendant(
      of: find.byKey(const Key('authField_Password')),
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(passwordField).obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    expect(tester.widget<TextField>(passwordField).obscureText, isFalse);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();

    expect(tester.widget<TextField>(passwordField).obscureText, isTrue);
  });

  testWidgets('Register link navigates to the register screen and back', (
    WidgetTester tester,
  ) async {
    await _pumpAuthApp(tester, FakeAuthRepository());

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets(
    'Create account is disabled until terms are accepted, then signs up',
    (WidgetTester tester) async {
      final appointmentService = await _pumpAuthApp(
        tester,
        FakeAuthRepository(),
      );

      await tester.tap(find.text('Create an account'));
      await tester.pumpAndSettle();

      final createAccountButton = find.widgetWithText(
        ElevatedButton,
        'Create account',
      );
      expect(
        tester.widget<ElevatedButton>(createAccountButton).onPressed,
        isNull,
      );

      await tester.enterText(
        find.byKey(const Key('authField_Full name')),
        'Yara Bennett',
      );
      await tester.enterText(
        find.byKey(const Key('authField_Email')),
        'yara@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('authField_Phone')),
        '+61 400 000 000',
      );
      await tester.enterText(
        find.byKey(const Key('authField_Password')),
        'password123',
      );

      await tester.tap(find.byType(TermsCheckbox));
      await tester.pump();
      expect(
        tester.widget<ElevatedButton>(createAccountButton).onPressed,
        isNotNull,
      );

      await tester.tap(createAccountButton);
      await _settleOnHome(tester, appointmentService);

      expect(find.text('Nearby doctors'), findsOneWidget);
    },
  );

  testWidgets('Invalid email is rejected before signing in', (
    WidgetTester tester,
  ) async {
    final repository = FakeAuthRepository();
    await _pumpAuthApp(tester, repository);

    await tester.enterText(
      find.byKey(const Key('authField_Email')),
      'not-an-email',
    );
    await tester.enterText(
      find.byKey(const Key('authField_Password')),
      'password123',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pump();

    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(repository.signInCalled, isFalse);
  });

  testWidgets('Signing in reveals the home page', (WidgetTester tester) async {
    final appointmentService = await _pumpAuthApp(
      tester,
      FakeAuthRepository(),
    );

    await tester.enterText(
      find.byKey(const Key('authField_Email')),
      'doctor@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('authField_Password')),
      'password123',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await _settleOnHome(tester, appointmentService);

    expect(find.text('Welcome back'), findsNothing);
    expect(find.text('Nearby doctors'), findsOneWidget);
  });
}
