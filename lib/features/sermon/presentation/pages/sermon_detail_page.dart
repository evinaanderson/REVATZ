import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/empty_state.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../category/presentation/state/category_providers.dart';
import '../state/sermon_providers.dart';
import '../widgets/photo_thumbnail.dart' show showPhotoViewer;
import '../widgets/sermon_menu_actions.dart';
import '../widgets/sermon_photo.dart';

class SermonDetailPage extends ConsumerWidget {
  final String sermonId;
  const SermonDetailPage({super.key, required this.sermonId});

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
    final photo = sermon.photo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sermon'),
        actions: [
          IconButton(
            tooltip: 'Partager',
            icon: const Icon(Icons.share_outlined),
            onPressed: () => shareSermon(context, ref, sermon),
          ),
          IconButton(
            tooltip: 'Modifier',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => openSermonEditor(context, sermonId),
          ),
          IconButton(
            tooltip: 'Supprimer',
            icon: const Icon(Icons.delete_outline),
            onPressed: () =>
                deleteSermonWithConfirm(context, ref, sermon, closePageAfter: true),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: InkWell(
                onTap: photo == null ? null : () => showPhotoViewer(context, photo),
                child: SermonPhoto(photo: photo, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(sermon.title,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
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
          if (sermon.content.isNotEmpty) ...[
            const SizedBox(height: 16),
            SelectableText(sermon.content, style: theme.textTheme.bodyLarge),
          ],
          if (sermon.passages.isNotEmpty) ...[
            const SizedBox(height: 20),
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
                          style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold, color: AppColors.gold)),
                      if (p.text.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('« ${p.text} »',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                ),
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
