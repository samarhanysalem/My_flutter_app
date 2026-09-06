/// A doctor sourced from Firestore's `doctors` collection. Shared across the
/// `home` and `doctor_profile` features, so it lives here rather than inside
/// either feature folder.
class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    this.bio,
  });

  final String id;
  final String name;
  final String specialty;
  final double rating;

  /// Shown on the doctor's profile screen. Null for a doctor whose record
  /// doesn't have one yet — the profile screen falls back to generic copy.
  final String? bio;

  factory Doctor.fromFirestore(String id, Map<String, dynamic> data) {
    return Doctor(
      id: id,
      name: data['name'] as String? ?? '',
      specialty: data['specialty'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      bio: data['bio'] as String?,
    );
  }
}
