import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/presentation/widgets/dialogs.dart';
import '../../../../core/utils/format.dart';
import '../../../sermon/domain/entities/sermon.dart';
import '../../../sermon/presentation/state/sermon_providers.dart';
import '../../domain/entities/backup_info.dart';
import '../state/backup_providers.dart';

class BackupPage extends ConsumerStatefulWidget {
  const BackupPage({super.key});

  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage> {
  String? _busyLabel;
  bool get _busy => _busyLabel != null;

  Future<void> _run(String label, Future<void> Function() task) async {
    setState(() => _busyLabel = label);
    try {
      await task();
    } finally {
      if (mounted) setState(() => _busyLabel = null);
    }
  }

  Future<void> _backup() => _run('Sauvegarde en cours…', () async {
        final result = await ref.read(backupActionsProvider).backup();
        if (!mounted) return;
        ref.invalidate(backupInfoProvider);
        showMessage(
          context,
          result.when<String>(
            success: (_) => 'Sauvegarde terminée',
            failure: (f) => f.message,
          ),
        );
      });

  Future<void> _restore() async {
    final ok = await confirmDialog(
      context,
      title: 'Restaurer depuis Google Drive ?',
      message: 'Les sermons et catégories de la sauvegarde seront ajoutés. '
          'Ceux qui existent déjà sur ce téléphone seront remplacés par la '
          'version sauvegardée.',
      confirmLabel: 'Restaurer',
    );
    if (!ok || !mounted) return;

    await _run('Restauration en cours…', () async {
      final result = await ref.read(backupActionsProvider).restore();
      if (!mounted) return;
      showMessage(
        context,
        result.when<String>(
          success: (d) =>
              '${d.sermons.length} sermon(s) et ${d.categories.length} catégorie(s) restaurés',
          failure: (f) => f.message,
        ),
      );
    });
  }

  Future<void> _export() => _run('Création du ZIP…', () async {
        final result = await ref.read(backupActionsProvider).exportZip();
        if (!mounted) return;
        final path = result.valueOrNull;
        if (path == null) {
          showMessage(context, result.failureOrNull?.message ?? 'Export impossible');
          return;
        }
        try {
          await Share.shareXFiles([XFile(path)], text: 'Export de mes sermons');
        } catch (_) {
          if (mounted) showMessage(context, 'ZIP créé : $path');
        }
      });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = ref.watch(backupInfoProvider).valueOrNull ?? const BackupInfo();
    final sermons = ref.watch(sermonsStreamProvider).valueOrNull ?? const <Sermon>[];
    final pending = sermons.where((s) => s.syncStatus == SyncStatus.pending).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Sauvegarde')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_busy) ...[
            LinearProgressIndicator(),
            const SizedBox(height: 4),
            Text(_busyLabel!, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(
                      info.status == BackupStatus.failed
                          ? Icons.error_outline
                          : Icons.cloud_done_outlined,
                      color: info.status == BackupStatus.failed
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text('État de la sauvegarde', style: theme.textTheme.titleMedium),
                  ]),
                  const SizedBox(height: 12),
                  Text(info.lastBackupAt == null
                      ? 'Aucune sauvegarde effectuée'
                      : 'Dernière sauvegarde : ${formatDateTime(info.lastBackupAt!)}'),
                  if (info.status == BackupStatus.failed)
                    Text('La dernière tentative a échoué.',
                        style: TextStyle(color: theme.colorScheme.error)),
                  const SizedBox(height: 4),
                  Text(pending == 0
                      ? 'Tous vos sermons sont à jour.'
                      : '$pending sermon${pending > 1 ? 's' : ''} non sauvegardé${pending > 1 ? 's' : ''}.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _busy ? null : _backup,
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Sauvegarder sur Google Drive'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy ? null : _restore,
            icon: const Icon(Icons.cloud_download_outlined),
            label: const Text('Restaurer depuis Google Drive'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy ? null : _export,
            icon: const Icon(Icons.folder_zip_outlined),
            label: const Text('Exporter en ZIP (un dossier par catégorie)'),
          ),
          const SizedBox(height: 24),
          Text(
            'La sauvegarde est enregistrée dans le dossier « GestionSermons » de '
            'votre Google Drive. Elle met à jour le même fichier à chaque fois. '
            'Si Google vous le demande, connectez-vous et autorisez l\'accès.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }
}
