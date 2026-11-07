import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/async_value_view.dart';
import '../../../../core/presentation/widgets/empty_state.dart';
import '../../../category/presentation/state/category_providers.dart';
import '../../domain/entities/sermon.dart';
import '../state/sermon_providers.dart';
import '../widgets/sermon_card.dart';
import 'sermon_detail_page.dart';
import 'sermon_form_page.dart';

class SermonListPage extends ConsumerStatefulWidget {
  const SermonListPage({super.key});

  @override
  ConsumerState<SermonListPage> createState() => _SermonListPageState();
}

class _SermonListPageState extends ConsumerState<SermonListPage> {
  bool _searching = false;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) {
        _searchCtrl.clear();
        ref.read(sermonSearchQueryProvider.notifier).state = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sermons = ref.watch(filteredSermonsProvider);
    final filtering = ref.watch(selectedCategoryIdProvider) != null ||
        ref.watch(sermonSearchQueryProvider).trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Rechercher un sermon…',
                  border: InputBorder.none,
                ),
                onChanged: (v) =>
                    ref.read(sermonSearchQueryProvider.notifier).state = v,
              )
            : const Text('Mes sermons'),
        actions: [
          IconButton(
            tooltip: _searching ? 'Fermer la recherche' : 'Rechercher',
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          const _CategoryFilterBar(),
          Expanded(
            child: AsyncValueView<List<Sermon>>(
              value: sermons,
              data: (list) {
                if (list.isEmpty) {
                  return EmptyState(
                    icon: filtering ? Icons.search_off : Icons.menu_book_outlined,
                    title: filtering ? 'Aucun résultat' : 'Aucun sermon',
                    message: filtering
                        ? 'Essayez un autre mot-clé ou une autre catégorie.'
                        : 'Appuyez sur « Nouveau » pour écrire votre premier sermon.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 88),
                  itemCount: list.length,
                  itemBuilder: (_, i) => SermonCard(
                    sermon: list[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => SermonDetailPage(sermonId: list[i].id)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SermonFormPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau'),
      ),
    );
  }
}

class _CategoryFilterBar extends ConsumerWidget {
  const _CategoryFilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesStreamProvider).valueOrNull ?? const [];
    final selected = ref.watch(selectedCategoryIdProvider);
    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Tous'),
              selected: selected == null,
              onSelected: (_) =>
                  ref.read(selectedCategoryIdProvider.notifier).state = null,
            ),
          ),
          for (final c in categories)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(c.name),
                selected: selected == c.id,
                onSelected: (_) => ref.read(selectedCategoryIdProvider.notifier).state =
                    selected == c.id ? null : c.id,
              ),
            ),
        ],
      ),
    );
  }
}
