import 'package:flutter/foundation.dart';

import '../services/profile_service.dart';

/// Owns the signed-in patient's editable profile fields plus the
/// loading/saving/error state for fetching them and for the three actions
/// Profile exposes: saving name/phone, changing password, and deleting the
/// account. A one-time fetch on construction (not a stream) — matching
/// `MyAppointmentsProvider`'s reasoning for its own one-time fetches.
class ProfileProvider extends ChangeNotifier {
  ProfileProvider({
    required ProfileService profileService,
    required String? uid,
    required String? email,
  }) : _profileService = profileService,
       _uid = uid,
       _email = email {
    if (uid == null) {
      _isLoading = false;
    } else {
      _load(uid);
    }
  }

  final ProfileService _profileService;
  final String? _uid;
  final String? _email;

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  bool _hasLoadError = false;
  bool get hasLoadError => _hasLoadError;

  String _fullName = '';
  String get fullName => _fullName;
  String _phone = '';
  String get phone => _phone;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  bool _isChangingPassword = false;
  bool get isChangingPassword => _isChangingPassword;
  String? _passwordError;
  String? get passwordError => _passwordError;

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;
  String? _deleteError;
  String? get deleteError => _deleteError;

  Future<void> _load(String uid) async {
    try {
      final profile = await _profileService.getProfile(uid);
      _fullName = profile?.fullName ?? '';
      _phone = profile?.phone ?? '';
      _hasLoadError = false;
    } catch (_) {
      _hasLoadError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Saves [fullName]/[phone], returning whether it succeeded. The caller
  /// shows a generic localized message on failure — unlike
  /// [changePassword]/[deleteAccount], there's no reauthentication step
  /// whose specific failure reason (e.g. a wrong password) the patient
  /// needs to see.
  Future<bool> save({required String fullName, required String phone}) async {
    final uid = _uid;
    if (uid == null) return false;
    _isSaving = true;
    notifyListeners();
    try {
      await _profileService.updateProfile(uid: uid, fullName: fullName, phone: phone);
      _fullName = fullName;
      _phone = phone;
      return true;
    } catch (_) {
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final email = _email;
    if (email == null) return false;
    _isChangingPassword = true;
    _passwordError = null;
    notifyListeners();
    try {
      await _profileService.changePassword(
        email: email,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (error) {
      _passwordError = _messageFor(error);
      return false;
    } finally {
      _isChangingPassword = false;
      notifyListeners();
    }
  }

  /// Deletes the account, returning whether it succeeded. On success, the
  /// underlying Firebase Auth user is gone, which fires `authStateChanges()`
  /// with `null` and flips `AuthGate` over to the sign-in screen — the same
  /// mechanism sign-out already relies on — so there's nothing further to
  /// navigate here.
  Future<bool> deleteAccount({required String currentPassword}) async {
    final email = _email;
    if (email == null) return false;
    _isDeleting = true;
    _deleteError = null;
    notifyListeners();
    try {
      await _profileService.deleteAccount(email: email, currentPassword: currentPassword);
      return true;
    } catch (error) {
      _deleteError = _messageFor(error);
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  String _messageFor(Object error) {
    if (error is ProfileException) return error.message;
    return 'Something went wrong. Please try again.';
  }
}
