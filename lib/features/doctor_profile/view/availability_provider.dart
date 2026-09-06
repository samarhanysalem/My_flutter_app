import 'package:flutter/foundation.dart';

import '../services/availability_service.dart';

/// Owns the selected day and that day's fetched time slots for the
/// AvailabilitySection. One instance is scoped to a single doctor.
class AvailabilityProvider extends ChangeNotifier {
  AvailabilityProvider({
    required AvailabilityService availabilityService,
    required String doctorId,
    required DateTime initialDate,
  }) : _availabilityService = availabilityService,
       _doctorId = doctorId,
       _selectedDate = initialDate {
    _load();
  }

  final AvailabilityService _availabilityService;
  final String _doctorId;

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
}
