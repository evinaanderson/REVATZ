import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../widgets/list_marker_button.dart';
import '../widgets/quill_content.dart';

/// Éditeur plein écran du contenu d'un sermon (texte riche).
/// Retourne le contenu à enregistrer (String) à la fermeture.
class ContentEditorPage extends StatefulWidget {
  final String initialContent;
  const ContentEditorPage({super.key, required this.initialContent});

  @override
  State<ContentEditorPage> createState() => _ContentEditorPageState();
}

class _ContentEditorPageState extends State<ContentEditorPage> {
  late final QuillController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuillController(
      document: documentFromContent(widget.initialContent),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _done() => Navigator.pop(context, contentFromDocument(_controller.document));

  @override
  Widget build(BuildContext context) {
    // Le bouton retour valide aussi le contenu (rien n'est perdu).
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _done();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Contenu du sermon'),
          actions: [
            IconButton(
              tooltip: 'Terminé',
              icon: const Icon(Icons.check),
              onPressed: _done,
            ),
          ],
        ),
        body: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: QuillSimpleToolbar(
                    controller: _controller,
                    config: const QuillSimpleToolbarConfig(
                      multiRowsDisplay: false,
                      showFontFamily: false,
                      showSearchButton: false,
                      showSubscript: false,
                      showSuperscript: false,
                      showInlineCode: false,
                      showCodeBlock: false,
                      showLink: false,
                    ),
                  ),
                ),
                ListMarkerButton(controller: _controller),
              ],
            ),
            const Divider(height: 1),
            Expanded(
              child: QuillEditor.basic(
                controller: _controller,
                config: const QuillEditorConfig(
                  placeholder: 'Écrivez votre sermon…',
                  padding: EdgeInsets.all(16),
                  autoFocus: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
