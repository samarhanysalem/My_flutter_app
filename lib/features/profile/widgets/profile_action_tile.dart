import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// One row of Profile's action list (Change password, Delete account, Log
/// out): a leading icon, a label, and a trailing chevron. [color] tints the
/// icon and label for a destructive action (Delete account); defaults to
/// the neutral ink color otherwise.
class ProfileActionTile extends StatelessWidget {
  const ProfileActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppTheme.ink,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(child: Text(label, style: AppTheme.body.copyWith(color: color))),
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left
                  : Icons.chevron_right,
              size: 20,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
