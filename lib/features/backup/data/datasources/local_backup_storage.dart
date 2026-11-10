import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/local_backup_file.dart';
import '../../domain/entities/storage_location.dart';

/// Dossier de sauvegarde « REVATZ ».
///
/// Ordre de préférence (le premier dossier où l'écriture réussit) :
///   1. 0/REVATZ/                 (/storage/emulated/0/REVATZ)
///   2. 0/Download/REVATZ/        (/storage/emulated/0/Download/REVATZ)
///   3. dossier privé de l'application (Android/data/<package>/files/REVATZ)
///      = repli uniquement, signalé à l'utilisateur.
///
/// Les dossiers 1 et 2 demandent l'autorisation « Accès à tous les fichiers »
/// (Android 11 et plus) ou « Stockage » (Android 10 et moins).
class LocalBackupStorage {
  static const folderName = 'REVATZ';
  static const _root = '/storage/emulated/0';

  /// Dossiers publics, par ordre de préférence.
  static const _publicFolders = <String>[
    '$_root/$folderName',
    '$_root/Download/$folderName',
  ];

  bool _askedThisSession = false;

  /// yyyyMMdd_HHmmss
  String stamp([DateTime? now]) {
    final d = now ?? DateTime.now();
    String t(int n) => n.toString().padLeft(2, '0');
    return '${d.year}${t(d.month)}${t(d.day)}_${t(d.hour)}${t(d.minute)}${t(d.second)}';
  }

  /// Dossier utilisé pour écrire.
  ///
  /// [requestAccess] : si aucun dossier public n'est accessible, demande
  /// l'autorisation. [openSettings] : si elle est toujours refusée, ouvre les
  /// réglages de l'application (bouton « Autoriser l'accès »).
  Future<StorageLocation> location({
    bool requestAccess = false,
    bool openSettings = false,
  }) async {
    if (Platform.isAndroid) {
      var dir = await _firstWritablePublic();
      if (dir == null && requestAccess) {
        await _requestPermissions();
        dir = await _firstWritablePublic();
        if (dir == null && openSettings) {
          try {
            await openAppSettings();
          } catch (_) {}
        }
      }
      if (dir != null) return StorageLocation(path: dir.path, isPublic: true);
    }
    final priv = await _privateDirectory();
    return StorageLocation(path: priv.path, isPublic: false);
  }

  /// Écriture : demande l'autorisation une seule fois par session.
  Future<Directory> _writeDirectory() async {
    final ask = !_askedThisSession;
    _askedThisSession = true;
    final loc = await location(requestAccess: ask);
    return Directory(loc.path);
  }

  Future<String> save(String fileName, List<int> bytes) async {
    final dir = await _writeDirectory();
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// Liste les ZIP de TOUS les dossiers connus (0/REVATZ, 0/Download/REVATZ et
  /// dossier privé) : les anciennes sauvegardes restent donc visibles.
  Future<List<LocalBackupFile>> list() async {
    await _writeDirectory(); // peut déclencher la demande d'autorisation
    final folders = <String>{
      if (Platform.isAndroid) ..._publicFolders,
      (await _privateDirectory()).path,
    };

    final byPath = <String, LocalBackupFile>{};
    for (final path in folders) {
      try {
        final dir = Directory(path);
        if (!await dir.exists()) continue;
        await for (final e in dir.list()) {
          if (e is File && p.extension(e.path).toLowerCase() == '.zip') {
            final stat = await e.stat();
            byPath[e.path] = LocalBackupFile(
              path: e.path,
              name: p.basename(e.path),
              sizeBytes: stat.size,
              modifiedAt: stat.modified,
            );
          }
        }
      } catch (_) {
        // dossier illisible (autorisation manquante) : on l'ignore
      }
    }
    final files = byPath.values.toList()
      ..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return files;
  }

  // ------------------------------------------------------------ Internes
  Future<Directory?> _firstWritablePublic() async {
    for (final path in _publicFolders) {
      final dir = Directory(path);
      if (await _isWritable(dir)) return dir;
    }
    return null;
  }

  Future<void> _requestPermissions() async {
    try {
      // Android 11 et plus : « Accès à tous les fichiers »
      await Permission.manageExternalStorage.request();
      if (await _firstWritablePublic() != null) return;
      // Android 10 et moins : « Stockage »
      await Permission.storage.request();
    } catch (_) {}
  }

  Future<Directory> _privateDirectory() async {
    Directory? base;
    if (Platform.isAndroid) base = await getExternalStorageDirectory();
    base ??= await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, folderName));
    await dir.create(recursive: true);
    return dir;
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
