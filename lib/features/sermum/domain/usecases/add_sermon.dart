import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/id_generator.dart';
import '../entities/bible_passage.dart';
import '../entities/reference_photo.dart';
import '../entities/sermon.dart';
import '../repositories/sermon_repository.dart';

class AddSermonParams {
  final String title;
  final String categoryId;
  final List<BiblePassage> passages;
  final String content;
  final List<ReferencePhoto> photos;
  final List<String> tags;
  final DateTime? preachedAt;

  const AddSermonParams({
    required this.title,
    required this.categoryId,
    this.passages = const [],
    this.content = '',
    this.photos = const [],
    this.tags = const [],
    this.preachedAt,
  });
}

class AddSermon implements UseCase<Sermon, AddSermonParams> {
  final SermonRepository _repository;
  final IdGenerator _ids;
  AddSermon(this._repository, this._ids);

  @override
  Future<Result<Sermon>> call(AddSermonParams p) {
    if (p.title.trim().isEmpty) {
      return Future.value(const Err(ValidationFailure('Le titre est obligatoire')));
    }
    if (p.categoryId.trim().isEmpty) {
      return Future.value(const Err(ValidationFailure('Choisissez une catégorie')));
    }
    final now = DateTime.now();
    return _repository.add(Sermon(
      id: _ids.generate(),
      title: p.title.trim(),
      categoryId: p.categoryId,
      passages: p.passages,
      content: p.content,
      photos: p.photos,
      tags: p.tags,
      preachedAt: p.preachedAt,
      createdAt: now,
      updatedAt: now,
    ));
  }
}
