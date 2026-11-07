import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../../../core/services/photo_storage_service.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/sermon.dart';
import '../../domain/usecases/add_sermon.dart';
import '../../domain/usecases/delete_sermon.dart';
import '../../domain/usecases/get_sermons.dart';
import '../../domain/usecases/update_sermon.dart';

/// Flux réactif : l'écran se met à jour tout seul après chaque modification.
final sermonsStreamProvider =
    StreamProvider<List<Sermon>>((ref) => sl<WatchSermons>()());

final sermonSearchQueryProvider = StateProvider<String>((ref) => '');

/// null = toutes les catégories.
final selectedCategoryIdProvider = StateProvider<String?>((ref) => null);

/// Liste filtrée (catégorie + recherche) à partir du flux complet.
final filteredSermonsProvider = Provider<AsyncValue<List<Sermon>>>((ref) {
  final all = ref.watch(sermonsStreamProvider);
  final query = ref.watch(sermonSearchQueryProvider).trim().toLowerCase();
  final categoryId = ref.watch(selectedCategoryIdProvider);

  return all.whenData((list) => list.where((s) {
        if (categoryId != null && s.categoryId != categoryId) return false;
        if (query.isEmpty) return true;
        return s.title.toLowerCase().contains(query) ||
            s.content.toLowerCase().contains(query) ||
            s.tags.any((t) => t.toLowerCase().contains(query)) ||
            s.passages.any((p) =>
                p.reference.toLowerCase().contains(query) ||
                p.text.toLowerCase().contains(query));
      }).toList());
});

final sermonByIdProvider = Provider.family<Sermon?, String>((ref, id) {
  final list = ref.watch(sermonsStreamProvider).valueOrNull ?? const <Sermon>[];
  for (final s in list) {
    if (s.id == id) return s;
  }
  return null;
});

class SermonActions {
  final AddSermon _add;
  final UpdateSermon _update;
  final DeleteSermon _delete;
  SermonActions(this._add, this._update, this._delete);

  Future<Result<Sermon>> add(AddSermonParams params) => _add(params);
  Future<Result<Sermon>> update(Sermon sermon) => _update(sermon);
  Future<Result<void>> delete(String id) => _delete(id);
}

final sermonActionsProvider =
    Provider<SermonActions>((ref) => SermonActions(sl(), sl(), sl()));

final photoStorageProvider =
    Provider<PhotoStorageService>((ref) => PhotoStorageService(sl<IdGenerator>()));
