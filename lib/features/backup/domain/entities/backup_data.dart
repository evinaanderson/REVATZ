import '../../../category/domain/entities/category.dart';
import '../../../sermon/domain/entities/sermon.dart';

/// Contenu complet d'une sauvegarde.
class BackupData {
  final List<Category> categories;
  final List<Sermon> sermons;
  final DateTime createdAt;

  const BackupData({
    required this.categories,
    required this.sermons,
    required this.createdAt,
  });
}
