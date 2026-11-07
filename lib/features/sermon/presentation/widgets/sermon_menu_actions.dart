import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/presentation/widgets/dialogs.dart';
import '../../domain/entities/sermon.dart';
import '../pages/sermon_form_page.dart';
import '../state/sermon_providers.dart';

enum SermonMenuAction { edit, share, delete }

Future<void> openSermonEditor(BuildContext context, String sermonId) =>
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => SermonFormPage(sermonId: sermonId)),
    );

/// Demande confirmation, supprime le sermon et sa photo.
/// [closePageAfter] : referme la page courante (écran de détail).
Future<void> deleteSermonWithConfirm(
  BuildContext context,
  WidgetRef ref,
  Sermon sermon, {
  bool closePageAfter = false,
}) async {
  final ok = await confirmDialog(
    context,
    title: 'Supprimer ce sermon ?',
    message: '« ${sermon.title} » sera supprimé définitivement.',
    confirmLabel: 'Supprimer',
    destructive: true,
  );
  if (!ok || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  final result = await ref.read(sermonActionsProvider).delete(sermon);
  result.when<void>(
    success: (_) {
      if (closePageAfter) navigator.pop();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Sermon supprimé')));
    },
    failure: (f) => messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(f.message))),
  );
}

/// Partage « annonce WhatsApp » : titre en gras, contenu, textes bibliques
/// (référence en gras, verset en italique entre guillemets) + une photo.
Future<void> shareSermon(BuildContext context, WidgetRef ref, Sermon sermon) async {
  final content = ref.read(buildSermonShareProvider)(sermon);
  try {
    final path = content.photoPath;
    if (path != null && await File(path).exists()) {
      await Share.shareXFiles([XFile(path)], text: content.text);
    } else {
      await Share.share(content.text);
    }
  } catch (_) {
    if (context.mounted) showMessage(context, 'Partage impossible');
  }
}

/// Menu des trois points verticaux : Modifier, Partager, Supprimer.
class SermonMenuButton extends ConsumerWidget {
  final Sermon sermon;
  const SermonMenuButton({super.key, required this.sermon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<SermonMenuAction>(
      tooltip: 'Options',
      icon: const Icon(Icons.more_vert),
      onSelected: (action) {
        switch (action) {
          case SermonMenuAction.edit:
            openSermonEditor(context, sermon.id);
          case SermonMenuAction.share:
            shareSermon(context, ref, sermon);
          case SermonMenuAction.delete:
            deleteSermonWithConfirm(context, ref, sermon);
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: SermonMenuAction.edit,
          child: Row(children: [
            Icon(Icons.edit_outlined),
            SizedBox(width: 12),
            Text('Modifier'),
          ]),
        ),
        PopupMenuItem(
          value: SermonMenuAction.share,
          child: Row(children: [
            Icon(Icons.share_outlined),
            SizedBox(width: 12),
            Text('Partager'),
          ]),
        ),
        PopupMenuItem(
          value: SermonMenuAction.delete,
          child: Row(children: [
            Icon(Icons.delete_outline),
            SizedBox(width: 12),
            Text('Supprimer'),
          ]),
        ),
      ],
    );
  }
}
