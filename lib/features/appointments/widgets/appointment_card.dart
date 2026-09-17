import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../common/models/appointment.dart';
import '../../../common/models/doctor.dart';
import '../../../common/widgets/icon_text_row.dart';
import '../../../common/widgets/localized_doctor_name.dart';
import '../../../common/widgets/status_badge.dart';
import '../../../config/app_config.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';

/// One appointment row on My appointments — an upcoming appointment (full
/// detail, address, and actions) or a past one (dimmed, no address or
/// actions), per [isPast].
class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.isPast,
    required this.lookupDoctor,
    this.onCancel,
    this.onReschedule,
  });

  final Appointment appointment;
  final bool isPast;

  /// See `LocalizedDoctorName`.
  final Future<Doctor?> Function(String doctorId) lookupDoctor;

  /// Only rendered (and required) for an upcoming appointment — see
  /// [isPast].
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final avatarColor = AppTheme
        .avatarPalette[appointment.doctorId.hashCode.abs() % AppTheme.avatarPalette.length];
    final date = DateTime.tryParse(appointment.date);
    final dateTimeLabel = date == null
        ? appointment.slot
        : '${DateFormat.MMMEd(locale.toLanguageTag()).format(date)} · ${appointment.slot}';

    final String statusLabel;
    final Color? statusBackground;
    final Color? statusTextColor;
    if (appointment.status == 'cancelled') {
      statusLabel = loc.appointmentStatusCancelled;
      statusBackground = AppTheme.errorTint;
      statusTextColor = AppTheme.error;
    } else if (isPast) {
      statusLabel = loc.appointmentStatusCompleted;
      statusBackground = null;
      statusTextColor = null;
    } else {
      statusLabel = loc.appointmentStatusConfirmed;
      statusBackground = null;
      statusTextColor = null;
    }

    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // Top-aligned so the badge sits at the card's top-right corner
            // even when the doctor name/specialty wrap to two lines,
            // rather than centering against the taller text block.
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: avatarColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LocalizedDoctorName(
                      appointment: appointment,
                      lookupDoctor: lookupDoctor,
                      style: AppTheme.cardTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    Text(
                      appointment.localizedDoctorSpecialty(loc),
                      style: AppTheme.fieldLabel,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacing8),
              StatusBadge(
                label: statusLabel,
                backgroundColor: statusBackground,
                textColor: statusTextColor,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing14),
          IconTextRow(icon: Icons.calendar_month_outlined, text: dateTimeLabel),
          if (!isPast) ...[
            const SizedBox(height: AppTheme.spacing8),
            IconTextRow(
              icon: Icons.location_on_outlined,
              text: AppConfig.clinicAddressFor(locale),
            ),
            const SizedBox(height: AppTheme.spacing14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                    ),
                    child: Text(
                      loc.cancel,
                      style: AppTheme.buttonLabel.copyWith(color: AppTheme.error),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReschedule,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                    ),
                    child: Text(
                      loc.reschedule,
                      style: AppTheme.buttonLabel.copyWith(color: AppTheme.primary),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );

    // A plain Opacity rather than per-token dimmed colors, since this is
    // the only place a "completed" appearance is needed — not a reusable
    // design-system state.
    return isPast ? Opacity(opacity: 0.6, child: card) : card;
  }
}
