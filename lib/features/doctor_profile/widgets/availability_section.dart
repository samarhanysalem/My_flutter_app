import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../view/availability_provider.dart';

/// "Available today" time-slot chips, backed by real availability data from
/// Firestore (`doctors/{doctorId}/availability/{yyyy-MM-dd}` — see
/// `AvailabilityService`), with a calendar button to check a different day.
/// Reads the `AvailabilityProvider` that `DoctorProfileView` provides above
/// both this and `BookAppointmentButton`, so selecting a slot here is what
/// that button books.
class AvailabilitySection extends StatelessWidget {
  const AvailabilitySection({super.key, required this.today});

  /// Today's date (date-only), used to caption the title and bound the
  /// calendar — passed down from `DoctorProfileView` so it matches the
  /// `AvailabilityProvider`'s own notion of "today".
  final DateTime today;

  Future<void> _pickDate(BuildContext context, AvailabilityProvider provider) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 60)),
    );
    if (picked == null) return;
    await provider.selectDate(DateTime(picked.year, picked.month, picked.day));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AvailabilityProvider>();
    final loc = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final title = provider.selectedDate == today
        ? loc.availableToday
        : loc.availableOn(
            DateFormat.MMMEd(locale.toLanguageTag()).format(provider.selectedDate),
          );

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
              onPressed: () => _pickDate(context, provider),
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
        if (provider.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppTheme.spacing10),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (provider.hasError)
          Text(loc.loadAvailabilityError, style: AppTheme.subtitle)
        else if (provider.slots.isEmpty)
          Text(loc.noSlotsAvailable, style: AppTheme.subtitle)
        else
          Row(
            children: [
              for (var i = 0; i < provider.slots.length; i++) ...[
                Expanded(
                  child: _SlotChip(
                    label: provider.slots[i],
                    selected: i == provider.selectedSlotIndex,
                    onTap: () => provider.selectSlot(i),
                  ),
                ),
                if (i != provider.slots.length - 1)
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
