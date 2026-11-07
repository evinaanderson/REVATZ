import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/dialogs.dart';
import '../../../../core/presentation/widgets/empty_state.dart';
import '../../../../core/utils/format.dart';
import '../../../category/presentation/state/category_providers.dart';
import '../state/sermon_providers.dart';
import '../widgets/photo_thumbnail.dart';
import 'sermon_form_page.dart';

class SermonDetailPage extends ConsumerWidget {
  final String sermonId;
  const SermonDetailPage({super.key, required this.sermonId});

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final sermon = ref.read(sermonByIdProvider(sermonId));
    if (sermon == null) return;
    final ok = await confirmDialog(
      context,
      title: 'Supprimer ce sermon ?',
      message: '« ${sermon.title} » sera supprimé définitivement.',
      confirmLabel: 'Supprimer',
      destructive: true,
    );
    if (!ok) return;

    final result = await ref.read(sermonActionsProvider).delete(sermonId);
    if (!context.mounted) return;
    result.when<void>(
      success: (_) {
        final storage = ref.read(photoStorageProvider);
        for (final p in sermon.photos) {
          storage.deleteFile(p.path);
        }
        Navigator.pop(context);
        showMessage(context, 'Sermon supprimé');
      },
      failure: (f) => showMessage(context, f.message),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sermon = ref.watch(sermonByIdProvider(sermonId));
    final theme = Theme.of(context);

    if (sermon == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(icon: Icons.search_off, title: 'Sermon introuvable'),
      );
    }

    final category = ref.watch(categoriesMapProvider)[sermon.categoryId];
    final color = category?.colorValue != null
        ? Color(category!.colorValue!)
        : theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sermon'),
        actions: [
          IconButton(
            tooltip: 'Modifier',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SermonFormPage(sermonId: sermonId)),
            ),
          ),
          IconButton(
            tooltip: 'Supprimer',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(sermon.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Chip(
                avatar: CircleAvatar(backgroundColor: color, radius: 6),
                label: Text(category?.name ?? 'Sans catégorie'),
              ),
              if (sermon.preachedAt != null)
                Text('Prêché le ${formatDate(sermon.preachedAt!)}',
                    style: theme.textTheme.bodyMedium),
            ],
          ),
          if (sermon.passages.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Textes bibliques', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            for (final p in sermon.passages)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.reference,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      if (p.text.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(p.text,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                ),
              ),
          ],
          if (sermon.content.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Contenu', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            SelectableText(sermon.content, style: theme.textTheme.bodyLarge),
          ],
          if (sermon.photos.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Photos de référence', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final ph in sermon.photos)
                  PhotoThumbnail(
                      photo: ph, onTap: () => showPhotoViewer(context, ph)),
              ],
            ),
          ],
          if (sermon.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 6,
              children: [for (final t in sermon.tags) Chip(label: Text('#$t'))],
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Créé le ${formatDateTime(sermon.createdAt)} · '
            'modifié le ${formatDateTime(sermon.updatedAt)}',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }
}
