/// The signed-in patient's profile document, sourced from Firestore's
/// `users/{uid}` doc (the same doc `FirebaseAuthRepository.signUp` creates).
class UserProfile {
  const UserProfile({required this.fullName, required this.email, required this.phone});

  final String fullName;
  final String email;
  final String phone;

  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    return UserProfile(
      fullName: data['fullName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
    );
  }
}
