import 'package:flutter/widgets.dart';

import '../utils/specialty_localizations.dart';
import '../../l10n/app_localizations.dart';

/// A booked appointment, sourced from Firestore's `appointments` collection.
/// Shared across the `home` and `appointments` features.
class Appointment {
  const Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.date,
    required this.slot,
    required this.status,
    this.doctorNameAr,
  });

  final String id;
  final String patientId;
  final String doctorId;

  /// Denormalized from the doctor record at booking time (same reasoning
  /// as `Doctor`'s own fields) so appointment screens don't need a second
  /// read per doctor.
  final String doctorName;
  final String doctorSpecialty;

  /// Arabic form of [doctorName] — a transliteration, not a translation, as
  /// with `Doctor.nameAr`. Null if the doctor didn't have one at booking
  /// time.
  final String? doctorNameAr;

  /// Calendar date the appointment is booked for, as `yyyy-MM-dd` — see
  /// `common/utils/date_id.dart`.
  final String date;

  /// Time-of-day label, e.g. "10:30 AM" — matches an `AvailabilityService`
  /// slot string.
  final String slot;

  /// Currently always `'confirmed'` — there's no cancellation flow yet.
  final String status;

  factory Appointment.fromFirestore(String id, Map<String, dynamic> data) {
    return Appointment(
      id: id,
      patientId: data['patientId'] as String? ?? '',
      doctorId: data['doctorId'] as String? ?? '',
      doctorName: data['doctorName'] as String? ?? '',
      doctorSpecialty: data['doctorSpecialty'] as String? ?? '',
      doctorNameAr: data['doctorNameAr'] as String?,
      date: data['date'] as String? ?? '',
      slot: data['slot'] as String? ?? '',
      status: data['status'] as String? ?? '',
    );
  }

  /// [doctorName], localized: [doctorNameAr] when [locale] is Arabic and
  /// one exists, otherwise the stored [doctorName].
  String localizedDoctorName(Locale locale) {
    final arabic = doctorNameAr?.trim();
    if (locale.languageCode == 'ar' && arabic != null && arabic.isNotEmpty) {
      return arabic;
    }
    return doctorName;
  }

  /// [doctorSpecialty], localized against the known specialty set — see
  /// `localizeSpecialty`.
  String localizedDoctorSpecialty(AppLocalizations loc) =>
      localizeSpecialty(loc, doctorSpecialty);
}
