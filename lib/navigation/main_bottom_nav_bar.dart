import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'nav_shell_controller.dart';

/// The app's persistent bottom navigation — a fully custom bar (rather than
/// a stock BottomNavigationBar/NavigationBar) so every color/spacing here
/// traces to AppTheme explicitly, matching the rest of the app's visual
/// style instead of Material's default nav-bar theming.
class MainBottomNavBar extends StatelessWidget {
  const MainBottomNavBar({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final MainTab selected;
  final ValueChanged<MainTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final items = <(MainTab tab, IconData icon, IconData selectedIcon, String label)>[
      (MainTab.home, Icons.home_outlined, Icons.home, loc.navHome),
      (
        MainTab.appointments,
        Icons.calendar_month_outlined,
        Icons.calendar_month,
        loc.navAppointments,
      ),
      (MainTab.profile, Icons.person_outline, Icons.person, loc.navProfile),
    ];

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        top: false,
        // `heightFactor: 1` makes this Center shrink-wrap to the Row's
        // natural height instead of expanding to fill the large, loose
        // height Scaffold gives its `bottomNavigationBar` slot — the
        // default Center/Align behavior of filling all available space
        // on a bounded axis, which is correct for body content but would
        // otherwise let this bar swallow the whole screen and starve the
        // body area (an IndexedStack) down to zero height.
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppTheme.spacing8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final item in items)
                    _NavBarItem(
                      icon: item.$1 == selected ? item.$3 : item.$2,
                      label: item.$4,
                      selected: item.$1 == selected,
                      onTap: () => onSelect(item.$1),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.primary : AppTheme.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: AppTheme.spacing4),
              Text(
                label,
                style: AppTheme.captionSecondary.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
