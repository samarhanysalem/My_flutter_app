/// A doctor listed on the Home screen, sourced from Firestore's `doctors`
/// collection.
class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.distanceMiles,
    required this.rating,
  });

  final String id;
  final String name;
  final String specialty;
  final double distanceMiles;
  final double rating;

  factory Doctor.fromFirestore(String id, Map<String, dynamic> data) {
    return Doctor(
      id: id,
      name: data['name'] as String? ?? '',
      specialty: data['specialty'] as String? ?? '',
      distanceMiles: (data['distanceMiles'] as num?)?.toDouble() ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
    );
  }
}
