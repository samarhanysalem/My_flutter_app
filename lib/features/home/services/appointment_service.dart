import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/doctor.dart';

/// Abstraction over the appointment/doctor backend, so `HomeProvider` can be
/// unit tested with a fake instead of talking to real Firestore.
abstract class AppointmentService {
  /// Live doctor listing from the `doctors` collection.
  Stream<List<Doctor>> watchDoctors();
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
}
