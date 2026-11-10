import '../../../../core/result/result.dart';
import '../entities/backup_data.dart';
import '../entities/backup_info.dart';
import '../entities/local_backup_file.dart';
import '../entities/storage_location.dart';

abstract class BackupRepository {
  // ----- Local (dossier REVATZ) -----

  /// Crée REVATZ/Sermon_[datetime].zip (sermon.json + photos/) et retourne son chemin.
  Future<Result<String>> saveLocalBackup(BackupData data);

  /// Lit un ZIP (sermon.json + photos) choisi par l'utilisateur.
  Future<Result<BackupData>> restoreFromLocalFile(String zipPath);

  /// Liste les ZIP présents dans le dossier REVATZ, du plus récent au plus ancien.
  Future<Result<List<LocalBackupFile>>> listLocalBackups();

  /// ZIP lisible : un dossier par catégorie + sermon.json (pour la restauration).
  Future<Result<String>> exportToZip(BackupData data);

  /// Dossier utilisé pour les sauvegardes locales
  /// (0/REVATZ, 0/Download/REVATZ, ou dossier privé en repli).
  /// [requestAccess] : demande l'autorisation « Accès à tous les fichiers ».
  Future<Result<StorageLocation>> getStorageLocation({bool requestAccess = false});

  // ----- Google Drive -----
  Future<Result<BackupInfo>> backupToDrive(BackupData data);
  Future<Result<BackupData>> restoreFromDrive();
  Future<Result<BackupInfo>> getBackupInfo();
}
