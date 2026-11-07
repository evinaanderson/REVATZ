import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/backup_info.dart';

/// Mémorise localement l'état de la dernière sauvegarde.
class BackupPrefsDataSource {
  static const _kLast = 'backup_last_at';
  static const _kFolder = 'backup_folder_id';
  static const _kAuto = 'backup_auto';
  static const _kStatus = 'backup_status';

  final SharedPreferences _prefs;
  BackupPrefsDataSource(this._prefs);

  BackupInfo load() {
    final last = _prefs.getString(_kLast);
    final statusName = _prefs.getString(_kStatus);
    return BackupInfo(
      lastBackupAt: last == null ? null : DateTime.tryParse(last),
      driveFolderId: _prefs.getString(_kFolder),
      autoBackup: _prefs.getBool(_kAuto) ?? false,
      status: BackupStatus.values.firstWhere(
        (s) => s.name == statusName,
        orElse: () => BackupStatus.never,
      ),
    );
  }

  Future<void> save(BackupInfo info) async {
    if (info.lastBackupAt != null) {
      await _prefs.setString(_kLast, info.lastBackupAt!.toIso8601String());
    }
    if (info.driveFolderId != null) {
      await _prefs.setString(_kFolder, info.driveFolderId!);
    }
    await _prefs.setBool(_kAuto, info.autoBackup);
    await _prefs.setString(_kStatus, info.status.name);
  }
}
