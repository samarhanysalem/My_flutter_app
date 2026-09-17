import 'package:doctor_appointment_app/common/models/appointment.dart';
import 'package:doctor_appointment_app/common/models/doctor.dart';
import 'package:doctor_appointment_app/common/widgets/localized_doctor_name.dart';
import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _appointmentWithArabicName = Appointment(
  id: 'a1',
  patientId: 'u1',
  doctorId: '1',
  doctorName: 'Dr. Sara Whitmore',
  doctorNameAr: 'د. سارة ويتمور',
  doctorSpecialty: 'Cardiologist',
  date: '2099-01-02',
  slot: '10:30 AM',
  status: 'confirmed',
);

const _appointmentWithoutArabicName = Appointment(
  id: 'a2',
  patientId: 'u1',
  doctorId: '2',
  doctorName: 'Dr. Marcus Cole',
  doctorSpecialty: 'Orthopedic Surgeon',
  date: '2099-01-02',
  slot: '9:00 AM',
  status: 'confirmed',
);

Widget _wrap(Widget child, {required Locale locale}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets(
    'shows the appointment\'s own Arabic name directly, without a lookup',
    (tester) async {
      var lookupCalled = false;
      await tester.pumpWidget(
        _wrap(
          LocalizedDoctorName(
            appointment: _appointmentWithArabicName,
            lookupDoctor: (_) async {
              lookupCalled = true;
              return null;
            },
          ),
          locale: const Locale('ar'),
        ),
      );
      await tester.pump();

      expect(find.text('د. سارة ويتمور'), findsOneWidget);
      expect(lookupCalled, isFalse);
    },
  );

  testWidgets(
    'shows the English name in English locale, without a lookup, even with no Arabic name',
    (tester) async {
      var lookupCalled = false;
      await tester.pumpWidget(
        _wrap(
          LocalizedDoctorName(
            appointment: _appointmentWithoutArabicName,
            lookupDoctor: (_) async {
              lookupCalled = true;
              return null;
            },
          ),
          locale: const Locale('en'),
        ),
      );
      await tester.pump();

      expect(find.text('Dr. Marcus Cole'), findsOneWidget);
      expect(lookupCalled, isFalse);
    },
  );

  testWidgets(
    'falls back to a live doctor lookup when the Arabic name is missing in Arabic locale, '
    'upgrading from English once it resolves',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          LocalizedDoctorName(
            appointment: _appointmentWithoutArabicName,
            lookupDoctor: (doctorId) async {
              expect(doctorId, '2');
              return const Doctor(
                id: '2',
                name: 'Dr. Marcus Cole',
                nameAr: 'د. ماركوس كول',
                specialty: 'Orthopedic Surgeon',
                rating: 4.8,
              );
            },
          ),
          locale: const Locale('ar'),
        ),
      );

      // Before the lookup resolves, it shows the English name rather than a
      // loading indicator — an appointment predating the doctor's Arabic
      // name is the rare case, not worth a spinner for.
      expect(find.text('Dr. Marcus Cole'), findsOneWidget);

      await tester.pump();

      expect(find.text('د. ماركوس كول'), findsOneWidget);
      expect(find.text('Dr. Marcus Cole'), findsNothing);
    },
  );

  testWidgets(
    'stays on the English name when the lookup finds no Arabic name either',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          LocalizedDoctorName(
            appointment: _appointmentWithoutArabicName,
            lookupDoctor: (_) async => const Doctor(
              id: '2',
              name: 'Dr. Marcus Cole',
              specialty: 'Orthopedic Surgeon',
              rating: 4.8,
            ),
          ),
          locale: const Locale('ar'),
        ),
      );
      await tester.pump();

      expect(find.text('Dr. Marcus Cole'), findsOneWidget);
    },
  );

  testWidgets(
    'stays on the English name when the lookup fails to find the doctor',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          LocalizedDoctorName(
            appointment: _appointmentWithoutArabicName,
            lookupDoctor: (_) async => null,
          ),
          locale: const Locale('ar'),
        ),
      );
      await tester.pump();

      expect(find.text('Dr. Marcus Cole'), findsOneWidget);
    },
  );
}
