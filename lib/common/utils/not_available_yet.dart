import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Shows the standard "isn't available yet" notice used across the app for
/// features that don't have a real implementation yet (e.g. quick actions,
/// booking, forgot password). [feature] should already be a localized name.
void showNotAvailableYet(BuildContext context, String feature) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(AppLocalizations.of(context)!.notAvailableYet(feature))),
  );
}
