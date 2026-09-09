import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// A small pill-shaped status label (e.g. "Confirmed" on an appointment
/// card) — shared between Home's upcoming-appointment card and the My
/// appointments screen.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing8,
        vertical: AppTheme.spacing3,
      ),
      decoration: BoxDecoration(
        color: AppTheme.accentTint,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(
        label,
        style: AppTheme.captionSecondary.copyWith(color: AppTheme.primary),
      ),
    );
  }
}
