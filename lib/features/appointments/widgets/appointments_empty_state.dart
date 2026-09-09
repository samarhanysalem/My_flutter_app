import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Empty-state message for a My appointments tab, with an optional action
/// button (e.g. Upcoming's "Book now" — Past has none).
class AppointmentsEmptyState extends StatelessWidget {
  const AppointmentsEmptyState({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final actionLabel = this.actionLabel;
    final onAction = this.onAction;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: AppTheme.subtitle, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppTheme.spacing16),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                  ),
                  child: Text(actionLabel, style: AppTheme.buttonLabel),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
