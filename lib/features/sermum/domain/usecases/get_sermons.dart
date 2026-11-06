import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/sermon.dart';
import '../repositories/sermon_repository.dart';

class GetSermons implements UseCase<List<Sermon>, NoParams> {
  final SermonRepository _repository;
  GetSermons(this._repository);

  @override
  Future<Result<List<Sermon>>> call(NoParams params) => _repository.getAll();
}

/// Flux réactif de tous les sermons.
class WatchSermons {
  final SermonRepository _repository;
  WatchSermons(this._repository);

  Stream<List<Sermon>> call() => _repository.watchAll();
}
