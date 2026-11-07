import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../category/data/models/category_model.dart';
import '../../../sermon/data/models/sermon_model.dart';
import '../../../sermon/domain/entities/reference_photo.dart';
import '../../../sermon/domain/entities/sermon.dart';
import '../../domain/entities/backup_data.dart';

/// Construit et lit les archives ZIP de REVATZ.
///
/// Deux formats, mêmes données (`sermon.json`) :
///  1. Sauvegarde (local + Drive) : `sermon.json` + `photos/<id>.<ext>`
///  2. Export lisible : `<Catégorie>/<Titre>.txt` (+ photo) + `sermon.json`
///
/// Dans `sermon.json`, le chemin de la photo est RELATIF à la racine du ZIP,
/// ce qui permet la restauration sur un autre téléphone.
class BackupArchiveService {
  static const jsonName = 'sermon.json';
  static const _legacyJsonName = 'data.json'; // anciennes sauvegardes Drive
  static const _photosDir = 'photos';
  static const _noCategory = 'Sans catégorie';
  static const formatVersion = 2;

  // ------------------------------------------------------ Sauvegarde (ZIP)
  Future<List<int>> buildBackupBytes(BackupData data) async {
    final archive = Archive();
    final sermonsJson = <Map<String, dynamic>>[];

    for (final s in data.sermons) {
      ReferencePhoto? kept;
      final photo = s.photo;
      if (photo != null) {
        final file = File(photo.path);
        if (await file.exists()) {
          final entry = '$_photosDir/${photo.id}${p.extension(photo.path)}';
          final bytes = await file.readAsBytes();
          archive.addFile(ArchiveFile(entry, bytes.length, bytes));
          kept = photo.copyWith(path: entry);
        }
      }
      sermonsJson.add(
          SermonModel.fromEntity(s.copyWith(photo: kept, clearPhoto: kept == null))
              .toJson());
    }

    _addJson(archive, data, sermonsJson);
    return _encode(archive);
  }

  // --------------------------------------------------------- Export lisible
  Future<List<int>> buildExportBytes(BackupData data) async {
    final archive = Archive();
    final names = {for (final c in data.categories) c.id: _safe(c.name)};
    final used = <String>{};
    final sermonsJson = <Map<String, dynamic>>[];

    for (final s in data.sermons) {
      final folder = names[s.categoryId] ?? _noCategory;
      var base = _safe(s.title);
      if (!used.add('$folder/$base'.toLowerCase())) {
        base = '$base-${s.id.substring(0, min(6, s.id.length))}';
        used.add('$folder/$base'.toLowerCase());
      }

      final text = utf8.encode(_render(s, folder));
      archive.addFile(ArchiveFile('$folder/$base.txt', text.length, text));

      ReferencePhoto? kept;
      final photo = s.photo;
      if (photo != null) {
        final file = File(photo.path);
        if (await file.exists()) {
          final entry = '$folder/$base${p.extension(photo.path)}';
          final bytes = await file.readAsBytes();
          archive.addFile(ArchiveFile(entry, bytes.length, bytes));
          kept = photo.copyWith(path: entry); // chemin de la photo dans le ZIP
        }
      }
      sermonsJson.add(
          SermonModel.fromEntity(s.copyWith(photo: kept, clearPhoto: kept == null))
              .toJson());
    }

    _addJson(archive, data, sermonsJson);
    return _encode(archive);
  }

  // ------------------------------------------------------------ Restauration
  /// Lit `sermon.json`, extrait les photos dans le dossier de l'app et
  /// remplace leurs chemins par les chemins locaux.
  Future<BackupData> parseBackupBytes(
    List<int> bytes, {
    required SyncStatus status,
  }) async {
    final archive = ZipDecoder().decodeBytes(bytes);
    final jsonFile =
        archive.findFile(jsonName) ?? archive.findFile(_legacyJsonName);
    if (jsonFile == null) {
      throw const FormatException('sermon.json introuvable dans le ZIP');
    }

    final map =
        jsonDecode(utf8.decode(jsonFile.content as List<int>)) as Map<String, dynamic>;
    final photosDir = await _photosDirectory();

    final categories = ((map['categories'] as List?) ?? const [])
        .map((j) => CategoryModel.fromJson(j as Map<String, dynamic>))
        .toList();

    final sermons = <Sermon>[];
    for (final j in (map['sermons'] as List? ?? const [])) {
      Sermon s = SermonModel.fromJson(j as Map<String, dynamic>);
      final photo = s.photo;
      if (photo != null) {
        final entry = archive.findFile(photo.path.replaceAll('\\', '/'));
        if (entry != null && entry.isFile) {
          final target =
              p.join(photosDir.path, '${photo.id}${p.extension(photo.path)}');
          await File(target).writeAsBytes(entry.content as List<int>, flush: true);
          s = s.copyWith(photo: photo.copyWith(path: target));
        } else {
          s = s.copyWith(clearPhoto: true); // photo absente du ZIP
        }
      }
      sermons.add(s.copyWith(syncStatus: status));
    }

    return BackupData(
      categories: categories,
      sermons: sermons,
      createdAt:
          DateTime.tryParse(map['exportedAt'] as String? ?? map['createdAt'] as String? ?? '') ??
              DateTime.now(),
    );
  }

  // --------------------------------------------------------------- Helpers
  void _addJson(Archive archive, BackupData data, List<Map<String, dynamic>> sermons) {
    final json = utf8.encode(const JsonEncoder.withIndent('  ').convert({
      'app': 'REVATZ',
      'version': formatVersion,
      'exportedAt': data.createdAt.toIso8601String(),
      'categories':
          data.categories.map((c) => CategoryModel.fromEntity(c).toJson()).toList(),
      'sermons': sermons,
    }));
    archive.addFile(ArchiveFile(jsonName, json.length, json));
  }

  List<int> _encode(Archive archive) {
    final out = ZipEncoder().encode(archive);
    if (out == null) throw const FileSystemException('Création du ZIP impossible');
    return out;
  }

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
