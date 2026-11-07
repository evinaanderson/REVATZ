import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/bible_passage.dart';
import '../../domain/entities/reference_photo.dart';
import '../../domain/entities/sermon.dart';

class SermonModel extends Sermon {
  const SermonModel({
    required super.id,
    required super.title,
    required super.categoryId,
    required super.createdAt,
    required super.updatedAt,
    super.passages,
    super.content,
    super.photos,
    super.tags,
    super.preachedAt,
    super.syncStatus,
  });

  factory SermonModel.fromEntity(Sermon s) => SermonModel(
        id: s.id,
        title: s.title,
        categoryId: s.categoryId,
        createdAt: s.createdAt,
        updatedAt: s.updatedAt,
        passages: s.passages,
        content: s.content,
        photos: s.photos,
        tags: s.tags,
        preachedAt: s.preachedAt,
        syncStatus: s.syncStatus,
      );

  // ---------- Drift ----------
  factory SermonModel.fromRow(SermonRow r) => SermonModel(
        id: r.id,
        title: r.title,
        categoryId: r.categoryId,
        content: r.content,
        passages: _decodePassages(r.passagesJson),
        photos: _decodePhotos(r.photosJson),
        tags: _decodeTags(r.tagsJson),
        preachedAt: r.preachedAt,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        syncStatus: SyncStatus.values[r.syncStatus.clamp(0, SyncStatus.values.length - 1)],
      );

  SermonsCompanion toCompanion() => SermonsCompanion(
        id: Value(id),
        title: Value(title),
        categoryId: Value(categoryId),
        content: Value(content),
        passagesJson: Value(jsonEncode(_passagesToJson(passages))),
        photosJson: Value(jsonEncode(_photosToJson(photos))),
        tagsJson: Value(jsonEncode(tags)),
        preachedAt: Value(preachedAt),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
        syncStatus: Value(syncStatus.index),
      );

  // ---------- JSON (sauvegarde) ----------
  factory SermonModel.fromJson(Map<String, dynamic> j) => SermonModel(
        id: j['id'] as String,
        title: j['title'] as String,
        categoryId: j['categoryId'] as String,
        content: (j['content'] as String?) ?? '',
        passages: _decodePassages(jsonEncode(j['passages'] ?? [])),
        photos: _decodePhotos(jsonEncode(j['photos'] ?? [])),
        tags: _decodeTags(jsonEncode(j['tags'] ?? [])),
        preachedAt: j['preachedAt'] == null
            ? null
            : DateTime.parse(j['preachedAt'] as String),
        createdAt: DateTime.parse(j['createdAt'] as String),
        updatedAt: DateTime.parse(j['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'categoryId': categoryId,
        'content': content,
        'passages': _passagesToJson(passages),
        'photos': _photosToJson(photos),
        'tags': tags,
        'preachedAt': preachedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

// ---------- Helpers JSON ----------
List<Map<String, dynamic>> _passagesToJson(List<BiblePassage> list) =>
    list.map((p) => {'reference': p.reference, 'text': p.text}).toList();

List<Map<String, dynamic>> _photosToJson(List<ReferencePhoto> list) => list
    .map((p) => {'id': p.id, 'path': p.path, 'caption': p.caption})
    .toList();

List<BiblePassage> _decodePassages(String source) =>
    (jsonDecode(source) as List)
        .map((e) => BiblePassage(
              reference: e['reference'] as String,
              text: (e['text'] as String?) ?? '',
            ))
        .toList();

List<ReferencePhoto> _decodePhotos(String source) => (jsonDecode(source) as List)
    .map((e) => ReferencePhoto(
          id: e['id'] as String,
          path: e['path'] as String,
          caption: e['caption'] as String?,
        ))
    .toList();

List<String> _decodeTags(String source) =>
    (jsonDecode(source) as List).map((e) => e as String).toList();
