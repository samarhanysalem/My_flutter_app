import 'package:flutter/foundation.dart';

import '../../../common/models/appointment.dart';
import '../services/availability_service.dart';
import '../services/booking_service.dart';

/// Owns the selected day, that day's fetched time slots, and booking the
/// selected slot, for both AvailabilitySection and BookAppointmentButton.
/// One instance is scoped to a single doctor and shared by both widgets
/// (provided above them in DoctorProfileView).
class AvailabilityProvider extends ChangeNotifier {
  AvailabilityProvider({
    required AvailabilityService availabilityService,
    required BookingService bookingService,
    required String doctorId,
    required String doctorName,
    required String doctorSpecialty,
    String? doctorNameAr,
    required String? patientId,
    required DateTime initialDate,
    Appointment? reschedulingAppointment,
  }) : _availabilityService = availabilityService,
       _bookingService = bookingService,
       _doctorId = doctorId,
       _doctorName = doctorName,
       _doctorSpecialty = doctorSpecialty,
       _doctorNameAr = doctorNameAr,
       _patientId = patientId,
       _selectedDate = initialDate,
       _reschedulingAppointment = reschedulingAppointment {
    _load();
  }

  final AvailabilityService _availabilityService;
  final BookingService _bookingService;
  final String _doctorId;
  final String _doctorName;
  final String _doctorSpecialty;
  final String? _doctorNameAr;

  /// The appointment being moved to a new date/slot, if this session is a
  /// reschedule rather than a fresh booking — see [isRescheduling].
  final Appointment? _reschedulingAppointment;

  /// Whether [bookSelectedSlot] moves an existing appointment to the newly
  /// selected date/slot (true) or books a brand-new one (false). Read by
  /// `BookAppointmentButton` to vary its label and confirmation copy.
  bool get isRescheduling => _reschedulingAppointment != null;

  /// Null when nobody is signed in, which shouldn't happen on this
  /// (already-authenticated) screen — [bookSelectedSlot] just fails safely
  /// rather than assuming a user.
  final String? _patientId;

  DateTime _selectedDate;
  DateTime get selectedDate => _selectedDate;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  List<String> _slots = const [];
  List<String> get slots => _slots;

  int? _selectedSlotIndex;
  int? get selectedSlotIndex => _selectedSlotIndex;

  String? get selectedSlot =>
      _selectedSlotIndex == null ? null : _slots[_selectedSlotIndex!];

  bool _isBooking = false;
  bool get isBooking => _isBooking;

  void selectSlot(int index) {
    _selectedSlotIndex = index;
    notifyListeners();
  }

  Future<void> selectDate(DateTime date) async {
    if (date == _selectedDate) return;
    _selectedDate = date;
    await _load();
  }

  Future<void> _load() async {
    _isLoading = true;
    _hasError = false;
    _selectedSlotIndex = null;
    notifyListeners();
    try {
      _slots = await _availabilityService.getAvailableSlots(
        doctorId: _doctorId,
        date: _selectedDate,
      );
      _selectedSlotIndex = _slots.isEmpty ? null : 0;
    } catch (_) {
      _hasError = true;
      _slots = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Books [selectedSlot] on [selectedDate]. Returns whether it succeeded —
  /// this is a one-shot user action, not reactive state, so the caller
  /// (BookAppointmentButton) is responsible for showing confirmation/error
  /// feedback based on the result rather than this class holding onto it.
  Future<bool> bookSelectedSlot() async {
    final slot = selectedSlot;
    final patientId = _patientId;
    if (slot == null || patientId == null) return false;

    _isBooking = true;
    notifyListeners();
    var success = false;
    try {
      final rescheduling = _reschedulingAppointment;
      if (rescheduling != null) {
        await _bookingService.rescheduleAppointment(
          appointmentId: rescheduling.id,
          doctorId: _doctorId,
          doctorName: _doctorName,
          doctorSpecialty: _doctorSpecialty,
          doctorNameAr: _doctorNameAr,
          previousDate: rescheduling.date,
          previousSlot: rescheduling.slot,
          date: _selectedDate,
          slot: slot,
        );
      } else {
        await _bookingService.bookAppointment(
          patientId: patientId,
          doctorId: _doctorId,
          doctorName: _doctorName,
          doctorSpecialty: _doctorSpecialty,
          doctorNameAr: _doctorNameAr,
          date: _selectedDate,
          slot: slot,
        );
      }
      _slots = List.of(_slots)..remove(slot);
      _selectedSlotIndex = _slots.isEmpty ? null : 0;
      success = true;
    } catch (_) {
      success = false;
    } finally {
      _isBooking = false;
      notifyListeners();
    }
    return success;
  }
}
