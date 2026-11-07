import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../category/data/models/category_model.dart';
import '../../../sermon/data/models/sermon_model.dart';
import '../../../sermon/domain/entities/sermon.dart';
import '../../../sermon/domain/entities/reference_photo.dart';
import '../../domain/entities/backup_data.dart';

/// Construit et lit les archives ZIP :
///  1. archive de sauvegarde (Drive) : `data.json` + `photos/`
///  2. export lisible (local) : un dossier par catégorie
class BackupArchiveService {
  static const _jsonName = 'data.json';
  static const _photosDir = 'photos';
  static const _noCategory = 'Sans catégorie';

  // ---------------------------------------------------------------- Drive
  Future<List<int>> buildBackupBytes(BackupData data) async {
    final archive = Archive();
    final sermonsJson = <Map<String, dynamic>>[];

    for (final s in data.sermons) {
      final kept = <ReferencePhoto>[];
      for (final photo in s.photos) {
        final file = File(photo.path);
        if (!await file.exists()) continue;
        final entry = '$_photosDir/${photo.id}${p.extension(photo.path)}';
        final bytes = await file.readAsBytes();
        archive.addFile(ArchiveFile(entry, bytes.length, bytes));
        kept.add(photo.copyWith(path: entry)); // chemin relatif dans l'archive
      }
      sermonsJson.add(SermonModel.fromEntity(s.copyWith(photos: kept)).toJson());
    }

    final json = utf8.encode(jsonEncode({
      'version': 1,
      'createdAt': data.createdAt.toIso8601String(),
      'categories':
          data.categories.map((c) => CategoryModel.fromEntity(c).toJson()).toList(),
      'sermons': sermonsJson,
    }));
    archive.addFile(ArchiveFile(_jsonName, json.length, json));

    final out = ZipEncoder().encode(archive);
    if (out == null) throw const FileSystemException('Création du ZIP impossible');
    return out;
  }

  Future<BackupData> parseBackupBytes(List<int> bytes) async {
    final archive = ZipDecoder().decodeBytes(bytes);
    final jsonFile = archive.findFile(_jsonName);
    if (jsonFile == null) throw const FormatException('data.json manquant');

    final map =
        jsonDecode(utf8.decode(jsonFile.content as List<int>)) as Map<String, dynamic>;

    // Photos extraites dans le dossier de l'app (basename uniquement : sécurité).
    final photosDir = await _photosDirectory();
    for (final f in archive) {
      if (f.isFile && f.name.startsWith('$_photosDir/')) {
        final target = File(p.join(photosDir.path, p.basename(f.name)));
        await target.writeAsBytes(f.content as List<int>, flush: true);
      }
    }

    final categories = (map['categories'] as List)
        .map((j) => CategoryModel.fromJson(j as Map<String, dynamic>))
        .toList();

    final sermons = (map['sermons'] as List)
        .map((j) => SermonModel.fromJson(j as Map<String, dynamic>))
        .map<Sermon>((s) => s.copyWith(
              syncStatus: SyncStatus.synced,
              photos: s.photos
                  .map((ph) =>
                      ph.copyWith(path: p.join(photosDir.path, p.basename(ph.path))))
                  .toList(),
            ))
        .toList();

    return BackupData(
      categories: categories,
      sermons: sermons,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  // ----------------------------------------------------------- Export local
  /// ZIP lisible : `Catégorie/Titre.txt` + `Catégorie/Titre_photos/1.jpg`.
  Future<String> buildExportZip(BackupData data) async {
    final archive = Archive();
    final names = {for (final c in data.categories) c.id: _safe(c.name)};
    final used = <String>{};

    for (final s in data.sermons) {
      final folder = names[s.categoryId] ?? _noCategory;
      var base = _safe(s.title);
      if (!used.add('$folder/$base'.toLowerCase())) {
        base = '$base-${s.id.substring(0, min(6, s.id.length))}';
        used.add('$folder/$base'.toLowerCase());
      }

      final text = utf8.encode(_render(s, folder));
      archive.addFile(ArchiveFile('$folder/$base.txt', text.length, text));

      var i = 1;
      for (final photo in s.photos) {
        final file = File(photo.path);
        if (!await file.exists()) continue;
        final bytes = await file.readAsBytes();
        archive.addFile(ArchiveFile(
            '$folder/${base}_photos/$i${p.extension(photo.path)}',
            bytes.length,
            bytes));
        i++;
      }
    }

    final out = ZipEncoder().encode(archive);
    if (out == null) throw const FileSystemException('Création du ZIP impossible');

    final dir = Directory(p.join((await getApplicationDocumentsDirectory()).path, 'exports'));
    await dir.create(recursive: true);
    final file = File(p.join(dir.path, 'sermons_${_stamp(DateTime.now())}.zip'));
    await file.writeAsBytes(out, flush: true);
    return file.path;
  }

  // --------------------------------------------------------------- Helpers
  Future<Directory> _photosDirectory() async {
    final dir = Directory(
        p.join((await getApplicationDocumentsDirectory()).path, 'sermon_photos'));
    await dir.create(recursive: true);
    return dir;
  }

  String _safe(String name) {
    final cleaned = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    return cleaned.isEmpty ? 'Sans titre' : cleaned;
  }

  String _date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _stamp(DateTime d) =>
      '${_date(d).replaceAll('-', '')}_${d.hour.toString().padLeft(2, '0')}${d.minute.toString().padLeft(2, '0')}';

  String _render(Sermon s, String category) {
    final b = StringBuffer()
      ..writeln(s.title)
      ..writeln('=' * s.title.length)
      ..writeln('Catégorie : $category');
    if (s.preachedAt != null) b.writeln('Prêché le : ${_date(s.preachedAt!)}');
    if (s.tags.isNotEmpty) b.writeln('Tags : ${s.tags.join(', ')}');
    b.writeln('Dernière modification : ${_date(s.updatedAt)}');
    if (s.passages.isNotEmpty) {
      b
        ..writeln()
        ..writeln('TEXTES BIBLIQUES');
      for (final ps in s.passages) {
        b.writeln('- ${ps.reference}');
        if (ps.text.isNotEmpty) b.writeln('  ${ps.text}');
      }
    }
    b
      ..writeln()
      ..writeln('CONTENU')
      ..writeln(s.content);
    return b.toString();
  }
}
