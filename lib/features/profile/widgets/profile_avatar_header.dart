import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// The circular initial avatar plus display name/email shown at the top of
/// Profile — unchanged from the previous placeholder's identity block.
class ProfileAvatarHeader extends StatelessWidget {
  const ProfileAvatarHeader({super.key, this.displayName, this.email});

  final String? displayName;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final initialSource = (displayName != null && displayName!.isNotEmpty)
        ? displayName
        : email;
    final initial = (initialSource == null || initialSource.isEmpty)
        ? '?'
        : initialSource[0].toUpperCase();

    return Center(
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppTheme.accentTint,
              shape: BoxShape.circle,
            ),
            child: Text(
              initial,
              style: AppTheme.heading.copyWith(color: AppTheme.primary),
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          if (displayName != null && displayName!.isNotEmpty)
            Text(displayName!, style: AppTheme.cardTitle),
          if (email != null) ...[
            const SizedBox(height: AppTheme.spacing2),
            Text(email!, style: AppTheme.subtitle),
          ],
        ],
      ),
    );
  }
}
