import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../common/utils/date_id.dart';

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
  /// [doctorName]/[doctorSpecialty]/[doctorNameAr] are denormalized onto
  /// the appointment record (same reasoning as Doctor's own fields) so
  /// screens that list appointments don't need a second read per doctor.
  /// Throws [BookingException] if the slot is no longer available.
  Future<void> bookAppointment({
    required String patientId,
    required String doctorId,
    required String doctorName,
    required String doctorSpecialty,
    String? doctorNameAr,
    required DateTime date,
    required String slot,
  });

  /// Moves [appointmentId] — the same doctor and patient, previously booked
  /// for [previousDate] at [previousSlot] — to [slot] on [date], updating
  /// that *same* appointment document rather than creating a second one
  /// alongside it. In the same transaction, releases [previousSlot] back
  /// into availability and removes the new [slot]. Also refreshes the
  /// denormalized doctor fields to their current values, so a reschedule
  /// incidentally fixes a stale/missing `doctorNameAr` too (see
  /// `Appointment.doctorNameAr`'s doc comment). Throws [BookingException]
  /// if the new slot is no longer available.
  Future<void> rescheduleAppointment({
    required String appointmentId,
    required String doctorId,
    required String doctorName,
    required String doctorSpecialty,
    String? doctorNameAr,
    required String previousDate,
    required String previousSlot,
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
    required String doctorSpecialty,
    String? doctorNameAr,
    required DateTime date,
    required String slot,
  }) async {
    final availabilityRef = _firestore
        .collection('doctors')
        .doc(doctorId)
        .collection('availability')
        .doc(dateId(date));
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
        'doctorSpecialty': doctorSpecialty,
        if (doctorNameAr != null) 'doctorNameAr': doctorNameAr,
        'date': dateId(date),
        'slot': slot,
        'status': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> rescheduleAppointment({
    required String appointmentId,
    required String doctorId,
    required String doctorName,
    required String doctorSpecialty,
    String? doctorNameAr,
    required String previousDate,
    required String previousSlot,
    required DateTime date,
    required String slot,
  }) async {
    final newDateId = dateId(date);
    final doctorRef = _firestore.collection('doctors').doc(doctorId);
    final newAvailabilityRef = doctorRef.collection('availability').doc(newDateId);
    final previousAvailabilityRef = doctorRef
        .collection('availability')
        .doc(previousDate);
    final appointmentRef = _firestore.collection('appointments').doc(appointmentId);
    final sameDay = newDateId == previousDate;

    await _firestore.runTransaction((transaction) async {
      final newSnapshot = await transaction.get(newAvailabilityRef);
      final newSlots =
          (newSnapshot.data()?['slots'] as List?)?.whereType<String>().toList() ??
          <String>[];
      if (!newSlots.contains(slot)) {
        throw const BookingException('slot-unavailable');
      }

      if (sameDay) {
        // The previous slot never left this document, so re-adding it and
        // removing the new one both apply to the one snapshot already read
        // above — a transaction only keeps the *last* write per document,
        // so two separate arrayRemove/arrayUnion calls on the same
        // document here would silently drop the first one. Combining them
        // into a single plain-list update avoids that.
        newSlots.remove(slot);
        if (!newSlots.contains(previousSlot)) newSlots.add(previousSlot);
        transaction.update(newAvailabilityRef, {'slots': newSlots});
      } else {
        transaction.update(newAvailabilityRef, {
          'slots': FieldValue.arrayRemove([slot]),
        });
        transaction.update(previousAvailabilityRef, {
          'slots': FieldValue.arrayUnion([previousSlot]),
        });
      }

      transaction.update(appointmentRef, {
        'doctorName': doctorName,
        'doctorSpecialty': doctorSpecialty,
        if (doctorNameAr != null) 'doctorNameAr': doctorNameAr,
        'date': newDateId,
        'slot': slot,
      });
    });
  }
}
