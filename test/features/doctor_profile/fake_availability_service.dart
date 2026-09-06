import 'package:doctor_appointment_app/features/doctor_profile/services/availability_service.dart';

/// Hand-written test double so AvailabilitySection tests never touch real
/// Firestore. Slots are keyed by date-only (year/month/day) `DateTime`s.
class FakeAvailabilityService implements AvailabilityService {
  FakeAvailabilityService(this._slotsByDate);

  final Map<DateTime, List<String>> _slotsByDate;

  /// Set to make the next [getAvailableSlots] call fail with this error.
  Object? errorToThrow;

  @override
  Future<List<String>> getAvailableSlots({
    required String doctorId,
    required DateTime date,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    return _slotsByDate[DateTime(date.year, date.month, date.day)] ??
        const [];
  }
}
