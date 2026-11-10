import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';

import '../../domain/services/rich_content.dart';

/// Contenu enregistré (texte simple ou Delta JSON) -> document de l'éditeur.
Document documentFromContent(String content) {
  if (content.trim().isEmpty) return Document();
  if (RichContent.isDelta(content)) {
    try {
      return Document.fromJson(jsonDecode(content) as List);
    } catch (_) {
      // contenu illisible : on retombe sur le texte brut
    }
  }
  final doc = Document();
  doc.insert(0, content.trim());
  return doc;
}

/// Document de l'éditeur -> contenu à enregistrer ('' si vide).
String contentFromDocument(Document document) {
  if (document.toPlainText().trim().isEmpty) return '';
  return jsonEncode(document.toDelta().toJson());
}
