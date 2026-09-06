import 'package:flutter/material.dart';

/// Shows the standard "isn't available yet" notice used across the app for
/// features that don't have a real implementation yet (e.g. quick actions,
/// booking, forgot password).
void showNotAvailableYet(BuildContext context, String feature) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('$feature isn\'t available yet.')));
}
