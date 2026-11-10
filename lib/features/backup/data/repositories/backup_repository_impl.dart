import 'dart:io';

import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../../sermon/domain/entities/sermon.dart';
import '../../domain/entities/backup_data.dart';
import '../../domain/entities/backup_info.dart';
import '../../domain/entities/local_backup_file.dart';
import '../../domain/entities/storage_location.dart';
import '../../domain/repositories/backup_repository.dart';
import '../datasources/backup_archive_service.dart';
import '../datasources/backup_prefs_datasource.dart';
import '../datasources/drive_datasource.dart';
import '../datasources/drive_error_mapper.dart';
import '../datasources/local_backup_storage.dart';

class BackupRepositoryImpl implements BackupRepository {
  final DriveDataSource _drive;
  final BackupArchiveService _archive;
  final BackupPrefsDataSource _prefs;
  final LocalBackupStorage _local;

  BackupRepositoryImpl(this._drive, this._archive, this._prefs, this._local);

  // ------------------------------------------------------------- Local
  @override
  Future<Result<String>> saveLocalBackup(BackupData data) async {
    try {
      final bytes = await _archive.buildBackupBytes(data);
      final path = await _local.save('Sermon_${_local.stamp()}.zip', bytes);
      return Success(path);
    } catch (e) {
      return Err(mapBackupError(e));
    }
  }

  @override
  Future<Result<BackupData>> restoreFromLocalFile(String zipPath) async {
    try {
      final bytes = await File(zipPath).readAsBytes();
      // Après une restauration locale, les sermons restent « à synchroniser ».
      return Success(
          await _archive.parseBackupBytes(bytes, status: SyncStatus.pending));
    } catch (e) {
      return Err(mapBackupError(e));
    }
  }

  @override
  Future<Result<List<LocalBackupFile>>> listLocalBackups() async {
    try {
      return Success(await _local.list());
    } catch (e) {
      return Err(mapBackupError(e));
    }
  }

  @override
  Future<Result<String>> exportToZip(BackupData data) async {
    try {
      final bytes = await _archive.buildExportBytes(data);
      final path = await _local.save('Export_${_local.stamp()}.zip', bytes);
      return Success(path);
    } catch (e) {
      return Err(mapBackupError(e));
    }
  }

  @override
  Future<Result<StorageLocation>> getStorageLocation({
    bool requestAccess = false,
  }) async {
    try {
      return Success(await _local.location(
        requestAccess: requestAccess,
        openSettings: requestAccess,
      ));
    } catch (e) {
      return Err(mapBackupError(e));
    }
  }

  // ------------------------------------------------------------- Drive
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
      return Success(
          await _archive.parseBackupBytes(bytes, status: SyncStatus.synced));
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
