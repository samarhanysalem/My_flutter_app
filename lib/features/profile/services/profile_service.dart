import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../models/user_profile.dart';

/// Thrown when a profile action (save, password change, account deletion)
/// can't be completed — e.g. a wrong current password on reauthentication.
class ProfileException implements Exception {
  const ProfileException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Abstraction over the profile backend, so `ProfileProvider` can be unit
/// tested with a fake instead of talking to real Firebase.
abstract class ProfileService {
  /// [uid]'s `users` document, or `null` if it doesn't exist yet (e.g. the
  /// best-effort write at sign-up failed — see
  /// `FirebaseAuthRepository.signUp`).
  Future<UserProfile?> getProfile(String uid);

  /// Updates [uid]'s Firestore profile doc and Firebase Auth display name to
  /// [fullName]/[phone].
  Future<void> updateProfile({
    required String uid,
    required String fullName,
    required String phone,
  });

  /// Changes the signed-in user's password. Firebase requires a recently
  /// issued sign-in credential for this, so [currentPassword] is used to
  /// reauthenticate first — surfaced as a [ProfileException] if it's wrong.
  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  });

  /// Deletes the signed-in user's `users` document and their Firebase Auth
  /// account. Reauthenticates with [currentPassword] first, for the same
  /// reason as [changePassword].
  Future<void> deleteAccount({
    required String email,
    required String currentPassword,
  });
}

class FirestoreProfileService implements ProfileService {
  FirestoreProfileService({fb.FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
    : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  @override
  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) return null;
    return UserProfile.fromFirestore(data);
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required String fullName,
    required String phone,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'fullName': fullName,
      'phone': phone,
    }, SetOptions(merge: true));
    await _firebaseAuth.currentUser?.updateDisplayName(fullName);
  }

  Future<void> _reauthenticate(String email, String currentPassword) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const ProfileException('You need to sign in again to do this.');
    }
    try {
      await user.reauthenticateWithCredential(
        fb.EmailAuthProvider.credential(email: email, password: currentPassword),
      );
    } on fb.FirebaseAuthException catch (e) {
      throw ProfileException(e.message ?? 'That password is incorrect.');
    }
  }

  @override
  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    await _reauthenticate(email, currentPassword);
    try {
      await _firebaseAuth.currentUser?.updatePassword(newPassword);
    } on fb.FirebaseAuthException catch (e) {
      throw ProfileException(e.message ?? 'Failed to change your password.');
    }
  }

  @override
  Future<void> deleteAccount({
    required String email,
    required String currentPassword,
  }) async {
    await _reauthenticate(email, currentPassword);
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    // The Firestore doc is removed first: once the Auth account is deleted,
    // the user is signed out and would no longer pass this app's
    // `request.auth.uid == uid`-style security rules to clean it up after.
    await _firestore.collection('users').doc(user.uid).delete();
    try {
      await user.delete();
    } on fb.FirebaseAuthException catch (e) {
      throw ProfileException(e.message ?? 'Failed to delete your account.');
    }
  }
}
