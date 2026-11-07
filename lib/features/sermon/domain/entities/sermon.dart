import 'bible_passage.dart';
import 'reference_photo.dart';

/// État de synchronisation avec Google Drive.
enum SyncStatus { pending, synced }

/// Entité immuable : pour modifier, utilisez [copyWith].
class Sermon {
  final String id;
  final String title;
  final List<BiblePassage> passages;
  final String content;
  final List<ReferencePhoto> photos;
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
    this.photos = const [],
    this.tags = const [],
    this.preachedAt,
    this.syncStatus = SyncStatus.pending,
  });

  Sermon copyWith({
    String? title,
    List<BiblePassage>? passages,
    String? content,
    List<ReferencePhoto>? photos,
    String? categoryId,
    List<String>? tags,
    DateTime? preachedAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) =>
      Sermon(
        id: id,
        title: title ?? this.title,
        passages: passages ?? this.passages,
        content: content ?? this.content,
        photos: photos ?? this.photos,
        categoryId: categoryId ?? this.categoryId,
        tags: tags ?? this.tags,
        preachedAt: preachedAt ?? this.preachedAt,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );

  @override
  bool operator ==(Object other) => other is Sermon && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
