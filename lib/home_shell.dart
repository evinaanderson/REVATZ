import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/presentation/navigation_providers.dart';
import 'features/backup/presentation/pages/backup_page.dart';
import 'features/category/presentation/pages/categories_page.dart';
import 'features/sermon/presentation/pages/sermon_list_page.dart';
import 'features/user/presentation/pages/profile_page.dart';

/// Barre de navigation inférieure : Sermons, Catégories, Sauvegarde, Profil.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  static const List<Widget> _pages = [
    SermonListPage(),
    CategoriesPage(),
    BackupPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeTabIndexProvider);
    return Scaffold(
      body: IndexedStack(index: index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) =>
            ref.read(homeTabIndexProvider.notifier).state = i,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Sermons'),
          NavigationDestination(
              icon: Icon(Icons.folder_outlined),
              selectedIcon: Icon(Icons.folder),
              label: 'Catégories'),
          NavigationDestination(
              icon: Icon(Icons.cloud_outlined),
              selectedIcon: Icon(Icons.cloud),
              label: 'Sauvegarde'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil'),
        ],
      ),
    );
  }
}
