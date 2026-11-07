import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../../sermon/domain/entities/sermon.dart';
import '../../../sermon/domain/repositories/sermon_repository.dart';
import '../entities/backup_data.dart';
import '../entities/backup_info.dart';
import '../entities/local_backup_file.dart';
import '../repositories/backup_repository.dart';

/// Rassemble les données locales (sauvegarde, export, partage).
Future<Result<BackupData>> _collect(
    SermonRepository sermons, CategoryRepository categories) async {
  final s = await sermons.getAll();
  if (s.failureOrNull != null) return Err(s.failureOrNull!);
  final c = await categories.getAll();
  if (c.failureOrNull != null) return Err(c.failureOrNull!);
  return Success(BackupData(
    sermons: s.valueOrNull!,
    categories: c.valueOrNull!,
    createdAt: DateTime.now(),
  ));
}

/// Importe une sauvegarde : catégories d'abord (les sermons en dépendent).
Future<Result<void>> _import(SermonRepository sermons,
    CategoryRepository categories, BackupData data) async {
  final c = await categories.upsertAll(data.categories);
  if (c.failureOrNull != null) return Err<void>(c.failureOrNull!);
  final s = await sermons.upsertAll(data.sermons);
  if (s.failureOrNull != null) return Err<void>(s.failureOrNull!);
  return const Success<void>(null);
}

// ===================== LOCAL =====================

/// Sauvegarde locale : REVATZ/Sermon_[datetime].zip
class SaveLocalBackup implements UseCase<String, NoParams> {
  final SermonRepository _sermons;
  final CategoryRepository _categories;
  final BackupRepository _backup;
  SaveLocalBackup(this._sermons, this._categories, this._backup);

  @override
  Future<Result<String>> call(NoParams params) async {
    final data = await _collect(_sermons, _categories);
    if (data.failureOrNull != null) return Err(data.failureOrNull!);
    return _backup.saveLocalBackup(data.valueOrNull!);
  }
}

/// Restauration depuis un fichier ZIP choisi par l'utilisateur.
class RestoreFromLocalFile implements UseCase<BackupData, String> {
  final SermonRepository _sermons;
  final CategoryRepository _categories;
  final BackupRepository _backup;
  RestoreFromLocalFile(this._sermons, this._categories, this._backup);

  @override
  Future<Result<BackupData>> call(String zipPath) async {
    final restored = await _backup.restoreFromLocalFile(zipPath);
    final data = restored.valueOrNull;
    if (data == null) return restored;
    final imported = await _import(_sermons, _categories, data);
    if (imported.failureOrNull != null) return Err(imported.failureOrNull!);
    return restored;
  }
}

class ListLocalBackups implements UseCase<List<LocalBackupFile>, NoParams> {
  final BackupRepository _backup;
  ListLocalBackups(this._backup);

  @override
  Future<Result<List<LocalBackupFile>>> call(NoParams params) =>
      _backup.listLocalBackups();
}

/// Export lisible (dossier par catégorie) + sermon.json.
class ExportToZip implements UseCase<String, NoParams> {
  final SermonRepository _sermons;
  final CategoryRepository _categories;
  final BackupRepository _backup;
  ExportToZip(this._sermons, this._categories, this._backup);

  @override
  Future<Result<String>> call(NoParams params) async {
    final data = await _collect(_sermons, _categories);
    if (data.failureOrNull != null) return Err(data.failureOrNull!);
    return _backup.exportToZip(data.valueOrNull!);
  }
}

// ===================== GOOGLE DRIVE =====================

class BackupToDrive implements UseCase<BackupInfo, NoParams> {
  final SermonRepository _sermons;
  final CategoryRepository _categories;
  final BackupRepository _backup;
  BackupToDrive(this._sermons, this._categories, this._backup);

  @override
  Future<Result<BackupInfo>> call(NoParams params) async {
    final data = await _collect(_sermons, _categories);
    if (data.failureOrNull != null) return Err(data.failureOrNull!);
    final result = await _backup.backupToDrive(data.valueOrNull!);
    if (result.isSuccess) {
      final synced = data.valueOrNull!.sermons
          .map((s) => s.copyWith(syncStatus: SyncStatus.synced))
          .toList();
      await _sermons.upsertAll(synced);
    }
    return result;
  }
}

class RestoreFromDrive implements UseCase<BackupData, NoParams> {
  final SermonRepository _sermons;
  final CategoryRepository _categories;
  final BackupRepository _backup;
  RestoreFromDrive(this._sermons, this._categories, this._backup);

  @override
  Future<Result<BackupData>> call(NoParams params) async {
    final restored = await _backup.restoreFromDrive();
    final data = restored.valueOrNull;
    if (data == null) return restored;
    final imported = await _import(_sermons, _categories, data);
    if (imported.failureOrNull != null) return Err(imported.failureOrNull!);
    return restored;
  }
}

class GetBackupInfo implements UseCase<BackupInfo, NoParams> {
  final BackupRepository _backup;
  GetBackupInfo(this._backup);

  @override
  Future<Result<BackupInfo>> call(NoParams params) => _backup.getBackupInfo();
}
