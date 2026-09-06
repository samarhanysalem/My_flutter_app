import 'package:doctor_appointment_app/features/doctor_profile/widgets/availability_section.dart';
import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Fixed reference dates so the mock per-weekday schedule in
// AvailabilitySection is deterministic regardless of which real day the
// suite runs on.
final _tuesday = DateTime(2024, 1, 2);
final _sunday = DateTime(2024, 1, 7);

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('shows the selected day\'s slots and lets one be selected', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(AvailabilitySection(today: _tuesday)));

    expect(find.text('Available today'), findsOneWidget);
    expect(find.text('10:30 AM'), findsOneWidget);
    expect(find.text('1:00 PM'), findsOneWidget);
    expect(find.text('4:15 PM'), findsOneWidget);

    // Selecting a different slot shouldn't throw and should still render
    // all three (the widget re-renders with a new selected index).
    await tester.tap(find.text('1:00 PM'));
    await tester.pump();

    expect(find.text('10:30 AM'), findsOneWidget);
    expect(find.text('1:00 PM'), findsOneWidget);
    expect(find.text('4:15 PM'), findsOneWidget);
  });

  testWidgets('picking another day from the calendar shows that day\'s slots', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(AvailabilitySection(today: _tuesday)));

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
    await tester.pumpWidget(_wrap(AvailabilitySection(today: _sunday)));

    expect(
      find.text('No time slots available on this day.'),
      findsOneWidget,
    );
  });
}
