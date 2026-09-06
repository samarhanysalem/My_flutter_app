import 'package:doctor_appointment_app/common/models/doctor.dart';
import 'package:doctor_appointment_app/features/home/view/home_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_appointment_service.dart';

void main() {
  group('HomeProvider', () {
    const doctors = [
      Doctor(
        id: '1',
        name: 'Dr. Sara Whitmore',
        specialty: 'Cardiologist',
        rating: 4.9,
      ),
      Doctor(
        id: '2',
        name: 'Dr. Marcus Cole',
        specialty: 'Orthopedic Surgeon',
        rating: 4.8,
      ),
    ];

    test('starts loading then shows fetched doctors', () async {
      final service = FakeAppointmentService();
      final provider = HomeProvider(appointmentService: service);
      expect(provider.isLoading, isTrue);

      service.emitDoctors(doctors);
      await Future<void>.delayed(Duration.zero);

      expect(provider.isLoading, isFalse);
      expect(provider.doctors, doctors);
      expect(provider.errorMessage, isNull);

      provider.dispose();
      service.dispose();
    });

    test('surfaces an error message on stream failure', () async {
      final service = FakeAppointmentService();
      final provider = HomeProvider(appointmentService: service);

      service.emitError(Exception('boom'));
      await Future<void>.delayed(Duration.zero);

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNotNull);
      expect(provider.doctors, isEmpty);

      provider.dispose();
      service.dispose();
    });

    test('search query filters by name or specialty, case-insensitively', () async {
      final service = FakeAppointmentService();
      final provider = HomeProvider(appointmentService: service);
      service.emitDoctors(doctors);
      await Future<void>.delayed(Duration.zero);

      provider.setSearchQuery('cole');
      expect(provider.doctors, [doctors[1]]);

      provider.setSearchQuery('cardiologist');
      expect(provider.doctors, [doctors[0]]);

      provider.setSearchQuery('');
      expect(provider.doctors, doctors);

      provider.dispose();
      service.dispose();
    });

    test('selecting a specialty filters, and selecting null (All) clears it', () async {
      final service = FakeAppointmentService();
      final provider = HomeProvider(appointmentService: service);
      service.emitDoctors(doctors);
      await Future<void>.delayed(Duration.zero);

      provider.selectSpecialty('Cardiologist');
      expect(provider.selectedSpecialty, 'Cardiologist');
      expect(provider.doctors, [doctors[0]]);
      expect(provider.hasActiveFilter, isTrue);

      provider.selectSpecialty(null);
      expect(provider.selectedSpecialty, isNull);
      expect(provider.doctors, doctors);
      expect(provider.hasActiveFilter, isFalse);

      provider.dispose();
      service.dispose();
    });
  });
}
