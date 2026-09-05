import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

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
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) return;
      await user.updateDisplayName(fullName);
      await _firestore.collection('users').doc(user.uid).set({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to sign up.');
    }
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  AppUser? _toAppUser(fb.User? user) {
    if (user == null) return null;
    return AppUser(uid: user.uid, email: user.email);
  }
}
