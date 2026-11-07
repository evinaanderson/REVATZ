import 'dart:typed_data';

import 'package:googleapis/drive/v3.dart' as drive;

import '../../../user/data/datasources/google_auth_datasource.dart';
import 'drive_error_mapper.dart';

class DriveUploadResult {
  final String folderId;
  final DateTime modifiedAt;
  const DriveUploadResult(this.folderId, this.modifiedAt);
}

/// Un dossier « GestionSermons » contenant un seul fichier `sermons_backup.zip`,
/// mis à jour sur place à chaque sauvegarde (pas de doublons).
class DriveDataSource {
  static const _folderName = 'GestionSermons';
  static const _fileName = 'sermons_backup.zip';
  static const _folderMime = 'application/vnd.google-apps.folder';

  final GoogleAuthDataSource _auth;
  DriveDataSource(this._auth);

  Future<DriveUploadResult> uploadBackup(List<int> bytes) async {
    final api = await _auth.getDriveApi();
    final folderId = await _findOrCreateFolder(api);
    final existingId = await _findBackupFileId(api, folderId);
    final media = drive.Media(Stream<List<int>>.value(bytes), bytes.length);

    final drive.File result;
    if (existingId == null) {
      result = await api.files.create(
        drive.File()
          ..name = _fileName
          ..mimeType = 'application/zip'
          ..parents = [folderId],
        uploadMedia: media,
        $fields: 'id,modifiedTime',
      );
    } else {
      result = await api.files.update(
        drive.File(),
        existingId,
        uploadMedia: media,
        $fields: 'id,modifiedTime',
      );
    }
    return DriveUploadResult(folderId, result.modifiedTime ?? DateTime.now());
  }

  Future<List<int>> downloadBackup() async {
    final api = await _auth.getDriveApi();
    final folderId = await _findFolder(api);
    if (folderId == null) throw const BackupNotFoundException();
    final fileId = await _findBackupFileId(api, folderId);
    if (fileId == null) throw const BackupNotFoundException();

    final media = await api.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final builder = BytesBuilder(copy: false);
    await for (final chunk in media.stream) {
      builder.add(chunk);
    }
    return builder.takeBytes();
  }

  Future<String?> _findFolder(drive.DriveApi api) async {
    final res = await api.files.list(
      q: "mimeType='$_folderMime' and name='$_folderName' and trashed=false",
      spaces: 'drive',
      pageSize: 1,
      $fields: 'files(id)',
    );
    final files = res.files;
    return (files == null || files.isEmpty) ? null : files.first.id;
  }

  Future<String> _findOrCreateFolder(drive.DriveApi api) async {
    final existing = await _findFolder(api);
    if (existing != null) return existing;
    final created = await api.files.create(
      drive.File()
        ..name = _folderName
        ..mimeType = _folderMime,
      $fields: 'id',
    );
    return created.id!;
  }

  Future<String?> _findBackupFileId(drive.DriveApi api, String folderId) async {
    final res = await api.files.list(
      q: "'$folderId' in parents and name='$_fileName' and trashed=false",
      spaces: 'drive',
      pageSize: 1,
      $fields: 'files(id)',
    );
    final files = res.files;
    return (files == null || files.isEmpty) ? null : files.first.id;
  }
}
