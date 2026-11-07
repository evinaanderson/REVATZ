import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/local_backup_file.dart';

/// Gère le dossier de sauvegarde « REVATZ ».
///
/// Emplacement visé (Android) : /storage/emulated/0/REVATZ  (= « 0/REVATZ »).
/// Il nécessite l'autorisation « Accès à tous les fichiers » (Android 11+)
/// ou « Stockage » (Android 10 et moins). Si elle est refusée, on bascule
/// automatiquement sur le dossier propre à l'application.
class LocalBackupStorage {
  static const folderName = 'REVATZ';
  static const _androidRoot = '/storage/emulated/0';

  /// yyyyMMdd_HHmmss
  String stamp([DateTime? now]) {
    final d = now ?? DateTime.now();
    String t(int n) => n.toString().padLeft(2, '0');
    return '${d.year}${t(d.month)}${t(d.day)}_${t(d.hour)}${t(d.minute)}${t(d.second)}';
  }

  Future<Directory> directory() async {
    if (Platform.isAndroid) {
      if (await _hasStorageAccess()) {
        final shared = Directory(p.join(_androidRoot, folderName));
        if (await _isWritable(shared)) return shared;
      }
      // Repli : Android/data/<package>/files/REVATZ
      final ext = await getExternalStorageDirectory();
      if (ext != null) {
        final appDir = Directory(p.join(ext.path, folderName));
        if (await _isWritable(appDir)) return appDir;
      }
    }
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, folderName));
    await dir.create(recursive: true);
    return dir;
  }

  Future<String> save(String fileName, List<int> bytes) async {
    final dir = await directory();
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<List<LocalBackupFile>> list() async {
    final dir = await directory();
    final files = <LocalBackupFile>[];
    await for (final e in dir.list()) {
      if (e is File && p.extension(e.path).toLowerCase() == '.zip') {
        final stat = await e.stat();
        files.add(LocalBackupFile(
          path: e.path,
          name: p.basename(e.path),
          sizeBytes: stat.size,
          modifiedAt: stat.modified,
        ));
      }
    }
    files.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return files;
  }

  Future<bool> _hasStorageAccess() async {
    try {
      if (await Permission.manageExternalStorage.isGranted) return true;
      if (await Permission.storage.isGranted) return true;
      if (await Permission.manageExternalStorage.request().isGranted) return true;
      return await Permission.storage.request().isGranted;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _isWritable(Directory dir) async {
    try {
      await dir.create(recursive: true);
      final probe = File(p.join(dir.path, '.probe'));
      await probe.writeAsString('ok');
      await probe.delete();
      return true;
    } catch (_) {
      return false;
    }
  }
}
