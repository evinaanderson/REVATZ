import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../../../core/services/photo_storage_service.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/sermon.dart';
import '../../domain/usecases/add_sermon.dart';
import '../../domain/usecases/build_sermon_share.dart';
import '../../domain/usecases/delete_sermon.dart';
import '../../domain/usecases/get_sermons.dart';
import '../../domain/services/rich_content.dart';
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
            RichContent.toSearchText(s.content).toLowerCase().contains(query) ||
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

final photoStorageProvider =
    Provider<PhotoStorageService>((ref) => PhotoStorageService(sl<IdGenerator>()));

/// Construit le texte de partage (titre en gras, contenu, versets).
final buildSermonShareProvider =
    Provider<BuildSermonShare>((ref) => const BuildSermonShare());

class SermonActions {
  final AddSermon _add;
  final UpdateSermon _update;
  final DeleteSermon _delete;
  final PhotoStorageService _photos;
  SermonActions(this._add, this._update, this._delete, this._photos);

  Future<Result<Sermon>> add(AddSermonParams params) => _add(params);
  Future<Result<Sermon>> update(Sermon sermon) => _update(sermon);

  /// Supprime le sermon puis son fichier photo.
  Future<Result<void>> delete(Sermon sermon) async {
    final result = await _delete(sermon.id);
    final photo = sermon.photo;
    if (result.isSuccess && photo != null) {
      await _photos.deleteFile(photo.path);
    }
    return result;
  }
}

final sermonActionsProvider = Provider<SermonActions>(
    (ref) => SermonActions(sl(), sl(), sl(), ref.read(photoStorageProvider)));
