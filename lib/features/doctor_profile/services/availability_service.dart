import 'package:cloud_firestore/cloud_firestore.dart';

import 'availability_date_id.dart';

/// Abstraction over the availability backend, so `AvailabilityProvider` can
/// be unit tested with a fake instead of talking to real Firestore.
abstract class AvailabilityService {
  /// The time slots available for [doctorId] on [date] (time-of-day only —
  /// the caller is responsible for narrowing [date] to a single day).
  /// Empty when the doctor has no published availability for that day
  /// (including a day with no `availability` document at all).
  Future<List<String>> getAvailableSlots({
    required String doctorId,
    required DateTime date,
  });
}

class FirestoreAvailabilityService implements AvailabilityService {
  FirestoreAvailabilityService({FirebaseFirestore? firestore})
    : _explicitFirestore = firestore;

  final FirebaseFirestore? _explicitFirestore;

  // Resolved lazily (on first actual use, inside the try/catch-guarded
  // AvailabilityProvider._load()) rather than in the constructor, so simply
  // constructing this default service — which AvailabilitySection does
  // whenever a widget test doesn't inject a fake — doesn't crash before
  // Firebase.initializeApp() has run.
  FirebaseFirestore get _firestore => _explicitFirestore ?? FirebaseFirestore.instance;

  @override
  Future<List<String>> getAvailableSlots({
    required String doctorId,
    required DateTime date,
  }) async {
    final snapshot = await _firestore
        .collection('doctors')
        .doc(doctorId)
        .collection('availability')
        .doc(availabilityDateId(date))
        .get();
    final slots = snapshot.data()?['slots'];
    if (slots is! List) return const [];
    return slots.whereType<String>().toList();
  }
}
