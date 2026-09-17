import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../view/my_appointments_provider.dart';

/// The Upcoming/Past segmented toggle at the top of My appointments. The
/// selected segment gets an accent (filled) background; the unselected one
/// stays unfilled with a plain border, per the design spec.
class AppointmentsTabToggle extends StatelessWidget {
  const AppointmentsTabToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final AppointmentsTab selected;
  final ValueChanged<AppointmentsTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _TabSegment(
            label: loc.upcomingTabLabel,
            selected: selected == AppointmentsTab.upcoming,
            onTap: () => onChanged(AppointmentsTab.upcoming),
          ),
        ),
        const SizedBox(width: AppTheme.spacing10),
        Expanded(
          child: _TabSegment(
            label: loc.pastTabLabel,
            selected: selected == AppointmentsTab.past,
            onTap: () => onChanged(AppointmentsTab.past),
          ),
        ),
      ],
    );
  }
}

class _TabSegment extends StatelessWidget {
  const _TabSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: selected ? null : Border.all(color: AppTheme.border),
        ),
        child: Text(
          label,
          style: AppTheme.buttonLabel.copyWith(
            color: selected ? AppTheme.onPrimary : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
