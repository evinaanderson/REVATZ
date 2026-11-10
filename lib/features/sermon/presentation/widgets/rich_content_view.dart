import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'quill_content.dart';

/// Affiche le contenu d'un sermon avec sa mise en forme (lecture seule).
/// Sans défilement propre : à placer dans un ListView / SingleChildScrollView.
class RichContentView extends StatefulWidget {
  final String content;
  const RichContentView({super.key, required this.content});

  @override
  State<RichContentView> createState() => _RichContentViewState();
}

class _RichContentViewState extends State<RichContentView> {
  late QuillController _controller;

  QuillController _create() => QuillController(
        document: documentFromContent(widget.content),
        selection: const TextSelection.collapsed(offset: 0),
      )..readOnly = true;

  @override
  void initState() {
    super.initState();
    _controller = _create();
  }

  @override
  void didUpdateWidget(covariant RichContentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _controller.dispose();
      _controller = _create();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QuillEditor.basic(
      controller: _controller,
      config: const QuillEditorConfig(
        scrollable: false,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
