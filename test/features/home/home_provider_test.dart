import 'package:doctor_appointment_app/common/models/doctor.dart';
import 'package:doctor_appointment_app/features/home/view/home_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common/repositories/fake_appointment_repository.dart';

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
      final repository = FakeAppointmentRepository();
      final provider = HomeProvider(appointmentRepository: repository);
      expect(provider.isLoading, isTrue);

      repository.emitDoctors(doctors);
      await Future<void>.delayed(Duration.zero);

      expect(provider.isLoading, isFalse);
      expect(provider.doctors, doctors);
      expect(provider.hasError, isFalse);

      provider.dispose();
      repository.dispose();
    });

    test('surfaces an error message on stream failure', () async {
      final repository = FakeAppointmentRepository();
      final provider = HomeProvider(appointmentRepository: repository);

      repository.emitError(Exception('boom'));
      await Future<void>.delayed(Duration.zero);

      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isTrue);
      expect(provider.doctors, isEmpty);

      provider.dispose();
      repository.dispose();
    });

    test('search query filters by name or specialty, case-insensitively', () async {
      final repository = FakeAppointmentRepository();
      final provider = HomeProvider(appointmentRepository: repository);
      repository.emitDoctors(doctors);
      await Future<void>.delayed(Duration.zero);

      provider.setSearchQuery('cole');
      expect(provider.doctors, [doctors[1]]);

      provider.setSearchQuery('cardiologist');
      expect(provider.doctors, [doctors[0]]);

      provider.setSearchQuery('');
      expect(provider.doctors, doctors);

      provider.dispose();
      repository.dispose();
    });

    test('selecting a specialty filters, and selecting null (All) clears it', () async {
      final repository = FakeAppointmentRepository();
      final provider = HomeProvider(appointmentRepository: repository);
      repository.emitDoctors(doctors);
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
      repository.dispose();
    });
  });
}
