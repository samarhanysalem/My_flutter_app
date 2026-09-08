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
}
