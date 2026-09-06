import 'package:doctor_appointment_app/features/doctor_profile/widgets/availability_section.dart';
import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_availability_service.dart';

// Fixed reference dates so tests don't depend on which real day the suite
// runs on.
final _tuesday = DateTime(2024, 1, 2);
final _wednesday = DateTime(2024, 1, 3);
final _sunday = DateTime(2024, 1, 7);

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('fetches and shows the selected day\'s slots from the service', (
    tester,
  ) async {
    final service = FakeAvailabilityService({
      _tuesday: ['10:30 AM', '1:00 PM', '4:15 PM'],
    });
    await tester.pumpWidget(
      _wrap(
        AvailabilitySection(
          doctorId: 'doc-1',
          availabilityService: service,
          today: _tuesday,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Available today'), findsOneWidget);
    expect(find.text('10:30 AM'), findsOneWidget);
    expect(find.text('1:00 PM'), findsOneWidget);
    expect(find.text('4:15 PM'), findsOneWidget);

    // Selecting a different slot shouldn't throw and should still render
    // all three (the provider notifies with a new selected index).
    await tester.tap(find.text('1:00 PM'));
    await tester.pump();

    expect(find.text('10:30 AM'), findsOneWidget);
    expect(find.text('1:00 PM'), findsOneWidget);
    expect(find.text('4:15 PM'), findsOneWidget);
  });

  testWidgets('shows a loading indicator while the slots are being fetched', (
    tester,
  ) async {
    final service = FakeAvailabilityService({
      _tuesday: ['10:30 AM'],
    });
    await tester.pumpWidget(
      _wrap(
        AvailabilitySection(
          doctorId: 'doc-1',
          availabilityService: service,
          today: _tuesday,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('10:30 AM'), findsOneWidget);
  });

  testWidgets('picking another day from the calendar fetches that day\'s slots', (
    tester,
  ) async {
    final service = FakeAvailabilityService({
      _tuesday: ['10:30 AM', '4:15 PM'],
      _wednesday: ['9:00 AM', '5:30 PM'],
    });
    await tester.pumpWidget(
      _wrap(
        AvailabilitySection(
          doctorId: 'doc-1',
          availabilityService: service,
          today: _tuesday,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();

    // Pick Wednesday the 3rd from the calendar grid, then confirm.
    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // The title switches from "Available today" to the picked date, and
    // Wednesday's slots replace Tuesday's.
    expect(find.text('Available today'), findsNothing);
    expect(find.textContaining('Wed'), findsOneWidget);
    expect(find.text('9:00 AM'), findsOneWidget);
    expect(find.text('5:30 PM'), findsOneWidget);
    expect(find.text('10:30 AM'), findsNothing);
    expect(find.text('4:15 PM'), findsNothing);
  });

  testWidgets('shows a message instead of chips on a day with no slots', (
    tester,
  ) async {
    final service = FakeAvailabilityService(const {});
    await tester.pumpWidget(
      _wrap(
        AvailabilitySection(
          doctorId: 'doc-1',
          availabilityService: service,
          today: _sunday,
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text('No time slots available on this day.'),
      findsOneWidget,
    );
  });

  testWidgets('shows an error message when fetching slots fails', (
    tester,
  ) async {
    final service = FakeAvailabilityService(const {})
      ..errorToThrow = Exception('boom');
    await tester.pumpWidget(
      _wrap(
        AvailabilitySection(
          doctorId: 'doc-1',
          availabilityService: service,
          today: _tuesday,
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text('Couldn\'t load availability. Please try again.'),
      findsOneWidget,
    );
  });
}
