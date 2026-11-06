import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class UpdateCategory implements UseCase<Category, Category> {
  final CategoryRepository _repository;
  UpdateCategory(this._repository);

  @override
  Future<Result<Category>> call(Category category) {
    if (category.name.trim().isEmpty) {
      return Future.value(
          const Err(ValidationFailure('Le nom de la catégorie est obligatoire')));
    }
    return _repository.update(category.copyWith(name: category.name.trim()));
  }
}
