import '../../../../core/result/result.dart';
import '../entities/backup_data.dart';
import '../entities/backup_info.dart';

abstract class BackupRepository {
  /// Envoie (ou met à jour) la sauvegarde sur Google Drive.
  Future<Result<BackupInfo>> backupToDrive(BackupData data);

  /// Télécharge la dernière sauvegarde depuis Drive.
  Future<Result<BackupData>> restoreFromDrive();

  /// Crée un ZIP local (un dossier par catégorie) et retourne son chemin.
  Future<Result<String>> exportToZip(BackupData data);

  Future<Result<BackupInfo>> getBackupInfo();
}
