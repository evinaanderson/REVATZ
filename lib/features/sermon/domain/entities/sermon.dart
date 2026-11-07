import 'bible_passage.dart';
import 'reference_photo.dart';

/// État de synchronisation avec Google Drive.
enum SyncStatus { pending, synced }

/// Entité immuable : pour modifier, utilisez [copyWith].
/// Un sermon a au plus UNE photo de référence.
class Sermon {
  final String id;
  final String title;
  final List<BiblePassage> passages;
  final String content;
  final ReferencePhoto? photo;
  final String categoryId;
  final List<String> tags;
  final DateTime? preachedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SyncStatus syncStatus;

  const Sermon({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.passages = const [],
    this.content = '',
    this.photo,
    this.tags = const [],
    this.preachedAt,
    this.syncStatus = SyncStatus.pending,
  });

  /// [clearPhoto] / [clearPreachedAt] permettent de remettre le champ à vide.
  Sermon copyWith({
    String? title,
    List<BiblePassage>? passages,
    String? content,
    ReferencePhoto? photo,
    bool clearPhoto = false,
    String? categoryId,
    List<String>? tags,
    DateTime? preachedAt,
    bool clearPreachedAt = false,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) =>
      Sermon(
        id: id,
        title: title ?? this.title,
        passages: passages ?? this.passages,
        content: content ?? this.content,
        photo: clearPhoto ? null : (photo ?? this.photo),
        categoryId: categoryId ?? this.categoryId,
        tags: tags ?? this.tags,
        preachedAt: clearPreachedAt ? null : (preachedAt ?? this.preachedAt),
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );

  @override
  bool operator ==(Object other) => other is Sermon && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
