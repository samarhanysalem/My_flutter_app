import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// A centered, error-colored line of text — a form/action failure message.
/// Shared by the auth forms and Profile's save/change-password/delete-account
/// error states.
class InlineErrorText extends StatelessWidget {
  const InlineErrorText({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: AppTheme.errorText.copyWith(color: AppTheme.error),
      textAlign: TextAlign.center,
    );
  }
}
