import '../../l10n/app_localizations.dart';

/// Shared field validators for the sign-in/sign-up forms.
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
}
