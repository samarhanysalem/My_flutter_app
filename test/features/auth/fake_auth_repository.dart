import 'dart:async';

import 'package:doctor_appointment_app/features/auth/models/app_user.dart';
import 'package:doctor_appointment_app/features/auth/services/auth_repository.dart';

/// Hand-written test double so auth tests never touch real Firebase.
///
/// Mirrors `FirebaseAuth.authStateChanges()`'s behavior of replaying the
/// current user to each new subscriber, rather than dropping it the way a
/// plain broadcast `StreamController` would for a listener that hasn't
/// subscribed yet.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AppUser? initialUser}) : _currentUser = initialUser {
    _controller = StreamController<AppUser?>.broadcast(
      onListen: () => _controller.add(_currentUser),
    );
  }

  late final StreamController<AppUser?> _controller;
  AppUser? _currentUser;

  /// Set to make the next [signIn]/[signUp] call fail with this error.
  AuthException? errorToThrow;

  bool signInCalled = false;
  bool signUpCalled = false;
  bool signOutCalled = false;

  @override
  Stream<AppUser?> authStateChanges() => _controller.stream;

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCalled = true;
    if (errorToThrow != null) throw errorToThrow!;
    _currentUser = AppUser(uid: 'test-uid', email: email);
    _controller.add(_currentUser);
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    signUpCalled = true;
    if (errorToThrow != null) throw errorToThrow!;
    _currentUser = AppUser(uid: 'test-uid', email: email);
    _controller.add(_currentUser);
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    _currentUser = null;
    _controller.add(null);
  }

  void dispose() => _controller.close();
}
