import 'package:doctor_appointment_app/common/models/appointment.dart';
import 'package:doctor_appointment_app/common/models/doctor.dart';
import 'package:doctor_appointment_app/features/auth/models/app_user.dart';
import 'package:doctor_appointment_app/features/auth/view/auth_provider.dart';
import 'package:doctor_appointment_app/features/doctor_profile/view/doctor_profile_view.dart';
import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../auth/fake_auth_repository.dart';
import 'fake_availability_service.dart';
import 'fake_booking_service.dart';

final _today = DateTime(2024, 1, 2);

Widget _wrap(Widget child) {
  final authProvider = AuthProvider(
    authRepository: FakeAuthRepository(
      initialUser: const AppUser(uid: 'patient-1', displayName: 'Alex Doe'),
    ),
  );
  // The AuthProvider is provided above MaterialApp (not inside `home:`) so
  // it's still reachable from routes pushed later via Navigator — see the
  // "back button pops the route" test, which pushes DoctorProfileView as a
  // second route.
  return ChangeNotifierProvider<AuthProvider>.value(
    value: authProvider,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

/// A DoctorProfileView with no published availability — most of these
/// tests don't care about specific time slots (see
/// availability_section_test.dart and the booking tests below for that),
/// just that the screen never touches real Firestore.
DoctorProfileView _profileView(
  Doctor doctor, {
  FakeAvailabilityService? availabilityService,
  FakeBookingService? bookingService,
  Appointment? reschedulingAppointment,
}) {
  return DoctorProfileView(
    doctor: doctor,
    availabilityService: availabilityService ?? FakeAvailabilityService(const {}),
    bookingService: bookingService ?? FakeBookingService(),
    reschedulingAppointment: reschedulingAppointment,
    today: _today,
  );
}

const _doctorWithBio = Doctor(
  id: '1',
  name: 'Dr. Sara Whitmore',
  specialty: 'Cardiologist',
  rating: 4.9,
  bio: 'Specializes in preventive cardiology.',
);

const _doctorWithoutBio = Doctor(
  id: '2',
  name: 'Dr. Marcus Cole',
  specialty: 'Orthopedic Surgeon',
  rating: 4.8,
);

void main() {
  testWidgets('shows the doctor\'s hero details and bio', (tester) async {
    await tester.pumpWidget(_wrap(_profileView(_doctorWithBio)));

    expect(find.text('Doctor profile'), findsOneWidget);
    expect(find.text('Dr. Sara Whitmore'), findsOneWidget);
    expect(find.text('Cardiologist'), findsOneWidget);
    expect(find.text('4.9'), findsOneWidget);
    expect(
      find.text('Specializes in preventive cardiology.'),
      findsOneWidget,
    );
  });

  testWidgets('falls back to generic copy when there is no bio', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_profileView(_doctorWithoutBio)));

    expect(
      find.text('No bio available yet for this doctor.'),
      findsOneWidget,
    );
  });

  testWidgets('back button pops the route', (tester) async {
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => _profileView(_doctorWithBio),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Doctor profile'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Doctor profile'), findsNothing);
  });

  testWidgets('a quick action shows a not-available notice', (tester) async {
    await tester.pumpWidget(_wrap(_profileView(_doctorWithBio)));

    await tester.tap(find.text('Message'));
    await tester.pump();
    expect(find.text('Message isn\'t available yet.'), findsOneWidget);
  });

  testWidgets('offers a calendar button to pick a different day', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_profileView(_doctorWithBio)));

    // The exact slots shown depend on published availability data — that's
    // covered in availability_section_test.dart. Here we only check the
    // calendar entry point exists and opens without throwing.
    expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  testWidgets('book appointment is disabled until a slot is selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        _profileView(
          _doctorWithBio,
          availabilityService: FakeAvailabilityService(const {}),
        ),
      ),
    );
    await tester.pump();

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Book appointment'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('booking the selected slot shows a confirmation', (
    tester,
  ) async {
    // On success, BookAppointmentButton pops the route and hands the
    // confirmation message back to whoever pushed it (see
    // book_appointment_button.dart) rather than showing a local SnackBar —
    // so, like the "back button pops the route" test, this pushes
    // DoctorProfileView from a launcher screen and observes the popped
    // result there instead of asserting text inside the profile screen.
    String? confirmationMessage;
    final bookingService = FakeBookingService();
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              confirmationMessage = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (_) => _profileView(
                    _doctorWithBio,
                    availabilityService: FakeAvailabilityService({
                      _today: ['10:30 AM', '1:00 PM'],
                    }),
                    bookingService: bookingService,
                  ),
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // The first slot is selected by default.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Book appointment'));
    await tester.pumpAndSettle();

    expect(find.text('Doctor profile'), findsNothing);
    expect(confirmationMessage, contains('Appointment booked'));
    expect(bookingService.bookedSlots, ['10:30 AM']);
  });

  testWidgets(
    'rescheduling updates the existing appointment instead of creating a new one',
    (tester) async {
      const originalAppointment = Appointment(
        id: 'appt-1',
        patientId: 'patient-1',
        doctorId: '1',
        doctorName: 'Dr. Sara Whitmore',
        doctorSpecialty: 'Cardiologist',
        date: '2024-01-01',
        slot: '9:00 AM',
        status: 'confirmed',
      );
      String? confirmationMessage;
      final bookingService = FakeBookingService();
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                confirmationMessage = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (_) => _profileView(
                      _doctorWithBio,
                      availabilityService: FakeAvailabilityService({
                        _today: ['10:30 AM', '1:00 PM'],
                      }),
                      bookingService: bookingService,
                      reschedulingAppointment: originalAppointment,
                    ),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Rescheduling shows different copy than a fresh booking, so a
      // patient doesn't think they've just booked a second appointment.
      expect(find.widgetWithText(ElevatedButton, 'Book appointment'), findsNothing);
      expect(find.widgetWithText(ElevatedButton, 'Confirm reschedule'), findsOneWidget);

      // The first slot is selected by default.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm reschedule'));
      await tester.pumpAndSettle();

      expect(find.text('Doctor profile'), findsNothing);
      expect(confirmationMessage, contains('rescheduled'));
      // rescheduleAppointment (which updates the same doc) was called, not
      // bookAppointment (which would create a second one) — the exact bug
      // this test guards against.
      expect(bookingService.rescheduledAppointmentId, 'appt-1');
      expect(bookingService.reschedulePreviousDate, '2024-01-01');
      expect(bookingService.reschedulePreviousSlot, '9:00 AM');
      expect(bookingService.bookedSlots, ['10:30 AM']);
    },
  );

  testWidgets('shows an error notice when rescheduling fails', (tester) async {
    const originalAppointment = Appointment(
      id: 'appt-1',
      patientId: 'patient-1',
      doctorId: '1',
      doctorName: 'Dr. Sara Whitmore',
      doctorSpecialty: 'Cardiologist',
      date: '2024-01-01',
      slot: '9:00 AM',
      status: 'confirmed',
    );
    final bookingService = FakeBookingService()
      ..errorToThrow = Exception('slot taken');
    await tester.pumpWidget(
      _wrap(
        _profileView(
          _doctorWithBio,
          availabilityService: FakeAvailabilityService({
            _today: ['10:30 AM'],
          }),
          bookingService: bookingService,
          reschedulingAppointment: originalAppointment,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm reschedule'));
    await tester.pump();

    expect(
      find.text(
        'Couldn\'t reschedule — that slot may have just been taken. Please choose another.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows an error notice when booking fails', (tester) async {
    final bookingService = FakeBookingService()
      ..errorToThrow = Exception('slot taken');
    await tester.pumpWidget(
      _wrap(
        _profileView(
          _doctorWithBio,
          availabilityService: FakeAvailabilityService({
            _today: ['10:30 AM'],
          }),
          bookingService: bookingService,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Book appointment'));
    await tester.pump();

    expect(
      find.text(
        'Couldn\'t book that slot — it may have just been taken. Please choose another.',
      ),
      findsOneWidget,
    );
    // A failed booking doesn't remove the slot.
    expect(find.text('10:30 AM'), findsOneWidget);
  });
}
