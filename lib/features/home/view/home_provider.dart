import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../common/models/doctor.dart';
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

  // Only whether loading failed, not the message itself — the message is
  // user-facing copy, so it's localized where it's displayed (DoctorList)
  // rather than baked into this non-widget layer as a fixed-language string.
  bool _hasError = false;
  bool get hasError => _hasError;

  List<Doctor> _doctors = [];
  List<Doctor> _allDoctors = List.unmodifiable(const <Doctor>[]);

  /// The unfiltered list, for building search suggestions from — [doctors]
  /// below is already narrowed by the current filters. Cached alongside
  /// [_doctors] rather than wrapped on every access, since this is read on
  /// every rebuild of the search bar.
  List<Doctor> get allDoctors => _allDoctors;

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
    _allDoctors = List.unmodifiable(doctors);
    _isLoading = false;
    _hasError = false;
    notifyListeners();
  }

  void _onError(Object error) {
    _isLoading = false;
    _hasError = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _doctorsSubscription.cancel();
    super.dispose();
  }
}
