import '../../../../core/result/result.dart';
import '../entities/category.dart';

abstract class CategoryRepository {
  Future<Result<Category>> add(Category category);
  Future<Result<Category>> update(Category category);
  Future<Result<void>> delete(String id);
  Future<Result<List<Category>>> getAll();
  Future<Result<Category>> getById(String id);
  Future<Result<void>> upsertAll(List<Category> categories);
  Stream<List<Category>> watchAll();
}
