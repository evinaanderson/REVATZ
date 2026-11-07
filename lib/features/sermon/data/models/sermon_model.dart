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
    super.photo,
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
        photo: s.photo,
        tags: s.tags,
        preachedAt: s.preachedAt,
        syncStatus: s.syncStatus,
      );

  // ---------- Drift ----------
  // La colonne `photosJson` est conservée (aucune migration) :
  // elle contient désormais une liste de 0 ou 1 photo.
  factory SermonModel.fromRow(SermonRow r) {
    final photos = jsonDecode(r.photosJson) as List;
    return SermonModel(
      id: r.id,
      title: r.title,
      categoryId: r.categoryId,
      content: r.content,
      passages: _passagesFromList(jsonDecode(r.passagesJson) as List),
      photo: photos.isEmpty
          ? null
          : _photoFromJson(photos.first as Map<String, dynamic>),
      tags: (jsonDecode(r.tagsJson) as List).map((e) => e as String).toList(),
      preachedAt: r.preachedAt,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      syncStatus:
          SyncStatus.values[r.syncStatus.clamp(0, SyncStatus.values.length - 1)],
    );
  }

  SermonsCompanion toCompanion() {
    final p = photo;
    return SermonsCompanion(
      id: Value(id),
      title: Value(title),
      categoryId: Value(categoryId),
      content: Value(content),
      passagesJson: Value(jsonEncode(_passagesToJson(passages))),
      photosJson: Value(jsonEncode(p == null ? <Map<String, dynamic>>[] : [_photoToJson(p)])),
      tagsJson: Value(jsonEncode(tags)),
      preachedAt: Value(preachedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus.index),
    );
  }

  // ---------- JSON (fichier sermon.json) ----------
  /// Lit le format 2.0 (`photo`) et l'ancien format (`photos`, première photo).
  factory SermonModel.fromJson(Map<String, dynamic> j) {
    ReferencePhoto? photo;
    final single = j['photo'];
    final legacy = j['photos'];
    if (single is Map<String, dynamic>) {
      photo = _photoFromJson(single);
    } else if (legacy is List && legacy.isNotEmpty) {
      photo = _photoFromJson(legacy.first as Map<String, dynamic>);
    }
    return SermonModel(
      id: j['id'] as String,
      title: j['title'] as String,
      categoryId: j['categoryId'] as String,
      content: (j['content'] as String?) ?? '',
      passages: _passagesFromList((j['passages'] as List?) ?? const []),
      photo: photo,
      tags: ((j['tags'] as List?) ?? const []).map((e) => e as String).toList(),
      preachedAt:
          j['preachedAt'] == null ? null : DateTime.parse(j['preachedAt'] as String),
      createdAt: DateTime.parse(j['createdAt'] as String),
      updatedAt: DateTime.parse(j['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final p = photo;
    return {
      'id': id,
      'title': title,
      'categoryId': categoryId,
      'content': content,
      'passages': _passagesToJson(passages),
      'photo': p == null ? null : _photoToJson(p),
      'tags': tags,
      'preachedAt': preachedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// ---------- Helpers JSON ----------
List<Map<String, dynamic>> _passagesToJson(List<BiblePassage> list) =>
    list.map((p) => {'reference': p.reference, 'text': p.text}).toList();

List<BiblePassage> _passagesFromList(List list) => list
    .map((e) => BiblePassage(
          reference: e['reference'] as String,
          text: (e['text'] as String?) ?? '',
        ))
    .toList();

Map<String, dynamic> _photoToJson(ReferencePhoto p) =>
    {'id': p.id, 'path': p.path, 'caption': p.caption};

ReferencePhoto _photoFromJson(Map<String, dynamic> e) => ReferencePhoto(
      id: e['id'] as String,
      path: e['path'] as String,
      caption: e['caption'] as String?,
    );
