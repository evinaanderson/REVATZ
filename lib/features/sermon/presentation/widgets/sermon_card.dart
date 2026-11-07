import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../category/presentation/state/category_providers.dart';
import '../../domain/entities/sermon.dart';
import 'sermon_menu_actions.dart';
import 'sermon_photo.dart';

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
        child: SizedBox(
          height: 112,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 100,
                child: SermonPhoto(photo: sermon.photo, width: 100, height: 112),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 0, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        sermon.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration:
                                BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${category?.name ?? 'Sans catégorie'} · ${formatDate(date)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: theme.colorScheme.outline),
                            ),
                          ),
                        ],
                      ),
                      if (sermon.passages.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.menu_book,
                                size: 14, color: AppColors.gold),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                sermon.passages.map((p) => p.reference).join(' · '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        )
                      else
                        const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SermonMenuButton(sermon: sermon),
                  Padding(
                    padding: const EdgeInsets.only(right: 12, bottom: 10),
                    child: Icon(
                      synced ? Icons.cloud_done_outlined : Icons.cloud_upload_outlined,
                      size: 18,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
