import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/sermon.dart';
import '../repositories/sermon_repository.dart';

class UpdateSermon implements UseCase<Sermon, Sermon> {
  final SermonRepository _repository;
  UpdateSermon(this._repository);

  @override
  Future<Result<Sermon>> call(Sermon sermon) {
    if (sermon.title.trim().isEmpty) {
      return Future.value(const Err(ValidationFailure('Le titre est obligatoire')));
    }
    return _repository.update(sermon.copyWith(
      title: sermon.title.trim(),
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending, // à re-synchroniser
    ));
  }
}
