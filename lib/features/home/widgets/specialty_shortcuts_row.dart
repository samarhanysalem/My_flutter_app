import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';

class _Specialty {
  const _Specialty(this.id, this.icon, this.filterValue);

  /// Stable identifier used to look up the localized [label] — see
  /// [_labelFor]. Not shown to the user.
  final String id;
  final IconData icon;

  /// The substring matched against `Doctor.specialty` — see
  /// `HomeProvider.doctors`. Always English, regardless of the app's
  /// language, since it's matched against the English specialty names
  /// stored in Firestore. A short label that isn't itself a substring of
  /// the real specialty name (e.g. "Endocrine" vs. "Endocrinologist", "Eye"
  /// vs. "Ophthalmologist") must use one that actually is.
  final String filterValue;
}

const _specialties = [
  _Specialty('cardio', Icons.favorite_border, 'Cardio'),
  _Specialty('ortho', Icons.accessibility_new, 'Ortho'),
  _Specialty('neuro', Icons.psychology_outlined, 'Neuro'),
  _Specialty('derma', Icons.face_retouching_natural, 'Derma'),
  _Specialty('pediatric', Icons.child_care, 'Pediatric'),
  _Specialty('endocrine', Icons.biotech_outlined, 'Endocrin'),
  _Specialty('psych', Icons.self_improvement, 'Psych'),
  _Specialty('gastro', Icons.local_dining, 'Gastro'),
  _Specialty('eye', Icons.visibility_outlined, 'Ophthalmolog'),
  _Specialty('family', Icons.family_restroom, 'Family'),
];

String _labelFor(AppLocalizations loc, String id) {
  switch (id) {
    case 'cardio':
      return loc.specialtyCardio;
    case 'ortho':
      return loc.specialtyOrtho;
    case 'neuro':
      return loc.specialtyNeuro;
    case 'derma':
      return loc.specialtyDerma;
    case 'pediatric':
      return loc.specialtyPediatric;
    case 'endocrine':
      return loc.specialtyEndocrine;
    case 'psych':
      return loc.specialtyPsych;
    case 'gastro':
      return loc.specialtyGastro;
    case 'eye':
      return loc.specialtyEye;
    case 'family':
      return loc.specialtyFamily;
  }
  throw ArgumentError('Unknown specialty id: $id');
}

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
    final loc = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _SpecialtyTile(
            label: loc.specialtyAll,
            icon: Icons.apps,
            selected: selectedSpecialty == null,
            onTap: () => onSelect(null),
          ),
          const SizedBox(width: AppTheme.spacing14),
          for (final specialty in _specialties) ...[
            _SpecialtyTile(
              label: _labelFor(loc, specialty.id),
              icon: specialty.icon,
              selected: selectedSpecialty == specialty.filterValue,
              onTap: () => onSelect(specialty.filterValue),
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
