import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategories implements UseCase<List<Category>, NoParams> {
  final CategoryRepository _repository;
  GetCategories(this._repository);

  @override
  Future<Result<List<Category>>> call(NoParams params) => _repository.getAll();
}

class WatchCategories {
  final CategoryRepository _repository;
  WatchCategories(this._repository);

  Stream<List<Category>> call() => _repository.watchAll();
}
