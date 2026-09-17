import 'package:doctor_appointment_app/features/profile/models/user_profile.dart';
import 'package:doctor_appointment_app/features/profile/services/profile_service.dart';

/// Hand-written test double so Profile tests never touch real Firebase.
class FakeProfileService implements ProfileService {
  /// Canned result for [getProfile] — set by a test before pumping.
  UserProfile? profileToReturn;

  /// Set to make the next [getProfile] call fail.
  Object? getProfileErrorToThrow;

  /// Set to make the next [updateProfile]/[changePassword]/[deleteAccount]
  /// call fail with this error.
  Object? errorToThrow;

  bool updateProfileCalled = false;
  String? lastFullName;
  String? lastPhone;

  bool changePasswordCalled = false;
  String? lastCurrentPassword;
  String? lastNewPassword;

  bool deleteAccountCalled = false;

  @override
  Future<UserProfile?> getProfile(String uid) async {
    if (getProfileErrorToThrow != null) throw getProfileErrorToThrow!;
    return profileToReturn;
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required String fullName,
    required String phone,
  }) async {
    updateProfileCalled = true;
    lastFullName = fullName;
    lastPhone = phone;
    if (errorToThrow != null) throw errorToThrow!;
  }

  @override
  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    changePasswordCalled = true;
    lastCurrentPassword = currentPassword;
    lastNewPassword = newPassword;
    if (errorToThrow != null) throw errorToThrow!;
  }

  @override
  Future<void> deleteAccount({
    required String email,
    required String currentPassword,
  }) async {
    deleteAccountCalled = true;
    if (errorToThrow != null) throw errorToThrow!;
  }
}
