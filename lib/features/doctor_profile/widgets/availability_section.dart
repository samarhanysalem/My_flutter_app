import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';

/// Mock time slots per weekday — there's no booking backend yet, so this
/// stands in for "what's actually free that day". Deliberately fixed rather
/// than randomized so the same day always shows the same slots.
const Map<int, List<String>> _slotsByWeekday = {
  DateTime.monday: ['9:00 AM', '11:15 AM', '2:30 PM'],
  DateTime.tuesday: ['10:30 AM', '1:00 PM', '4:15 PM'],
  DateTime.wednesday: ['9:00 AM', '1:00 PM', '5:30 PM'],
  DateTime.thursday: ['11:15 AM', '2:30 PM', '4:15 PM'],
  DateTime.friday: ['9:00 AM', '10:30 AM', '5:30 PM'],
  DateTime.saturday: ['10:30 AM', '2:30 PM'],
  DateTime.sunday: [],
};

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// "Available today" time-slot chips, with a calendar button to check a
/// different day. Selecting a day/slot is local, ephemeral UI state (no
/// booking backend exists yet), so this owns it directly rather than
/// lifting it into a ChangeNotifier, per CLAUDE.md's widget rules.
class AvailabilitySection extends StatefulWidget {
  AvailabilitySection({super.key, DateTime? today})
    : today = today ?? DateTime.now();

  /// Overridable so tests get deterministic "today" instead of depending on
  /// the real wall-clock date (which would make the mock slots below flaky).
  final DateTime today;

  @override
  State<AvailabilitySection> createState() => _AvailabilitySectionState();
}

class _AvailabilitySectionState extends State<AvailabilitySection> {
  late final DateTime _today = _dateOnly(widget.today);
  late DateTime _selectedDate = _today;
  int? _selectedSlotIndex = 0;

  List<String> get _slots =>
      _slotsByWeekday[_selectedDate.weekday] ?? const [];

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: _today,
      lastDate: _today.add(const Duration(days: 60)),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = _dateOnly(picked);
      _selectedSlotIndex = _slots.isEmpty ? null : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final title = _selectedDate == _today
        ? loc.availableToday
        : loc.availableOn(DateFormat.MMMEd(locale.toLanguageTag()).format(_selectedDate));
    final slots = _slots;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTheme.sectionTitle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: () => _pickDate(context),
              tooltip: loc.selectDate,
              icon: const Icon(
                Icons.calendar_month_outlined,
                size: 20,
                color: AppTheme.primary,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing10),
        if (slots.isEmpty)
          Text(loc.noSlotsAvailable, style: AppTheme.subtitle)
        else
          Row(
            children: [
              for (var i = 0; i < slots.length; i++) ...[
                Expanded(
                  child: _SlotChip(
                    label: slots[i],
                    selected: i == _selectedSlotIndex,
                    onTap: () => setState(() => _selectedSlotIndex = i),
                  ),
                ),
                if (i != slots.length - 1)
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
