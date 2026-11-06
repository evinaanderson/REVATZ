/// Erreurs métier/techniques exprimées sans dépendre d'un package externe.
abstract class Failure {
  final String message;
  const Failure(this.message);
  @override
  String toString() => '$runtimeType: $message';
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Élément introuvable']);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Erreur de base de données']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Pas de connexion internet']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentification échouée ou expirée']);
}

class StorageFullFailure extends Failure {
  const StorageFullFailure([super.message = 'Espace Google Drive insuffisant']);
}

class FileFailure extends Failure {
  const FileFailure([super.message = 'Erreur de lecture/écriture de fichier']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Erreur inconnue']);
}
