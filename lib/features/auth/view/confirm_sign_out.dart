import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import 'auth_provider.dart';

/// Shows the "Sign out?" confirmation dialog and signs out if confirmed,
/// surfacing a failure snackbar if it throws. Shared by Home (avatar tap)
/// and Profile (sign-out button).
Future<void> confirmSignOut(BuildContext context) async {
  final authProvider = context.read<AuthProvider>();
  final loc = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(loc.signOutQuestion),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(loc.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(loc.signOut),
        ),
      ],
    ),
  );
  if (confirmed ?? false) {
    try {
      await authProvider.signOut();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.signOutFailed)));
    }
  }
}
