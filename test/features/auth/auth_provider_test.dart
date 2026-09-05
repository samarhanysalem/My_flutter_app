import 'package:doctor_appointment_app/features/auth/models/app_user.dart';
import 'package:doctor_appointment_app/features/auth/services/auth_repository.dart';
import 'package:doctor_appointment_app/features/auth/view/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_auth_repository.dart';

void main() {
  group('AuthProvider', () {
    test('starts unknown then becomes unauthenticated with no user', () async {
      final repository = FakeAuthRepository();
      final provider = AuthProvider(authRepository: repository);
      expect(provider.status, AuthStatus.unknown);

      await Future<void>.delayed(Duration.zero);

      expect(provider.status, AuthStatus.unauthenticated);
      expect(provider.user, isNull);

      provider.dispose();
      repository.dispose();
    });

    test('starts authenticated when repository already has a user', () async {
      final repository = FakeAuthRepository(
        initialUser: const AppUser(uid: 'u1', email: 'a@b.com'),
      );
      final provider = AuthProvider(authRepository: repository);

      await Future<void>.delayed(Duration.zero);

      expect(provider.status, AuthStatus.authenticated);
      expect(provider.user?.uid, 'u1');

      provider.dispose();
      repository.dispose();
    });

    test('signIn success clears error and becomes authenticated', () async {
      final repository = FakeAuthRepository();
      final provider = AuthProvider(authRepository: repository);
      await Future<void>.delayed(Duration.zero);

      await provider.signIn(email: 'a@b.com', password: 'password123');

      expect(repository.signInCalled, isTrue);
      expect(provider.status, AuthStatus.authenticated);
      expect(provider.errorMessage, isNull);
      expect(provider.isLoading, isFalse);

      provider.dispose();
      repository.dispose();
    });

    test('signIn failure surfaces the error and stays unauthenticated', () async {
      final repository = FakeAuthRepository()
        ..errorToThrow = const AuthException('Invalid credentials.');
      final provider = AuthProvider(authRepository: repository);
      await Future<void>.delayed(Duration.zero);

      await provider.signIn(email: 'a@b.com', password: 'wrong');

      expect(provider.errorMessage, 'Invalid credentials.');
      expect(provider.status, AuthStatus.unauthenticated);
      expect(provider.isLoading, isFalse);

      provider.dispose();
      repository.dispose();
    });

    test('signOut clears the user', () async {
      final repository = FakeAuthRepository(
        initialUser: const AppUser(uid: 'u1'),
      );
      final provider = AuthProvider(authRepository: repository);
      await Future<void>.delayed(Duration.zero);
      expect(provider.status, AuthStatus.authenticated);

      await provider.signOut();

      expect(repository.signOutCalled, isTrue);
      expect(provider.status, AuthStatus.unauthenticated);

      provider.dispose();
      repository.dispose();
    });
  });
}
