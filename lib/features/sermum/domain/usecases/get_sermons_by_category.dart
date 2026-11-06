import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/sermon.dart';
import '../repositories/sermon_repository.dart';

class GetSermonsByCategory implements UseCase<List<Sermon>, String> {
  final SermonRepository _repository;
  GetSermonsByCategory(this._repository);

  @override
  Future<Result<List<Sermon>>> call(String categoryId) =>
      _repository.getByCategory(categoryId);
}
