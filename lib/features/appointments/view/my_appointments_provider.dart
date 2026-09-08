import 'package:flutter/foundation.dart';

import '../../../common/models/appointment.dart';
import '../../../common/models/doctor.dart';
import '../../home/services/appointment_service.dart';

enum AppointmentsTab { upcoming, past }

/// Owns the Upcoming/Past tab selection and both tabs' fetched appointment
/// lists. Both lists are one-time fetches (not streams) issued once, up
/// front, in the constructor — matching `getUpcomingAppointments`/
/// `getPastAppointments`'s "get" naming and CLAUDE.md's async/await
/// guidance, rather than staying subscribed like Home's upcoming-card does.
class MyAppointmentsProvider extends ChangeNotifier {
  MyAppointmentsProvider({
    required AppointmentService appointmentService,
    required String? patientId,
  }) : _appointmentService = appointmentService {
    // Null when nobody is signed in, which shouldn't happen on this
    // (already-authenticated) screen — just show both tabs empty rather
    // than assuming a user.
    if (patientId == null) {
      _isLoadingUpcoming = false;
      _isLoadingPast = false;
    } else {
      _loadUpcoming(patientId);
      _loadPast(patientId);
    }
  }

  final AppointmentService _appointmentService;

  AppointmentsTab _selectedTab = AppointmentsTab.upcoming;
  AppointmentsTab get selectedTab => _selectedTab;

  void selectTab(AppointmentsTab tab) {
    if (tab == _selectedTab) return;
    _selectedTab = tab;
    notifyListeners();
  }

  List<Appointment> _upcoming = const [];
  List<Appointment> get upcoming => _upcoming;
  bool _isLoadingUpcoming = true;
  bool get isLoadingUpcoming => _isLoadingUpcoming;
  bool _hasUpcomingError = false;
  bool get hasUpcomingError => _hasUpcomingError;

  List<Appointment> _past = const [];
  List<Appointment> get past => _past;
  bool _isLoadingPast = true;
  bool get isLoadingPast => _isLoadingPast;
  bool _hasPastError = false;
  bool get hasPastError => _hasPastError;

  Future<void> _loadUpcoming(String patientId) async {
    try {
      _upcoming = await _appointmentService.getUpcomingAppointments(patientId);
      _hasUpcomingError = false;
    } catch (_) {
      _hasUpcomingError = true;
    } finally {
      _isLoadingUpcoming = false;
      notifyListeners();
    }
  }

  Future<void> _loadPast(String patientId) async {
    try {
      _past = await _appointmentService.getPastAppointments(patientId);
      _hasPastError = false;
    } catch (_) {
      _hasPastError = true;
    } finally {
      _isLoadingPast = false;
      notifyListeners();
    }
  }

  /// Looks up the full doctor record for [doctorId] so "Reschedule" can
  /// open `DoctorProfileView`, which needs more than an appointment's
  /// denormalized doctor fields (name/specialty) carry — notably `rating`.
  /// Returns `null` if the doctor can't be found or the lookup fails.
  Future<Doctor?> getDoctorForReschedule(String doctorId) async {
    try {
      return await _appointmentService.getDoctor(doctorId);
    } catch (_) {
      return null;
    }
  }
}
