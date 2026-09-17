import 'dart:async';

import 'package:doctor_appointment_app/common/models/appointment.dart';
import 'package:doctor_appointment_app/common/models/doctor.dart';
import 'package:doctor_appointment_app/features/home/services/appointment_service.dart';

/// Hand-written test double so Home tests never touch real Firestore.
class FakeAppointmentService implements AppointmentService {
  final _controller = StreamController<List<Doctor>>.broadcast();
  final _upcomingAppointmentController =
      StreamController<Appointment?>.broadcast();

  @override
  Stream<List<Doctor>> watchDoctors() => _controller.stream;

  void emitDoctors(List<Doctor> doctors) => _controller.add(doctors);

  void emitError(Object error) => _controller.addError(error);

  @override
  Stream<Appointment?> watchUpcomingAppointment(String patientId) =>
      _upcomingAppointmentController.stream;

  void emitUpcomingAppointment(Appointment? appointment) =>
      _upcomingAppointmentController.add(appointment);

  /// Canned results for [getUpcomingAppointments]/[getPastAppointments] —
  /// set by a test before pumping, since (unlike the streams above) these
  /// are one-time fetches My appointments awaits during its first build.
  List<Appointment> upcomingAppointments = const [];
  List<Appointment> pastAppointments = const [];

  /// Set to make the next [getUpcomingAppointments]/[getPastAppointments]
  /// call fail with this error.
  Object? getAppointmentsErrorToThrow;

  @override
  Future<List<Appointment>> getUpcomingAppointments(String patientId) async {
    if (getAppointmentsErrorToThrow != null) throw getAppointmentsErrorToThrow!;
    return upcomingAppointments;
  }

  @override
  Future<List<Appointment>> getPastAppointments(String patientId) async {
    if (getAppointmentsErrorToThrow != null) throw getAppointmentsErrorToThrow!;
    return pastAppointments;
  }

  /// Canned result for [getDoctor] — set by a test exercising "Reschedule".
  Doctor? doctorToReturn;

  @override
  Future<Doctor?> getDoctor(String doctorId) async => doctorToReturn;

  void dispose() {
    _controller.close();
    _upcomingAppointmentController.close();
  }
}
