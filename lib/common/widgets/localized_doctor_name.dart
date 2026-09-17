import 'package:flutter/material.dart';

import '../models/appointment.dart';
import '../models/doctor.dart';

/// An appointment's doctor name, localized — shared between Home's
/// upcoming-appointment card and My appointments' cards.
///
/// The appointment's own denormalized `doctorNameAr` (captured at booking
/// time) is used when present. If it's missing and the current locale is
/// Arabic, this falls back to a live lookup via [lookupDoctor] — most
/// likely because the doctor's Arabic name was added to their record only
/// *after* this appointment was booked, so without this fallback the
/// appointment would show English forever even after the doctor's own
/// record catches up. See `Appointment.doctorNameAr`'s doc comment.
class LocalizedDoctorName extends StatefulWidget {
  const LocalizedDoctorName({
    super.key,
    required this.appointment,
    required this.lookupDoctor,
    this.style,
    this.overflow,
  });

  final Appointment appointment;
  final Future<Doctor?> Function(String doctorId) lookupDoctor;
  final TextStyle? style;
  final TextOverflow? overflow;

  @override
  State<LocalizedDoctorName> createState() => _LocalizedDoctorNameState();
}

class _LocalizedDoctorNameState extends State<LocalizedDoctorName> {
  String? _liveArabicName;
  bool _hasFetchedForCurrentAppointment = false;

  @override
  void didUpdateWidget(covariant LocalizedDoctorName oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appointment.doctorId != widget.appointment.doctorId ||
        oldWidget.appointment.doctorNameAr != widget.appointment.doctorNameAr) {
      _liveArabicName = null;
      _hasFetchedForCurrentAppointment = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeFetchLiveArabicName();
  }

  void _maybeFetchLiveArabicName() {
    if (_hasFetchedForCurrentAppointment) return;
    final arabic = widget.appointment.doctorNameAr?.trim();
    if (arabic != null && arabic.isNotEmpty) return;
    if (Localizations.localeOf(context).languageCode != 'ar') return;

    _hasFetchedForCurrentAppointment = true;
    widget.lookupDoctor(widget.appointment.doctorId).then((doctor) {
      if (!mounted) return;
      final liveArabic = doctor?.nameAr?.trim();
      if (liveArabic != null && liveArabic.isNotEmpty) {
        setState(() => _liveArabicName = liveArabic);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final liveArabicName = _liveArabicName;
    final name = locale.languageCode == 'ar' && liveArabicName != null
        ? liveArabicName
        : widget.appointment.localizedDoctorName(locale);
    return Text(name, style: widget.style, overflow: widget.overflow);
  }
}
