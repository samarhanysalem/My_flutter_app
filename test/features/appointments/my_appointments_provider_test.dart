import 'package:doctor_appointment_app/common/models/appointment.dart';
import 'package:doctor_appointment_app/common/models/doctor.dart';
import 'package:doctor_appointment_app/features/appointments/view/my_appointments_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common/repositories/fake_booking_repository.dart';
import '../../common/repositories/fake_appointment_repository.dart';

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
    final repository = FakeAppointmentRepository()
      ..upcomingAppointments = [_upcoming]
      ..pastAppointments = [_past];
    final provider = MyAppointmentsProvider(
      appointmentRepository: repository,
      bookingRepository: FakeBookingRepository(),
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

    repository.dispose();
  });

  test('defaults to the Upcoming tab and switches on selectTab', () async {
    final repository = FakeAppointmentRepository();
    final provider = MyAppointmentsProvider(
      appointmentRepository: repository,
      bookingRepository: FakeBookingRepository(),
      patientId: 'u1',
    );
    await Future<void>.value();

    expect(provider.selectedTab, AppointmentsTab.upcoming);

    provider.selectTab(AppointmentsTab.past);
    expect(provider.selectedTab, AppointmentsTab.past);

    repository.dispose();
  });

  test('surfaces an error per tab when fetching fails', () async {
    final repository = FakeAppointmentRepository()
      ..getAppointmentsErrorToThrow = Exception('boom');
    final provider = MyAppointmentsProvider(
      appointmentRepository: repository,
      bookingRepository: FakeBookingRepository(),
      patientId: 'u1',
    );
    await Future<void>.value();

    expect(provider.hasUpcomingError, isTrue);
    expect(provider.hasPastError, isTrue);
    expect(provider.upcoming, isEmpty);
    expect(provider.past, isEmpty);

    repository.dispose();
  });

  test('with no signed-in patient, both tabs are empty and not loading', () async {
    final repository = FakeAppointmentRepository();
    final provider = MyAppointmentsProvider(
      appointmentRepository: repository,
      bookingRepository: FakeBookingRepository(),
      patientId: null,
    );

    expect(provider.isLoadingUpcoming, isFalse);
    expect(provider.isLoadingPast, isFalse);
    expect(provider.upcoming, isEmpty);
    expect(provider.past, isEmpty);

    repository.dispose();
  });

  test('getDoctor returns the looked-up doctor', () async {
    const doctor = Doctor(
      id: '1',
      name: 'Dr. Sara Whitmore',
      specialty: 'Cardiologist',
      rating: 4.9,
    );
    final repository = FakeAppointmentRepository()..doctorToReturn = doctor;
    final provider = MyAppointmentsProvider(
      appointmentRepository: repository,
      bookingRepository: FakeBookingRepository(),
      patientId: 'u1',
    );

    expect(await provider.getDoctor('1'), doctor);

    repository.dispose();
  });

  test('getDoctor returns null when the doctor is not found', () async {
    final repository = FakeAppointmentRepository();
    final provider = MyAppointmentsProvider(
      appointmentRepository: repository,
      bookingRepository: FakeBookingRepository(),
      patientId: 'u1',
    );

    expect(await provider.getDoctor('missing'), isNull);

    repository.dispose();
  });

  test('cancelAppointment cancels via BookingRepository and refreshes', () async {
    final repository = FakeAppointmentRepository()..upcomingAppointments = [_upcoming];
    final bookingRepository = FakeBookingRepository();
    final provider = MyAppointmentsProvider(
      appointmentRepository: repository,
      bookingRepository: bookingRepository,
      patientId: 'u1',
    );
    await Future<void>.value();
    expect(provider.upcoming, [_upcoming]);

    // Simulate the cancellation having taken effect server-side by the
    // time refresh() re-fetches.
    repository.upcomingAppointments = const [];
    final success = await provider.cancelAppointment(_upcoming);
    await Future<void>.value();

    expect(success, isTrue);
    expect(bookingRepository.cancelledAppointmentId, 'a1');
    expect(bookingRepository.cancelledDoctorId, '1');
    expect(bookingRepository.cancelledDate, '2099-01-02');
    expect(bookingRepository.cancelledSlot, '10:30 AM');
    expect(provider.upcoming, isEmpty);

    repository.dispose();
  });

  test('cancelAppointment returns false when it fails', () async {
    final repository = FakeAppointmentRepository()..upcomingAppointments = [_upcoming];
    final bookingRepository = FakeBookingRepository()
      ..errorToThrow = Exception('permission-denied');
    final provider = MyAppointmentsProvider(
      appointmentRepository: repository,
      bookingRepository: bookingRepository,
      patientId: 'u1',
    );
    await Future<void>.value();

    expect(await provider.cancelAppointment(_upcoming), isFalse);

    repository.dispose();
  });
}
