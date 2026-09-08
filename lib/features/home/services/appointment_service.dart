import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../common/models/appointment.dart';
import '../../../common/models/doctor.dart';
import '../../../common/utils/date_id.dart';

/// Abstraction over the appointment/doctor backend, so `HomeProvider` can be
/// unit tested with a fake instead of talking to real Firestore.
abstract class AppointmentService {
  /// Live doctor listing from the `doctors` collection.
  Stream<List<Doctor>> watchDoctors();

  /// The nearest confirmed appointment for [patientId] that's today or
  /// later, or `null` if they don't have one. Used for Home's "upcoming
  /// appointment" card.
  Stream<Appointment?> watchUpcomingAppointment(String patientId);

  /// [patientId]'s confirmed appointments that are today or later, soonest
  /// first. Used by My appointments' Upcoming tab. A one-time fetch (not a
  /// stream) — the screen re-fetches on demand rather than staying
  /// subscribed, matching CLAUDE.md's async/await guidance.
  Future<List<Appointment>> getUpcomingAppointments(String patientId);

  /// [patientId]'s appointments dated before today, most recent first.
  /// There's no cancellation/completion flow yet, so nothing ever sets a
  /// `completed` status — "past" is date-based instead, the same reasoning
  /// [watchUpcomingAppointment] already uses for "upcoming".
  Future<List<Appointment>> getPastAppointments(String patientId);

  /// A single doctor by id, or `null` if it no longer exists. Used by My
  /// appointments' "Reschedule" action, which needs the doctor's full
  /// record (rating, bio) to open `DoctorProfileView` — more than an
  /// appointment's denormalized doctor fields carry.
  Future<Doctor?> getDoctor(String doctorId);
}

class FirestoreAppointmentService implements AppointmentService {
  FirestoreAppointmentService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<Doctor>> watchDoctors() {
    return _firestore
        .collection('doctors')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Doctor.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Stream<Appointment?> watchUpcomingAppointment(String patientId) {
    // Filtered/sorted client-side rather than via a composite Firestore
    // query (patientId == && date >= && orderBy(date)) — that combination
    // needs a composite index that has to be created out-of-band in the
    // Firebase console, and a single patient's appointment count is small
    // enough that this is a non-issue.
    return _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map((snapshot) {
          final today = dateId(DateTime.now());
          final upcoming =
              snapshot.docs
                  .map((doc) => Appointment.fromFirestore(doc.id, doc.data()))
                  .where(
                    (appointment) =>
                        appointment.status == 'confirmed' &&
                        appointment.date.compareTo(today) >= 0,
                  )
                  .toList()
                ..sort((a, b) => a.date.compareTo(b.date));
          return upcoming.isEmpty ? null : upcoming.first;
        });
  }

  /// Both list methods below read the same `patientId`-filtered query and
  /// split it client-side by date, for the same reason
  /// [watchUpcomingAppointment] already avoids a composite Firestore query
  /// (patientId == && date >= && orderBy(date)): that needs an index
  /// created out-of-band in the Firebase console, and a single patient's
  /// appointment count is small enough that this is a non-issue.
  Future<List<Map<String, dynamic>>> _appointmentDocs(String patientId) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }

  @override
  Future<List<Appointment>> getUpcomingAppointments(String patientId) async {
    final docs = await _appointmentDocs(patientId);
    final today = dateId(DateTime.now());
    final upcoming =
        docs
            .map((data) => Appointment.fromFirestore(data['id'] as String, data))
            .where(
              (appointment) =>
                  appointment.status == 'confirmed' &&
                  appointment.date.compareTo(today) >= 0,
            )
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    return upcoming;
  }

  @override
  Future<List<Appointment>> getPastAppointments(String patientId) async {
    final docs = await _appointmentDocs(patientId);
    final today = dateId(DateTime.now());
    final past =
        docs
            .map((data) => Appointment.fromFirestore(data['id'] as String, data))
            .where((appointment) => appointment.date.compareTo(today) < 0)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    return past;
  }

  @override
  Future<Doctor?> getDoctor(String doctorId) async {
    final doc = await _firestore.collection('doctors').doc(doctorId).get();
    final data = doc.data();
    if (data == null) return null;
    return Doctor.fromFirestore(doc.id, data);
  }
}
