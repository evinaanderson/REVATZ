/// Dossier où sont enregistrées les sauvegardes locales.
class StorageLocation {
  /// Chemin complet du dossier.
  final String path;

  /// true  = dossier public : 0/REVATZ ou 0/Download/REVATZ
  /// false = dossier privé de l'application (Android/data/...), repli
  ///         quand l'accès aux fichiers n'est pas autorisé.
  final bool isPublic;

  const StorageLocation({required this.path, required this.isPublic});
}
