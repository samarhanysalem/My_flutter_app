import '../../l10n/app_localizations.dart';

/// Shared field validators for the sign-in/sign-up forms and Profile's
/// editable fields.
class AuthValidators {
  const AuthValidators._();

  static final _emailPattern = RegExp(r'^[\w.+-]+@([\w-]+\.)+[A-Za-z]{2,}$');

  static String? email(String? value, AppLocalizations loc) {
    if (value == null || value.trim().isEmpty) {
      return loc.enterYourEmail;
    }
    if (!_emailPattern.hasMatch(value.trim())) {
      return loc.enterAValidEmail;
    }
    return null;
  }

  static String? fullName(String? value, AppLocalizations loc) {
    if (value == null || value.trim().isEmpty) {
      return loc.enterYourFullName;
    }
    return null;
  }

  static String? phone(String? value, AppLocalizations loc) {
    if (value == null || value.trim().isEmpty) {
      return loc.enterYourPhoneNumber;
    }
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 7) {
      return loc.enterAValidPhoneNumber;
    }
    return null;
  }

  static String? password(String? value, AppLocalizations loc) {
    if (value == null || value.length < 8) {
      return loc.passwordTooShort;
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value) ||
        !RegExp(r'[0-9]').hasMatch(value)) {
      return loc.passwordNeedsLetterAndNumber;
    }
    return null;
  }
}
