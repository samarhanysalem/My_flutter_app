import 'package:doctor_appointment_app/config/locale_provider.dart';
import 'package:doctor_appointment_app/features/auth/view/auth_provider.dart';
import 'package:doctor_appointment_app/features/auth/view/login_view.dart';
import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_auth_repository.dart';

/// Mirrors how `MyApp` wires `LocaleProvider` into `MaterialApp.locale`, so
/// switching the language actually re-renders in the new language — not
/// just LoginView in isolation.
Widget _appUnderTest(AuthProvider authProvider) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
    ],
    child: Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) => MaterialApp(
        locale: localeProvider.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const LoginView(),
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('defaults to English and offers an Arabic option', (
    tester,
  ) async {
    final authProvider = AuthProvider(authRepository: FakeAuthRepository());
    await tester.pumpWidget(_appUnderTest(authProvider));
    await tester.pump();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });

  testWidgets('switching to Arabic re-renders the screen in Arabic and RTL', (
    tester,
  ) async {
    final authProvider = AuthProvider(authRepository: FakeAuthRepository());
    await tester.pumpWidget(_appUnderTest(authProvider));
    await tester.pump();

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('العربية').last);
    await tester.pumpAndSettle();

    expect(find.text('مرحبًا بعودتك'), findsOneWidget);
    expect(find.text('Welcome back'), findsNothing);

    final direction = Directionality.of(
      tester.element(find.text('مرحبًا بعودتك')),
    );
    expect(direction, TextDirection.rtl);
  });

  testWidgets('the chosen language persists across app restarts', (
    tester,
  ) async {
    final authProvider = AuthProvider(authRepository: FakeAuthRepository());
    await tester.pumpWidget(_appUnderTest(authProvider));
    await tester.pump();

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('العربية').last);
    await tester.pumpAndSettle();
    expect(find.text('مرحبًا بعودتك'), findsOneWidget);

    // Simulate a fresh app launch: a new LocaleProvider re-reads the saved
    // preference instead of starting from nothing.
    await tester.pumpWidget(
      _appUnderTest(AuthProvider(authRepository: FakeAuthRepository())),
    );
    await tester.pumpAndSettle();

    expect(find.text('مرحبًا بعودتك'), findsOneWidget);
  });
}
