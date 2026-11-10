import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'list_markers.dart';

/// Menu « Numérotation et symboles » : I, II, IV · 1, 2, 3 · A, B · ★ • – ➤ ✓ ...
/// Le numéro suivant est calculé d'après la ligne précédente.
class ListMarkerButton extends StatelessWidget {
  final QuillController controller;
  const ListMarkerButton({super.key, required this.controller});

  void _apply(MarkerStyle style) {
    final text = controller.document.toPlainText();
    final base = controller.selection.baseOffset;
    final edit = ListMarkers.plan(text, base < 0 ? 0 : base, style);
    if (edit.removeLength == 0 && edit.insertText.isEmpty) return;
    controller.replaceText(
      edit.lineStart,
      edit.removeLength,
      edit.insertText,
      TextSelection.collapsed(offset: edit.lineStart + edit.insertText.length),
    );
  }

  PopupMenuItem<MarkerStyle> _item(MarkerStyle style, String sample, String label) {
    return PopupMenuItem<MarkerStyle>(
      value: style,
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(sample, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MarkerStyle>(
      tooltip: 'Numérotation et symboles',
      icon: const Icon(Icons.stars),
      onSelected: _apply,
      itemBuilder: (_) => [
        _item(MarkerStyle.roman, 'I, II, IV', 'Chiffres romains'),
        _item(MarkerStyle.number, '1, 2, 3', 'Chiffres'),
        _item(MarkerStyle.letterUpper, 'A, B, C', 'Lettres majuscules'),
        _item(MarkerStyle.letterLower, 'a, b, c', 'Lettres minuscules'),
        const PopupMenuDivider(),
        _item(MarkerStyle.dash, '–', 'Tiret'),
        _item(MarkerStyle.star, '★', 'Étoile'),
        _item(MarkerStyle.bullet, '•', 'Puce'),
        _item(MarkerStyle.arrow, '➤', 'Flèche'),
        _item(MarkerStyle.cross, '✝', 'Croix'),
        _item(MarkerStyle.check, '✓', 'Coche'),
        _item(MarkerStyle.diamond, '◆', 'Losange'),
        const PopupMenuDivider(),
        _item(MarkerStyle.none, '✕', 'Retirer le repère'),
      ],
    );
  }
}
