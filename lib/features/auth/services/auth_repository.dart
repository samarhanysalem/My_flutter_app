import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../models/app_user.dart';

/// Abstraction over the auth backend, so [AuthProvider] can be unit tested
/// with a fake instead of talking to real Firebase.
abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();

  /// One-shot notices for failures that happen *after* an auth action has
  /// already succeeded (e.g. a best-effort profile save) — not blocking
  /// errors, just something the UI may want to surface to the user.
  Stream<String> get profileWarnings;

  Future<void> signIn({required String email, required String password});

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  });

  Future<void> signOut();
}

/// User-facing auth failure. Implementations translate backend-specific
/// exceptions (e.g. `FirebaseAuthException`) into this so callers never
/// need to depend on the backend SDK's exception types.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({fb.FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
    : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  // Enrichment (display name / Firestore profile doc) runs unawaited right
  // after sign-up, before the UI has necessarily navigated to a screen that
  // listens for warnings. A plain broadcast StreamController drops events
  // with no listener attached, so queue them here and flush on the next
  // subscribe instead of losing them.
  final _queuedProfileWarnings = <String>[];
  late final StreamController<String> _profileWarnings = StreamController<String>.broadcast(
    onListen: () {
      for (final message in _queuedProfileWarnings) {
        _profileWarnings.add(message);
      }
      _queuedProfileWarnings.clear();
    },
  );

  void _addProfileWarning(String message) {
    if (_profileWarnings.hasListener) {
      _profileWarnings.add(message);
    } else {
      _queuedProfileWarnings.add(message);
    }
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(_toAppUser);
  }

  @override
  Stream<String> get profileWarnings => _profileWarnings.stream;

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to sign in.');
    }
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    final fb.UserCredential credential;
    try {
      credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to sign up.');
    }

    // The account already exists and authStateChanges() has already fired
    // by this point, so sign-up itself is done. Saving the display name and
    // profile doc is best-effort enrichment — it shouldn't block completion
    // or leave the caller waiting if it's slow or fails.
    final user = credential.user;
    if (user == null) return;
    unawaited(
      user
          .updateDisplayName(fullName)
          .catchError(
            (Object e) => _addProfileWarning(
              "Couldn't save your name — you can update it later.",
            ),
          ),
    );
    unawaited(
      _firestore
          .collection('users')
          .doc(user.uid)
          .set({
            'fullName': fullName,
            'email': email,
            'phone': phone,
            'createdAt': FieldValue.serverTimestamp(),
          })
          .catchError(
            (Object e) => _addProfileWarning(
              "Couldn't save your profile details — you can update them later.",
            ),
          ),
    );
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  AppUser? _toAppUser(fb.User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }
}
