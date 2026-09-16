import 'package:flutter/material.dart';

import '../../../common/widgets/inline_error_text.dart';
import '../../../common/widgets/labeled_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../view/profile_provider.dart';

/// Shows the delete-account confirmation dialog — an irreversibility
/// warning plus a password field, since Firebase requires a recently issued
/// credential to delete an account (the same reauthentication
/// `ProfileService.deleteAccount` needs for a password change). On success,
/// deleting the Firebase Auth user fires `authStateChanges()` with `null`,
/// which flips `AuthGate` to the sign-in screen on its own — the same
/// mechanism sign-out relies on — so there's nothing further to do here.
/// [provider] is looked up by the caller for the same reason
/// `showChangePasswordDialog` is.
Future<void> showDeleteAccountDialog(
  BuildContext context,
  ProfileProvider provider,
) async {
  await showDialog<void>(
    context: context,
    builder: (_) => _DeleteAccountDialog(provider: provider),
  );
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.provider});

  final ProfileProvider provider;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = await widget.provider.deleteAccount(
      currentPassword: _passwordController.text,
    );
    // On success there's nothing to pop into — AuthGate has already swapped
    // this whole screen out for the sign-in screen underneath the dialog.
    if (success && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, _) {
        final isLoading = widget.provider.isDeleting;
        final error = widget.provider.deleteError;
        return AlertDialog(
          title: Text(loc.deleteAccountQuestion),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.deleteAccountWarning, style: AppTheme.body),
                const SizedBox(height: AppTheme.spacing14),
                Text(loc.deleteAccountPasswordPrompt, style: AppTheme.fieldLabel),
                const SizedBox(height: AppTheme.spacing6),
                LabeledTextField(
                  fieldKey: 'deleteAccountPassword',
                  label: loc.currentPasswordLabel,
                  controller: _passwordController,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return loc.enterYourPassword;
                    }
                    return null;
                  },
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
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: Text(loc.cancel),
            ),
            TextButton(
              onPressed: isLoading ? null : _submit,
              style: TextButton.styleFrom(foregroundColor: AppTheme.error),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.error,
                      ),
                    )
                  : Text(loc.deleteAccount),
            ),
          ],
        );
      },
    );
  }
}
