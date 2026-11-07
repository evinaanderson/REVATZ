import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/navigation_providers.dart';
import '../../../../core/presentation/widgets/async_value_view.dart';
import '../../../../core/presentation/widgets/dialogs.dart';
import '../../../../core/presentation/widgets/empty_state.dart';
import '../../../sermon/presentation/state/sermon_providers.dart';
import '../../domain/entities/category.dart';
import '../state/category_providers.dart';
import '../widgets/category_dialog.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  Future<void> _delete(BuildContext context, WidgetRef ref, Category c) async {
    final ok = await confirmDialog(
      context,
      title: 'Supprimer « ${c.name} » ?',
      message: 'Cette action est définitive.',
      confirmLabel: 'Supprimer',
      destructive: true,
    );
    if (!ok) return;
    final result = await ref.read(categoryActionsProvider).delete(c.id);
    if (!context.mounted) return;
    result.when<void>(
      success: (_) => showMessage(context, 'Catégorie supprimée'),
      failure: (f) => showMessage(context, f.message),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesStreamProvider);
    final counts = ref.watch(sermonCountByCategoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Catégories')),
      body: AsyncValueView<List<Category>>(
        value: categories,
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.folder_open,
              title: 'Aucune catégorie',
              message: 'Créez des catégories pour classer vos sermons '
                  '(ex. Foi, Famille, Évangélisation).',
              action: FilledButton.icon(
                onPressed: () => showCategoryDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Créer une catégorie'),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final c = list[i];
              final n = counts[c.id] ?? 0;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(c.colorValue ?? 0xFF455A64),
                    child: const Icon(Icons.folder, color: Colors.white),
                  ),
                  title: Text(c.name),
                  subtitle: Text(n == 0 ? 'Aucun sermon' : '$n sermon${n > 1 ? 's' : ''}'),
                  onTap: () {
                    // Filtre la liste des sermons et bascule sur l'onglet Sermons.
                    ref.read(selectedCategoryIdProvider.notifier).state = c.id;
                    ref.read(homeTabIndexProvider.notifier).state = 0;
                  },
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') showCategoryDialog(context, category: c);
                      if (v == 'delete') _delete(context, ref, c);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Modifier')),
                      PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCategoryDialog(context),
        tooltip: 'Nouvelle catégorie',
        child: const Icon(Icons.add),
      ),
    );
  }
}
