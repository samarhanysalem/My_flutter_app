import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
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

  String _greeting(AppLocalizations loc) {
    final hour = DateTime.now().hour;
    final name = _firstName;
    if (hour < 12) {
      return name == null
          ? loc.greetingMorningNoName
          : loc.greetingMorningWithName(name);
    }
    if (hour < 17) {
      return name == null
          ? loc.greetingAfternoonNoName
          : loc.greetingAfternoonWithName(name);
    }
    return name == null
        ? loc.greetingEveningNoName
        : loc.greetingEveningWithName(name);
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
    final loc = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            _greeting(loc),
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
