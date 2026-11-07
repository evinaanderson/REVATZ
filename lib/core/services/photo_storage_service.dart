import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/sermon/domain/entities/reference_photo.dart';
import '../utils/id_generator.dart';

/// Copie les photos choisies dans le dossier privé de l'app (`sermon_photos`),
/// pour qu'elles survivent à la suppression de l'original dans la galerie
/// et puissent être incluses dans les sauvegardes.
class PhotoStorageService {
  final IdGenerator _ids;
  PhotoStorageService(this._ids);

  Future<ReferencePhoto> importPhoto(String sourcePath) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'sermon_photos'));
    await dir.create(recursive: true);

    final id = _ids.generate();
    final ext = p.extension(sourcePath).isEmpty ? '.jpg' : p.extension(sourcePath);
    final target = p.join(dir.path, '$id$ext');
    await File(sourcePath).copy(target);
    return ReferencePhoto(id: id, path: target);
  }

  Future<void> deleteFile(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {/* sans importance */}
  }
}
