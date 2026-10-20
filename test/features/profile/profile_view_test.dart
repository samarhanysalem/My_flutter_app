import 'package:doctor_appointment_app/common/models/app_user.dart';
import 'package:doctor_appointment_app/features/auth/view/auth_provider.dart';
import 'package:doctor_appointment_app/common/models/user_profile.dart';
import 'package:doctor_appointment_app/common/repositories/profile_repository.dart';
import 'package:doctor_appointment_app/features/profile/view/profile_view.dart';
import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../common/repositories/fake_auth_repository.dart';
import '../../common/repositories/fake_profile_repository.dart';

const _profile = UserProfile(
  fullName: 'Alex Doe',
  email: 'alex@example.com',
  phone: '+1 555 0100',
);

Future<void> _pumpView(
  WidgetTester tester,
  FakeProfileRepository profileRepository,
) async {
  final authProvider = AuthProvider(
    authRepository: FakeAuthRepository(
      initialUser: const AppUser(
        uid: 'u1',
        email: 'alex@example.com',
        displayName: 'Alex Doe',
      ),
    ),
  );
  // Lets the fake repository's current-user stream resolve before
  // ProfileView is built, so `uid`/`email` are already non-null the one
  // time ProfileProvider is created — see home_view_test.dart's
  // `_signedInAuthProvider` for the same fix.
  await tester.pump();

  await tester.pumpWidget(
    ChangeNotifierProvider<AuthProvider>.value(
      value: authProvider,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProfileView(profileRepository: profileRepository),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the loaded name, phone, and email', (tester) async {
    final profileRepository = FakeProfileRepository()..profileToReturn = _profile;
    await _pumpView(tester, profileRepository);
    await tester.pump();

    expect(find.text('alex@example.com'), findsWidgets);
    expect(find.text('Alex Doe'), findsWidgets);
    expect(find.text('+1 555 0100'), findsOneWidget);
  });

  testWidgets('shows a load error message when fetching the profile fails', (
    tester,
  ) async {
    final profileRepository = FakeProfileRepository()
      ..getProfileErrorToThrow = Exception('offline');
    await _pumpView(tester, profileRepository);
    await tester.pump();

    expect(
      find.text("Couldn't load your profile. Please try again."),
      findsOneWidget,
    );
  });

  testWidgets(
    'editing name and phone then Save updates the profile and shows a success snackbar',
    (tester) async {
      final profileRepository = FakeProfileRepository()..profileToReturn = _profile;
      await _pumpView(tester, profileRepository);
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('authField_profileFullName')),
        'Alexandra Doe',
      );
      await tester.enterText(
        find.byKey(const Key('authField_profilePhone')),
        '+1 555 0199',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(profileRepository.updateProfileCalled, isTrue);
      expect(profileRepository.lastFullName, 'Alexandra Doe');
      expect(profileRepository.lastPhone, '+1 555 0199');
      expect(find.text('Profile updated.'), findsOneWidget);
    },
  );

  testWidgets('Save shows a generic error snackbar when it fails', (
    tester,
  ) async {
    final profileRepository = FakeProfileRepository()
      ..profileToReturn = _profile
      ..errorToThrow = Exception('network');
    await _pumpView(tester, profileRepository);
    await tester.pump();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't update your profile. Please try again."),
      findsOneWidget,
    );
  });

  testWidgets(
    'Change password succeeds with the correct current password',
    (tester) async {
      final profileRepository = FakeProfileRepository()..profileToReturn = _profile;
      await _pumpView(tester, profileRepository);
      await tester.pump();

      await tester.tap(find.text('Change password'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('authField_currentPassword')),
        'oldpassword1',
      );
      await tester.enterText(
        find.byKey(const Key('authField_newPassword')),
        'newpassword2',
      );
      await tester.tap(find.widgetWithText(TextButton, 'Change password'));
      await tester.pumpAndSettle();

      expect(profileRepository.changePasswordCalled, isTrue);
      expect(profileRepository.lastCurrentPassword, 'oldpassword1');
      expect(profileRepository.lastNewPassword, 'newpassword2');
      expect(find.text('Password changed.'), findsOneWidget);
    },
  );

  testWidgets(
    'Change password shows the specific error and stays open for a wrong current password',
    (tester) async {
      final profileRepository = FakeProfileRepository()
        ..profileToReturn = _profile
        ..errorToThrow = const ProfileException('That password is incorrect.');
      await _pumpView(tester, profileRepository);
      await tester.pump();

      await tester.tap(find.text('Change password'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('authField_currentPassword')),
        'wrongpassword',
      );
      await tester.enterText(
        find.byKey(const Key('authField_newPassword')),
        'newpassword2',
      );
      await tester.tap(find.widgetWithText(TextButton, 'Change password'));
      await tester.pumpAndSettle();

      expect(find.text('That password is incorrect.'), findsOneWidget);
      // The dialog is still open — its confirm button is still there.
      expect(find.widgetWithText(TextButton, 'Change password'), findsOneWidget);
    },
  );

  testWidgets('Delete account calls deleteAccount with the entered password', (
    tester,
  ) async {
    final profileRepository = FakeProfileRepository()..profileToReturn = _profile;
    await _pumpView(tester, profileRepository);
    await tester.pump();

    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();

    expect(find.text("This will permanently delete your account and all your data. This can't be undone."), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('authField_deleteAccountPassword')),
      'mypassword1',
    );
    await tester.tap(find.widgetWithText(TextButton, 'Delete account'));
    await tester.pumpAndSettle();

    expect(profileRepository.deleteAccountCalled, isTrue);
  });

  testWidgets(
    'Delete account shows the specific error and stays open for a wrong password',
    (tester) async {
      final profileRepository = FakeProfileRepository()
        ..profileToReturn = _profile
        ..errorToThrow = const ProfileException('That password is incorrect.');
      await _pumpView(tester, profileRepository);
      await tester.pump();

      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('authField_deleteAccountPassword')),
        'wrongpassword',
      );
      await tester.tap(find.widgetWithText(TextButton, 'Delete account'));
      await tester.pumpAndSettle();

      expect(find.text('That password is incorrect.'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Delete account'), findsOneWidget);
    },
  );

  testWidgets('Log out opens the sign-out confirmation dialog', (
    tester,
  ) async {
    final profileRepository = FakeProfileRepository()..profileToReturn = _profile;
    await _pumpView(tester, profileRepository);
    await tester.pump();

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Sign out?'), findsOneWidget);
  });
}
