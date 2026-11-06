import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/sermon.dart';
import '../repositories/sermon_repository.dart';

class SearchSermons implements UseCase<List<Sermon>, String> {
  final SermonRepository _repository;
  SearchSermons(this._repository);

  @override
  Future<Result<List<Sermon>>> call(String query) {
    final q = query.trim();
    return q.isEmpty ? _repository.getAll() : _repository.search(q);
  }
}
