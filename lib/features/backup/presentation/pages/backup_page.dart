import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/presentation/widgets/dialogs.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../sermon/domain/entities/sermon.dart';
import '../../../sermon/presentation/state/sermon_providers.dart';
import '../../domain/entities/backup_info.dart';
import '../../domain/entities/local_backup_file.dart';
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

  Future<void> _shareFile(String path) async {
    try {
      await Share.shareXFiles(
        [XFile(path, mimeType: 'application/zip')],
        text: 'Sauvegarde REVATZ',
      );
    } catch (_) {
      if (mounted) showMessage(context, 'Partage impossible');
    }
  }

  /// Boîte de dialogue : chemin du fichier créé + bouton Partager.
  Future<void> _showCreated(String title, String path) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text('Fichier enregistré :\n$path'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer')),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _shareFile(path);
            },
            icon: const Icon(Icons.share_outlined),
            label: const Text('Partager'),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------- Local
  Future<void> _saveLocal() => _run('Sauvegarde en cours…', () async {
        final result = await ref.read(backupActionsProvider).saveLocal();
        if (!mounted) return;
        final path = result.valueOrNull;
        if (path == null) {
          showMessage(context, result.failureOrNull?.message ?? 'Sauvegarde impossible');
          return;
        }
        await _showCreated('Sauvegarde créée', path);
      });

  Future<void> _export() => _run('Création du ZIP…', () async {
        final result = await ref.read(backupActionsProvider).exportZip();
        if (!mounted) return;
        final path = result.valueOrNull;
        if (path == null) {
          showMessage(context, result.failureOrNull?.message ?? 'Export impossible');
          return;
        }
        await _showCreated('Export créé', path);
      });

  Future<void> _restoreFromFile() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['zip'],
    );
    final path = picked?.files.single.path;
    if (path == null || !mounted) return;

    final ok = await confirmDialog(
      context,
      title: 'Restaurer cette sauvegarde ?',
      message: 'Les sermons et catégories du fichier seront ajoutés. '
          'Ceux qui existent déjà sur ce téléphone seront remplacés par la '
          'version du fichier.',
      confirmLabel: 'Restaurer',
    );
    if (!ok || !mounted) return;

    await _run('Restauration en cours…', () async {
      final result = await ref.read(backupActionsProvider).restoreLocal(path);
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

  Future<void> _shareBackup() async {
    final result = await ref.read(backupActionsProvider).listLocal();
    if (!mounted) return;
    final files = result.valueOrNull ?? const <LocalBackupFile>[];
    if (files.isEmpty) {
      showMessage(
        context,
        result.failureOrNull?.message ??
            'Aucune sauvegarde trouvée. Créez-en une d\'abord.',
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Partager quelle sauvegarde ?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: files.length,
                  itemBuilder: (_, i) {
                    final f = files[i];
                    return ListTile(
                      leading: const Icon(Icons.folder_zip_outlined),
                      title: Text(f.name),
                      subtitle:
                          Text('${formatDateTime(f.modifiedAt)} · ${_size(f.sizeBytes)}'),
                      trailing: const Icon(Icons.share_outlined),
                      onTap: () {
                        Navigator.pop(ctx);
                        _shareFile(f.path);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _size(int bytes) {
    if (bytes < 1024) return '$bytes o';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} Ko';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} Mo';
  }

  // ------------------------------------------------------------- Drive
  Future<void> _backupDrive() => _run('Sauvegarde Drive en cours…', () async {
        final result = await ref.read(backupActionsProvider).backupToDrive();
        if (!mounted) return;
        ref.invalidate(backupInfoProvider);
        showMessage(
          context,
          result.when<String>(
            success: (_) => 'Sauvegarde Drive terminée',
            failure: (f) => f.message,
          ),
        );
      });

  Future<void> _restoreDrive() async {
    final ok = await confirmDialog(
      context,
      title: 'Restaurer depuis Google Drive ?',
      message: 'Les sermons et catégories de la sauvegarde seront ajoutés. '
          'Ceux qui existent déjà seront remplacés par la version sauvegardée.',
      confirmLabel: 'Restaurer',
    );
    if (!ok || !mounted) return;

    await _run('Restauration Drive en cours…', () async {
      final result = await ref.read(backupActionsProvider).restoreFromDrive();
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

  // ---------------------------------------------------------------- UI
  Widget _section(ThemeData theme, IconData icon, String title) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Row(children: [
          Icon(icon, color: AppColors.gold),
          const SizedBox(width: 8),
          Text(title, style: theme.textTheme.titleMedium),
        ]),
      );

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
            const LinearProgressIndicator(),
            const SizedBox(height: 4),
            Text(_busyLabel!, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
          ],

          // ---------- Local ----------
          _section(theme, Icons.sd_storage_outlined, 'Sauvegarde sur le téléphone'),
          Text(
            'Les fichiers sont enregistrés dans le dossier REVATZ '
            '(0/REVATZ/Sermon_[date].zip) : un fichier sermon.json et les photos.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _busy ? null : _saveLocal,
            icon: const Icon(Icons.save_alt),
            label: const Text('Sauvegarder en local'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy ? null : _restoreFromFile,
            icon: const Icon(Icons.restore),
            label: const Text('Restaurer depuis un fichier ZIP'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy ? null : _shareBackup,
            icon: const Icon(Icons.share_outlined),
            label: const Text('Partager une sauvegarde'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy ? null : _export,
            icon: const Icon(Icons.folder_zip_outlined),
            label: const Text('Exporter en ZIP (un dossier par catégorie)'),
          ),

          const SizedBox(height: 24),
          const Divider(),

          // ---------- Drive ----------
          _section(theme, Icons.cloud_outlined, 'Google Drive (en ligne)'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.lastBackupAt == null
                        ? 'Aucune sauvegarde en ligne effectuée'
                        : 'Dernière sauvegarde : ${formatDateTime(info.lastBackupAt!)}',
                  ),
                  if (info.status == BackupStatus.failed)
                    Text('La dernière tentative a échoué.',
                        style: TextStyle(color: theme.colorScheme.error)),
                  const SizedBox(height: 4),
                  Text(pending == 0
                      ? 'Tous vos sermons sont à jour.'
                      : '$pending sermon${pending > 1 ? 's' : ''} non sauvegardé${pending > 1 ? 's' : ''} en ligne.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: _busy ? null : _backupDrive,
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Sauvegarder sur Google Drive'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy ? null : _restoreDrive,
            icon: const Icon(Icons.cloud_download_outlined),
            label: const Text('Restaurer depuis Google Drive'),
          ),
        ],
      ),
    );
  }
}
