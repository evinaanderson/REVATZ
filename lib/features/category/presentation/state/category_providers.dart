import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../../../injection_container.dart';
import '../../../sermon/domain/entities/sermon.dart';
import '../../../sermon/presentation/state/sermon_providers.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/add_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/update_category.dart';

final categoriesStreamProvider =
    StreamProvider<List<Category>>((ref) => sl<WatchCategories>()());

final categoriesMapProvider = Provider<Map<String, Category>>((ref) {
  final list = ref.watch(categoriesStreamProvider).valueOrNull ?? const <Category>[];
  return {for (final c in list) c.id: c};
});

final sermonCountByCategoryProvider = Provider<Map<String, int>>((ref) {
  final sermons = ref.watch(sermonsStreamProvider).valueOrNull ?? const <Sermon>[];
  final counts = <String, int>{};
  for (final s in sermons) {
    counts[s.categoryId] = (counts[s.categoryId] ?? 0) + 1;
  }
  return counts;
});

class CategoryActions {
  final AddCategory _add;
  final UpdateCategory _update;
  final DeleteCategory _delete;
  CategoryActions(this._add, this._update, this._delete);

  Future<Result<Category>> add(String name, int? colorValue) =>
      _add(AddCategoryParams(name: name, colorValue: colorValue));

  Future<Result<Category>> update(Category category) => _update(category);

  Future<Result<void>> delete(String id) => _delete(id);
}

final categoryActionsProvider = Provider<CategoryActions>(
    (ref) => CategoryActions(sl(), sl(), sl()));
