import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/sermon.dart';
import '../repositories/sermon_repository.dart';

class GetSermon implements UseCase<Sermon, String> {
  final SermonRepository _repository;
  GetSermon(this._repository);

  @override
  Future<Result<Sermon>> call(String id) => _repository.getById(id);
}
