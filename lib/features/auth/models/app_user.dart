/// Minimal representation of the signed-in user, decoupled from
/// `package:firebase_auth`'s `User` type so the rest of the app (and tests)
/// don't depend on a Firebase-specific, hard-to-construct object.
class AppUser {
  const AppUser({required this.uid, this.email});

  final String uid;
  final String? email;
}
