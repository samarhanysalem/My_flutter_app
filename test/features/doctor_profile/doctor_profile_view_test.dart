import 'package:doctor_appointment_app/common/models/doctor.dart';
import 'package:doctor_appointment_app/features/doctor_profile/view/doctor_profile_view.dart';
import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_availability_service.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

/// A DoctorProfileView with no published availability — none of these
/// tests care about specific time slots (see availability_section_test.dart
/// for that), just that the screen never touches real Firestore.
DoctorProfileView _profileView(Doctor doctor) {
  return DoctorProfileView(
    doctor: doctor,
    availabilityService: FakeAvailabilityService(const {}),
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

  testWidgets('book appointment shows a not-available notice', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_profileView(_doctorWithBio)));

    await tester.tap(find.text('Book appointment'));
    await tester.pump();
    expect(find.text('Booking isn\'t available yet.'), findsOneWidget);
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
}
