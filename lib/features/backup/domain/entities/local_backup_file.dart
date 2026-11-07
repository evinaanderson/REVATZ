/// Un fichier ZIP trouvé dans le dossier REVATZ.
class LocalBackupFile {
  final String path;
  final String name;
  final int sizeBytes;
  final DateTime modifiedAt;

  const LocalBackupFile({
    required this.path,
    required this.name,
    required this.sizeBytes,
    required this.modifiedAt,
  });
}
