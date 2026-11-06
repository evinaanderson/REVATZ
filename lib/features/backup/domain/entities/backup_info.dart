enum BackupStatus { never, inProgress, success, failed }

class BackupInfo {
  final DateTime? lastBackupAt;
  final String? driveFolderId;
  final bool autoBackup;
  final BackupStatus status;

  const BackupInfo({
    this.lastBackupAt,
    this.driveFolderId,
    this.autoBackup = false,
    this.status = BackupStatus.never,
  });

  BackupInfo copyWith({
    DateTime? lastBackupAt,
    String? driveFolderId,
    bool? autoBackup,
    BackupStatus? status,
  }) =>
      BackupInfo(
        lastBackupAt: lastBackupAt ?? this.lastBackupAt,
        driveFolderId: driveFolderId ?? this.driveFolderId,
        autoBackup: autoBackup ?? this.autoBackup,
        status: status ?? this.status,
      );
}
