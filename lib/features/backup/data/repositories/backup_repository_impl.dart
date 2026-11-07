import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/backup_data.dart';
import '../../domain/entities/backup_info.dart';
import '../../domain/repositories/backup_repository.dart';
import '../datasources/backup_archive_service.dart';
import '../datasources/backup_prefs_datasource.dart';
import '../datasources/drive_datasource.dart';
import '../datasources/drive_error_mapper.dart';

class BackupRepositoryImpl implements BackupRepository {
  final DriveDataSource _drive;
  final BackupArchiveService _archive;
  final BackupPrefsDataSource _prefs;

  BackupRepositoryImpl(this._drive, this._archive, this._prefs);

  @override
  Future<Result<BackupInfo>> backupToDrive(BackupData data) async {
    try {
      final bytes = await _archive.buildBackupBytes(data);
      final upload = await _drive.uploadBackup(bytes);
      final info = _prefs.load().copyWith(
            lastBackupAt: upload.modifiedAt,
            driveFolderId: upload.folderId,
            status: BackupStatus.success,
          );
      await _prefs.save(info);
      return Success(info);
    } catch (e) {
      await _prefs.save(_prefs.load().copyWith(status: BackupStatus.failed));
      return Err(mapBackupError(e));
    }
  }

  @override
  Future<Result<BackupData>> restoreFromDrive() async {
    try {
      final bytes = await _drive.downloadBackup();
      return Success(await _archive.parseBackupBytes(bytes));
    } catch (e) {
      return Err(mapBackupError(e));
    }
  }

  @override
  Future<Result<String>> exportToZip(BackupData data) async {
    try {
      return Success(await _archive.buildExportZip(data));
    } catch (e) {
      return Err(mapBackupError(e));
    }
  }

  @override
  Future<Result<BackupInfo>> getBackupInfo() async {
    try {
      return Success(_prefs.load());
    } catch (e) {
      return Err<BackupInfo>(UnknownFailure(e.toString()));
    }
  }
}
