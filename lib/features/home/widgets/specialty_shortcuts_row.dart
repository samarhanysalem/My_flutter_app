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
  _Specialty('Derma', Icons.face_retouching_natural),
  _Specialty('Pediatric', Icons.child_care),
  _Specialty('Endocrine', Icons.biotech_outlined),
  _Specialty('Psych', Icons.self_improvement),
  _Specialty('Gastro', Icons.local_dining),
  _Specialty('Eye', Icons.visibility_outlined),
  _Specialty('Family', Icons.family_restroom),
];

/// Horizontally scrollable specialty shortcuts (so a narrow phone doesn't
/// force these to shrink or wrap — there are enough specialties now that
/// this row always overflows and scrolls). "All" clears the filter and is
/// highlighted whenever none is selected; tapping a specialty applies a
/// client-side substring filter on the doctor list (see
/// `HomeProvider.doctors`), so a short label like "Derma" still matches the
/// full "Dermatologist" specialty stored in Firestore.
class SpecialtyShortcutsRow extends StatelessWidget {
  const SpecialtyShortcutsRow({
    super.key,
    required this.selectedSpecialty,
    required this.onSelect,
  });

  final String? selectedSpecialty;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _SpecialtyTile(
            label: 'All',
            icon: Icons.apps,
            selected: selectedSpecialty == null,
            onTap: () => onSelect(null),
          ),
          const SizedBox(width: AppTheme.spacing14),
          for (final specialty in _specialties) ...[
            _SpecialtyTile(
              label: specialty.label,
              icon: specialty.icon,
              selected: selectedSpecialty == specialty.label,
              onTap: () => onSelect(specialty.label),
            ),
            const SizedBox(width: AppTheme.spacing14),
          ],
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
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color iconColor;
    if (selected) {
      background = AppTheme.primary;
      iconColor = AppTheme.onPrimary;
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
