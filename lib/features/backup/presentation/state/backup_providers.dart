import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/backup_data.dart';
import '../../domain/entities/backup_info.dart';
import '../../domain/usecases/backup_usecases.dart';

/// Après une sauvegarde : `ref.invalidate(backupInfoProvider)`.
final backupInfoProvider = FutureProvider.autoDispose<BackupInfo>((ref) async {
  final result = await sl<GetBackupInfo>()(const NoParams());
  return result.valueOrNull ?? const BackupInfo();
});

class BackupActions {
  final BackupToDrive _backup;
  final RestoreFromDrive _restore;
  final ExportToZip _export;
  BackupActions(this._backup, this._restore, this._export);

  Future<Result<BackupInfo>> backup() => _backup(const NoParams());
  Future<Result<BackupData>> restore() => _restore(const NoParams());
  Future<Result<String>> exportZip() => _export(const NoParams());
}

final backupActionsProvider =
    Provider<BackupActions>((ref) => BackupActions(sl(), sl(), sl()));
