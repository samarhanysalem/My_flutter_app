/// Shared field validators for the sign-in/sign-up forms.
class AuthValidators {
  const AuthValidators._();

  static final _emailPattern = RegExp(r'^[\w.-]+@([\w-]+\.)+[A-Za-z]{2,}$');

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your email';
    }
    if (!_emailPattern.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }
}
