import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/format.dart';
import '../../../category/presentation/state/category_providers.dart';
import '../../domain/entities/sermon.dart';

class SermonCard extends ConsumerWidget {
  final Sermon sermon;
  final VoidCallback onTap;

  const SermonCard({super.key, required this.sermon, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final category = ref.watch(categoriesMapProvider)[sermon.categoryId];
    final color = category?.colorValue != null
        ? Color(category!.colorValue!)
        : theme.colorScheme.primary;
    final date = sermon.preachedAt ?? sermon.updatedAt;
    final synced = sermon.syncStatus == SyncStatus.synced;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(sermon.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium),
                          ),
                          Icon(
                            synced ? Icons.cloud_done_outlined : Icons.cloud_upload_outlined,
                            size: 18,
                            color: theme.colorScheme.outline,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category?.name ?? 'Sans catégorie'} · ${formatDate(date)}',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.outline),
                      ),
                      if (sermon.passages.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.menu_book, size: 14, color: color),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                sermon.passages.map((p) => p.reference).join(' · '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
