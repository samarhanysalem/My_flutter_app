import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';

const _slots = ['10:30 AM', '1:00 PM', '4:15 PM'];

/// "Available today" time-slot chips. Selecting one is local, ephemeral UI
/// state (no booking backend exists yet), so this owns it directly rather
/// than lifting it into a ChangeNotifier, per CLAUDE.md's widget rules.
class AvailabilitySection extends StatefulWidget {
  const AvailabilitySection({super.key});

  @override
  State<AvailabilitySection> createState() => _AvailabilitySectionState();
}

class _AvailabilitySectionState extends State<AvailabilitySection> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.availableToday,
          style: AppTheme.sectionTitle,
        ),
        const SizedBox(height: AppTheme.spacing10),
        Row(
          children: [
            for (var i = 0; i < _slots.length; i++) ...[
              Expanded(
                child: _SlotChip(
                  label: _slots[i],
                  selected: i == _selected,
                  onTap: () => setState(() => _selected = i),
                ),
              ),
              if (i != _slots.length - 1)
                const SizedBox(width: AppTheme.spacing8),
            ],
          ],
        ),
      ],
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.surface,
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Text(
          label,
          style: AppTheme.subtitle.copyWith(
            color: selected ? AppTheme.onPrimary : AppTheme.ink,
          ),
        ),
      ),
    );
  }
}
