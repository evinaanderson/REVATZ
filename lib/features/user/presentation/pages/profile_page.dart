import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/async_value_view.dart';
import '../../../../core/presentation/widgets/dialogs.dart';
import '../../domain/entities/user.dart';
import '../state/user_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: AsyncValueView<User?>(
        value: user,
        data: (u) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundImage:
                    (u?.photoUrl != null) ? NetworkImage(u!.photoUrl!) : null,
                child: (u?.photoUrl == null) ? const Icon(Icons.person, size: 44) : null,
              ),
            ),
            const SizedBox(height: 16),
            if (u != null) ...[
              Text(u.name,
                  textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(u.email,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.outline)),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => ref.read(currentUserProvider.notifier).signOut(),
                icon: const Icon(Icons.logout),
                label: const Text('Se déconnecter'),
              ),
            ] else ...[
              Text('Vous n\'êtes pas connecté',
                  textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                'Connectez-vous avec Google pour sauvegarder vos sermons sur '
                'Google Drive et les retrouver si vous perdez votre téléphone.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () async {
                  final error = await ref.read(currentUserProvider.notifier).signIn();
                  if (error != null && context.mounted) showMessage(context, error);
                },
                icon: const Icon(Icons.login),
                label: const Text('Se connecter avec Google'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
