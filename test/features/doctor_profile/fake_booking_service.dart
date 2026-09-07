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
    required DateTime date,
    required String slot,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    bookedSlots.add(slot);
  }
}
