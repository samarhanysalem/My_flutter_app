import 'package:doctor_appointment_app/features/doctor_profile/services/booking_service.dart';

/// Hand-written test double so booking tests never touch real Firestore.
class FakeBookingService implements BookingService {
  /// Set to make the next [bookAppointment] call fail with this error.
  Object? errorToThrow;

  final bookedSlots = <String>[];

  @override
  Future<void> bookAppointment({
    required String patientId,
    required String doctorId,
    required String doctorName,
    required String doctorSpecialty,
    String? doctorNameAr,
    required DateTime date,
    required String slot,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    bookedSlots.add(slot);
  }

  /// Set by [rescheduleAppointment] with the args it was called with, so a
  /// test can assert the *same* appointment was updated rather than a new
  /// one created.
  String? rescheduledAppointmentId;
  String? reschedulePreviousDate;
  String? reschedulePreviousSlot;

  @override
  Future<void> rescheduleAppointment({
    required String appointmentId,
    required String doctorId,
    required String doctorName,
    required String doctorSpecialty,
    String? doctorNameAr,
    required String previousDate,
    required String previousSlot,
    required DateTime date,
    required String slot,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    rescheduledAppointmentId = appointmentId;
    reschedulePreviousDate = previousDate;
    reschedulePreviousSlot = previousSlot;
    bookedSlots.add(slot);
  }
}
