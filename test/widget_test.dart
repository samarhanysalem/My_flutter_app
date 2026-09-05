import 'package:doctor_appointment_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'features/auth/fake_auth_repository.dart';

void main() {
  testWidgets('Signed-out user sees the sign-in form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(authRepository: FakeAuthRepository()));
    await tester.pump();

    expect(find.text('Sign in'), findsWidgets);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('Signing in reveals the home page and the counter works', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(authRepository: FakeAuthRepository()));
    await tester.pump();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'doctor@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'password123',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
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
