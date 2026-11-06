/// Profil issu de Google Sign-In (aucun mot de passe stocké).
class User {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.photoUrl,
  });

  @override
  bool operator ==(Object other) => other is User && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
