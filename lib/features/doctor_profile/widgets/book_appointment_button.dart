import 'package:flutter/material.dart';

import '../../../common/utils/not_available_yet.dart';
import '../../../theme/app_theme.dart';

/// Fixed bottom CTA. The booking flow itself isn't built yet, so this is
/// the entry point stub — matches the "not available yet" pattern used
/// elsewhere in the app for unbuilt features.
class BookAppointmentButton extends StatelessWidget {
  const BookAppointmentButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => showNotAvailableYet(context, 'Booking'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
        ),
        child: Text('Book appointment', style: AppTheme.buttonLabel),
      ),
    );
  }
}
