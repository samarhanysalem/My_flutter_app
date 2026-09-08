import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../common/models/appointment.dart';
import '../../../common/widgets/icon_text_row.dart';
import '../../../common/widgets/status_badge.dart';
import '../../../config/app_config.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';

/// Home's "upcoming appointment" card — only rendered by the caller when
/// there actually is one (see `HomeProvider.upcomingAppointment`). Shows
/// enough to recognize the appointment at a glance; "View details" hands
/// off to My appointments.
class UpcomingAppointmentCard extends StatelessWidget {
  const UpcomingAppointmentCard({
    super.key,
    required this.appointment,
    required this.onViewDetails,
  });

  final Appointment appointment;
  final VoidCallback onViewDetails;

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

    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  loc.upcomingAppointmentLabel.toUpperCase(),
                  style: AppTheme.captionSecondary,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusBadge(label: loc.appointmentStatusConfirmed),
            ],
          ),
          const SizedBox(height: AppTheme.spacing14),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
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
                    Text(
                      appointment.localizedDoctorName(locale),
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
            ],
          ),
          const SizedBox(height: AppTheme.spacing14),
          IconTextRow(icon: Icons.calendar_month_outlined, text: dateTimeLabel),
          const SizedBox(height: AppTheme.spacing8),
          IconTextRow(
            icon: Icons.location_on_outlined,
            text: AppConfig.clinicAddressFor(locale),
          ),
          const SizedBox(height: AppTheme.spacing14),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton(
              onPressed: onViewDetails,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
              ),
              child: Text(
                loc.viewDetails,
                style: AppTheme.buttonLabel.copyWith(color: AppTheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
