import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';

/// Abstraction over the auth backend, so [AuthProvider] can be unit tested
/// with a fake instead of talking to real Firebase.
abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();

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

  @override
  Stream<AppUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(_toAppUser);
  }

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
            (Object e) => debugPrint('Failed to set display name: $e'),
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
            (Object e) => debugPrint('Failed to save user profile: $e'),
          ),
    );
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  AppUser? _toAppUser(fb.User? user) {
    if (user == null) return null;
    return AppUser(uid: user.uid, email: user.email);
  }
}
