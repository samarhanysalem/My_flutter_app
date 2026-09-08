import 'package:doctor_appointment_app/common/models/appointment.dart';
import 'package:doctor_appointment_app/common/models/doctor.dart';
import 'package:doctor_appointment_app/features/appointments/view/my_appointments_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../home/fake_appointment_service.dart';

const _upcoming = Appointment(
  id: 'a1',
  patientId: 'u1',
  doctorId: '1',
  doctorName: 'Dr. Sara Whitmore',
  doctorSpecialty: 'Cardiologist',
  date: '2099-01-02',
  slot: '10:30 AM',
  status: 'confirmed',
);

const _past = Appointment(
  id: 'a2',
  patientId: 'u1',
  doctorId: '2',
  doctorName: 'Dr. Marcus Cole',
  doctorSpecialty: 'Orthopedic Surgeon',
  date: '2020-01-02',
  slot: '9:00 AM',
  status: 'confirmed',
);

void main() {
  test('starts loading both tabs, then shows the fetched lists', () async {
    final service = FakeAppointmentService()
      ..upcomingAppointments = [_upcoming]
      ..pastAppointments = [_past];
    final provider = MyAppointmentsProvider(
      appointmentService: service,
      patientId: 'u1',
    );

    expect(provider.isLoadingUpcoming, isTrue);
    expect(provider.isLoadingPast, isTrue);

    // The fakes resolve on the next microtask tick.
    await Future<void>.value();

    expect(provider.isLoadingUpcoming, isFalse);
    expect(provider.isLoadingPast, isFalse);
    expect(provider.upcoming, [_upcoming]);
    expect(provider.past, [_past]);
    expect(provider.hasUpcomingError, isFalse);
    expect(provider.hasPastError, isFalse);

    service.dispose();
  });

  test('defaults to the Upcoming tab and switches on selectTab', () async {
    final service = FakeAppointmentService();
    final provider = MyAppointmentsProvider(
      appointmentService: service,
      patientId: 'u1',
    );
    await Future<void>.value();

    expect(provider.selectedTab, AppointmentsTab.upcoming);

    provider.selectTab(AppointmentsTab.past);
    expect(provider.selectedTab, AppointmentsTab.past);

    service.dispose();
  });

  test('surfaces an error per tab when fetching fails', () async {
    final service = FakeAppointmentService()
      ..getAppointmentsErrorToThrow = Exception('boom');
    final provider = MyAppointmentsProvider(
      appointmentService: service,
      patientId: 'u1',
    );
    await Future<void>.value();

    expect(provider.hasUpcomingError, isTrue);
    expect(provider.hasPastError, isTrue);
    expect(provider.upcoming, isEmpty);
    expect(provider.past, isEmpty);

    service.dispose();
  });

  test('with no signed-in patient, both tabs are empty and not loading', () async {
    final service = FakeAppointmentService();
    final provider = MyAppointmentsProvider(
      appointmentService: service,
      patientId: null,
    );

    expect(provider.isLoadingUpcoming, isFalse);
    expect(provider.isLoadingPast, isFalse);
    expect(provider.upcoming, isEmpty);
    expect(provider.past, isEmpty);

    service.dispose();
  });

  test('getDoctor returns the looked-up doctor', () async {
    const doctor = Doctor(
      id: '1',
      name: 'Dr. Sara Whitmore',
      specialty: 'Cardiologist',
      rating: 4.9,
    );
    final service = FakeAppointmentService()..doctorToReturn = doctor;
    final provider = MyAppointmentsProvider(
      appointmentService: service,
      patientId: 'u1',
    );

    expect(await provider.getDoctor('1'), doctor);

    service.dispose();
  });

  test('getDoctor returns null when the doctor is not found', () async {
    final service = FakeAppointmentService();
    final provider = MyAppointmentsProvider(
      appointmentService: service,
      patientId: 'u1',
    );

    expect(await provider.getDoctor('missing'), isNull);

    service.dispose();
  });
}
