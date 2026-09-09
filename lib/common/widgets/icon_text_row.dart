import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// A leading icon + a line of text (e.g. a calendar icon next to a date) —
/// shared between Home's upcoming-appointment card and the My appointments
/// screen.
class IconTextRow extends StatelessWidget {
  const IconTextRow({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: AppTheme.spacing8),
        Expanded(
          child: Text(
            text,
            style: AppTheme.subtitle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
