import 'package:cloud_firestore/cloud_firestore.dart';

import 'availability_date_id.dart';

/// Thrown when a booking can't be completed — most notably when the slot
/// was booked by someone else between being shown and being confirmed.
class BookingException implements Exception {
  const BookingException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Abstraction over the booking backend, so `AvailabilityProvider` can be
/// unit tested with a fake instead of talking to real Firestore.
abstract class BookingService {
  /// Books [slot] on [date] for [doctorId], on behalf of [patientId].
  /// Throws [BookingException] if the slot is no longer available.
  Future<void> bookAppointment({
    required String patientId,
    required String doctorId,
    required String doctorName,
    required DateTime date,
    required String slot,
  });
}

class FirestoreBookingService implements BookingService {
  FirestoreBookingService({FirebaseFirestore? firestore})
    : _explicitFirestore = firestore;

  final FirebaseFirestore? _explicitFirestore;

  // Resolved lazily for the same reason as FirestoreAvailabilityService —
  // see that class.
  FirebaseFirestore get _firestore => _explicitFirestore ?? FirebaseFirestore.instance;

  @override
  Future<void> bookAppointment({
    required String patientId,
    required String doctorId,
    required String doctorName,
    required DateTime date,
    required String slot,
  }) async {
    final availabilityRef = _firestore
        .collection('doctors')
        .doc(doctorId)
        .collection('availability')
        .doc(availabilityDateId(date));
    final appointmentRef = _firestore.collection('appointments').doc();

    // A transaction so two patients racing for the same slot can't both
    // "win" — the loser's write is retried against a fresh read and fails
    // the containsSlot check once the slot is gone.
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(availabilityRef);
      final slots =
          (snapshot.data()?['slots'] as List?)?.whereType<String>() ??
          const <String>[];
      if (!slots.contains(slot)) {
        throw const BookingException('slot-unavailable');
      }
      transaction.update(availabilityRef, {
        'slots': FieldValue.arrayRemove([slot]),
      });
      transaction.set(appointmentRef, {
        'patientId': patientId,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'date': availabilityDateId(date),
        'slot': slot,
        'status': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
