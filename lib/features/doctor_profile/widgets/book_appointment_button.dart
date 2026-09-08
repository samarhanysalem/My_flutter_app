import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../view/availability_provider.dart';

/// Fixed bottom CTA. Books whichever slot is currently selected in
/// AvailabilitySection — both read the same `AvailabilityProvider`,
/// provided by `DoctorProfileView` above them both. Disabled until a slot
/// is selected, and while a booking is in flight.
///
/// On success, pops this screen and hands the confirmation message back to
/// whoever pushed it (see `HomeView._openDoctorProfile`), which shows it —
/// the patient should land back on Home and see the new appointment there,
/// not stay on this screen. On failure, shows the error here instead and
/// stays, since the user still needs to pick another slot.
class BookAppointmentButton extends StatelessWidget {
  const BookAppointmentButton({super.key});

  Future<void> _book(
    BuildContext context,
    AvailabilityProvider provider,
    AppLocalizations loc,
    Locale locale,
  ) async {
    final date = provider.selectedDate;
    final slot = provider.selectedSlot!;
    final success = await provider.bookSelectedSlot();
    if (!context.mounted) return;
    if (success) {
      Navigator.of(context).pop(
        loc.appointmentBooked(
          DateFormat.MMMEd(locale.toLanguageTag()).format(date),
          slot,
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.bookingFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final provider = context.watch<AvailabilityProvider>();
    final canBook = !provider.isBooking && provider.selectedSlot != null;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: canBook ? () => _book(context, provider, loc, locale) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          disabledBackgroundColor: AppTheme.disabledFill,
          foregroundColor: AppTheme.onPrimary,
          disabledForegroundColor: AppTheme.textDisabled,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
        ),
        child: provider.isBooking
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.onPrimary,
                ),
              )
            : Text(loc.bookAppointment, style: AppTheme.buttonLabel),
      ),
    );
  }
}
