import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/doctor.dart';
import '../services/appointment_service.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider({required AppointmentService appointmentService})
    : _appointmentService = appointmentService {
    _doctorsSubscription = _appointmentService.watchDoctors().listen(
      _onDoctors,
      onError: _onError,
    );
  }

  final AppointmentService _appointmentService;
  late final StreamSubscription<List<Doctor>> _doctorsSubscription;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Doctor> _doctors = [];

  String _searchQuery = '';

  String? _selectedSpecialty;
  String? get selectedSpecialty => _selectedSpecialty;

  bool get hasActiveFilter =>
      _selectedSpecialty != null || _searchQuery.trim().isNotEmpty;

  /// [_doctors] narrowed by the current search text and specialty filter —
  /// both client-side, matched case-insensitively as a substring.
  List<Doctor> get doctors {
    final specialty = _selectedSpecialty?.toLowerCase();
    final query = _searchQuery.trim().toLowerCase();
    return _doctors.where((doctor) {
      final matchesSpecialty =
          specialty == null || doctor.specialty.toLowerCase().contains(specialty);
      final matchesQuery =
          query.isEmpty ||
          doctor.name.toLowerCase().contains(query) ||
          doctor.specialty.toLowerCase().contains(query);
      return matchesSpecialty && matchesQuery;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Pass `null` (the "All" shortcut) to clear the filter.
  void selectSpecialty(String? specialty) {
    _selectedSpecialty = specialty;
    notifyListeners();
  }

  void _onDoctors(List<Doctor> doctors) {
    _doctors = doctors;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void _onError(Object error) {
    _isLoading = false;
    _errorMessage = 'Something went wrong loading doctors. Please try again.';
    notifyListeners();
  }

  @override
  void dispose() {
    _doctorsSubscription.cancel();
    super.dispose();
  }
}
