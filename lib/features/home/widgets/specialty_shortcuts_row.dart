import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class _Specialty {
  const _Specialty(this.label, this.icon);

  final String label;
  final IconData icon;
}

const _specialties = [
  _Specialty('Cardio', Icons.favorite_border),
  _Specialty('Ortho', Icons.accessibility_new),
  _Specialty('Neuro', Icons.psychology_outlined),
];

/// Horizontally scrollable specialty shortcuts (so a narrow phone doesn't
/// force these to shrink or wrap). Tapping one toggles a client-side
/// specialty filter on the doctor list; tapping "More" isn't wired to
/// anything yet.
class SpecialtyShortcutsRow extends StatelessWidget {
  const SpecialtyShortcutsRow({
    super.key,
    required this.selectedSpecialty,
    required this.onSelect,
  });

  final String? selectedSpecialty;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final specialty in _specialties) ...[
            _SpecialtyTile(
              label: specialty.label,
              icon: specialty.icon,
              selected: selectedSpecialty == specialty.label,
              onTap: () => onSelect(specialty.label),
            ),
            const SizedBox(width: AppTheme.spacing14),
          ],
          _SpecialtyTile(
            label: 'More',
            icon: Icons.more_horiz,
            selected: false,
            neutral: true,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('More specialties isn\'t available yet.'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SpecialtyTile extends StatelessWidget {
  const _SpecialtyTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.neutral = false,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool neutral;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color iconColor;
    if (selected) {
      background = AppTheme.primary;
      iconColor = AppTheme.onPrimary;
    } else if (neutral) {
      background = AppTheme.screenGround;
      iconColor = AppTheme.textSecondary;
    } else {
      background = AppTheme.accentTint;
      iconColor = AppTheme.primary;
    }
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(AppTheme.radiusTile),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(height: AppTheme.spacing6),
          Text(label, style: AppTheme.captionSecondary),
        ],
      ),
    );
  }
}
