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
  final _profileWarningsController = StreamController<String>.broadcast();
  AppUser? _currentUser;

  /// Set to make the next [signIn]/[signUp] call fail with this error.
  AuthException? errorToThrow;

  bool signInCalled = false;
  bool signUpCalled = false;
  bool signOutCalled = false;
  String? lastFullName;
  String? lastPhone;

  @override
  Stream<AppUser?> authStateChanges() => _controller.stream;

  @override
  Stream<String> get profileWarnings => _profileWarningsController.stream;

  /// Lets a test simulate a repository-level profile warning (e.g. a failed
  /// best-effort profile save) to verify it reaches [AuthProvider].
  void emitProfileWarning(String message) =>
      _profileWarningsController.add(message);

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCalled = true;
    if (errorToThrow != null) throw errorToThrow!;
    _currentUser = AppUser(uid: 'test-uid', email: email);
    _controller.add(_currentUser);
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    signUpCalled = true;
    lastFullName = fullName;
    lastPhone = phone;
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

  void dispose() {
    _controller.close();
    _profileWarningsController.close();
  }
}
