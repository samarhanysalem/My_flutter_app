import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../auth/models/app_user.dart';

/// Top-of-screen greeting ("Good morning, Alex") with a tappable initial
/// avatar for account actions (sign out, later a profile screen).
class HomeGreetingHeader extends StatelessWidget {
  const HomeGreetingHeader({
    super.key,
    required this.user,
    required this.onAvatarTap,
  });

  final AppUser? user;
  final VoidCallback onAvatarTap;

  String get _greeting {
    final hour = DateTime.now().hour;
    final timeOfDay = hour < 12
        ? 'morning'
        : hour < 17
        ? 'afternoon'
        : 'evening';
    final name = _firstName;
    return name == null ? 'Good $timeOfDay' : 'Good $timeOfDay, $name';
  }

  String? get _firstName {
    final displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName.split(' ').first;
    }
    final email = user?.email;
    if (email != null && email.contains('@')) {
      return email.substring(0, email.indexOf('@'));
    }
    return null;
  }

  String get _initial {
    final source = _firstName ?? user?.email;
    if (source == null || source.isEmpty) return '?';
    return source[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            _greeting,
            style: AppTheme.greeting,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppTheme.spacing12),
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppTheme.accentTint,
              shape: BoxShape.circle,
            ),
            child: Text(
              _initial,
              style: AppTheme.cardTitle.copyWith(color: AppTheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}
