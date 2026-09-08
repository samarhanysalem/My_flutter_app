import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../common/models/appointment.dart';
import '../../../common/widgets/icon_text_row.dart';
import '../../../common/widgets/status_badge.dart';
import '../../../config/app_config.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';

/// My appointments — a placeholder for now. A full list of the patient's
/// appointments can come later; today this only receives navigation from
/// Home's "View details" (via `NavShellController.showAppointmentDetails`)
/// and shows that one appointment, or a generic message when reached
/// directly from the Appointments nav tab with nothing to show yet.
class MyAppointmentsView extends StatelessWidget {
  const MyAppointmentsView({super.key, this.appointment});

  final Appointment? appointment;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.screenGround,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.myAppointmentsTitle, style: AppTheme.screenTitle),
                  const SizedBox(height: AppTheme.spacing20),
                  if (appointment == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacing24,
                      ),
                      child: Center(
                        child: Text(
                          loc.noAppointmentDetails,
                          style: AppTheme.subtitle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    _AppointmentDetailsCard(appointment: appointment!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppointmentDetailsCard extends StatelessWidget {
  const _AppointmentDetailsCard({required this.appointment});

  final Appointment appointment;

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
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: StatusBadge(label: loc.appointmentStatusConfirmed),
          ),
          const SizedBox(height: AppTheme.spacing14),
          Row(
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
        ],
      ),
    );
  }
}
