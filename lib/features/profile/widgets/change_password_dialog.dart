import 'package:flutter/material.dart';

import '../../../common/widgets/inline_error_text.dart';
import '../../../common/widgets/labeled_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../auth/auth_validators.dart';
import '../view/profile_provider.dart';

/// Shows the change-password dialog (current password + new password) and,
/// on success, a confirmation snackbar. [provider] is looked up by the
/// caller rather than inside the dialog's own `builder` — a dialog's
/// `builder` context isn't a descendant of the screen that opened it, the
/// same reasoning `confirmSignOut`/`_confirmAndCancel` already follow.
Future<void> showChangePasswordDialog(
  BuildContext context,
  ProfileProvider provider,
) async {
  final loc = AppLocalizations.of(context)!;
  final changed = await showDialog<bool>(
    context: context,
    builder: (_) => _ChangePasswordDialog(provider: provider),
  );
  if ((changed ?? false) && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(loc.passwordChanged)));
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog({required this.provider});

  final ProfileProvider provider;

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = await widget.provider.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );
    if (success && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, _) {
        final isLoading = widget.provider.isChangingPassword;
        final error = widget.provider.passwordError;
        return AlertDialog(
          title: Text(loc.changePassword),
          // Without this, the content doesn't scroll, so on a phone with
          // the keyboard open there isn't room for both fields plus the
          // actions row below them — they render on top of each other
          // instead of one being pushed off-screen and scrollable to.
          scrollable: true,
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LabeledTextField(
                  fieldKey: 'currentPassword',
                  label: loc.currentPasswordLabel,
                  controller: _currentPasswordController,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return loc.enterYourPassword;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacing14),
                LabeledTextField(
                  fieldKey: 'newPassword',
                  label: loc.newPasswordLabel,
                  controller: _newPasswordController,
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (value) => AuthValidators.password(value, loc),
                ),
                if (error != null) ...[
                  const SizedBox(height: AppTheme.spacing12),
                  InlineErrorText(message: error),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(false),
              child: Text(loc.cancel),
            ),
            TextButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(loc.changePassword),
            ),
          ],
        );
      },
    );
  }
}
