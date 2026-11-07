import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/sermon_repository.dart';

class DeleteSermon implements UseCase<void, String> {
  final SermonRepository _repository;
  DeleteSermon(this._repository);

  @override
  Future<Result<void>> call(String id) => _repository.delete(id);
}
