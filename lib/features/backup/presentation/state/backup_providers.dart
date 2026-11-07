import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/backup_data.dart';
import '../../domain/entities/backup_info.dart';
import '../../domain/entities/local_backup_file.dart';
import '../../domain/usecases/backup_usecases.dart';

/// État de la sauvegarde Google Drive.
/// Après une sauvegarde : `ref.invalidate(backupInfoProvider)`.
final backupInfoProvider = FutureProvider.autoDispose<BackupInfo>((ref) async {
  final result = await sl<GetBackupInfo>()(const NoParams());
  return result.valueOrNull ?? const BackupInfo();
});

class BackupActions {
  final SaveLocalBackup _saveLocal;
  final RestoreFromLocalFile _restoreLocal;
  final ListLocalBackups _listLocal;
  final ExportToZip _export;
  final BackupToDrive _backupDrive;
  final RestoreFromDrive _restoreDrive;

  BackupActions(this._saveLocal, this._restoreLocal, this._listLocal,
      this._export, this._backupDrive, this._restoreDrive);

  // Local
  Future<Result<String>> saveLocal() => _saveLocal(const NoParams());
  Future<Result<BackupData>> restoreLocal(String zipPath) => _restoreLocal(zipPath);
  Future<Result<List<LocalBackupFile>>> listLocal() => _listLocal(const NoParams());
  Future<Result<String>> exportZip() => _export(const NoParams());

  // Google Drive
  Future<Result<BackupInfo>> backupToDrive() => _backupDrive(const NoParams());
  Future<Result<BackupData>> restoreFromDrive() => _restoreDrive(const NoParams());
}

final backupActionsProvider = Provider<BackupActions>(
    (ref) => BackupActions(sl(), sl(), sl(), sl(), sl(), sl()));
