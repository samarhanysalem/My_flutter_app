import 'package:doctor_appointment_app/features/auth/widgets/terms_checkbox.dart';
import 'package:doctor_appointment_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'features/auth/fake_auth_repository.dart';

/// The login/register forms are taller than the default 800x600 test
/// surface; widgets below the fold fail to hit-test inside the
/// SingleChildScrollView unless the surface is made tall enough to fit them.
Future<void> _pumpAuthApp(WidgetTester tester, FakeAuthRepository repository) async {
  tester.view.physicalSize = const Size(400, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MyApp(authRepository: repository));
  await tester.pump();
}

void main() {
  testWidgets('Signed-out user sees the login form', (
    WidgetTester tester,
  ) async {
    await _pumpAuthApp(tester, FakeAuthRepository());

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
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
      await _pumpAuthApp(tester, FakeAuthRepository());

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
      await tester.pumpAndSettle();

      expect(find.text('Doctor Appointment App'), findsOneWidget);
    },
  );

  testWidgets('Signing in reveals the home page and the counter works', (
    WidgetTester tester,
  ) async {
    await _pumpAuthApp(tester, FakeAuthRepository());

    await tester.enterText(
      find.byKey(const Key('authField_Email')),
      'doctor@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('authField_Password')),
      'password123',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle();

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
