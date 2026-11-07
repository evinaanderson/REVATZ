import '../entities/sermon.dart';

/// Contenu prêt à partager (style « annonce WhatsApp »).
class SermonShareContent {
  final String text;
  final String? photoPath;
  const SermonShareContent({required this.text, this.photoPath});
}

/// Construit le message de partage d'un sermon :
///  - le titre en gras au début ;
///  - le contenu ;
///  - tout au fond, les textes bibliques : référence en gras,
///    verset en italique entre guillemets ;
///  - la photo de référence (une seule) si elle existe.
///
/// Syntaxe WhatsApp : *gras* et _italique_.
class BuildSermonShare {
  const BuildSermonShare();

  SermonShareContent call(Sermon sermon) {
    final b = StringBuffer()..writeln(_bold(sermon.title));

    final content = sermon.content.trim();
    if (content.isNotEmpty) {
      b
        ..writeln()
        ..writeln(content);
    }

    for (final p in sermon.passages) {
      if (p.reference.trim().isEmpty) continue;
      b
        ..writeln()
        ..writeln(_bold(p.reference));
      final verse = p.text.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (verse.isNotEmpty) b.writeln(_italic('"$verse"'));
    }

    return SermonShareContent(
      text: b.toString().trim(),
      photoPath: sermon.photo?.path,
    );
  }

  String _bold(String t) => '*${t.replaceAll('*', '').trim()}*';
  String _italic(String t) => '_${t.replaceAll('_', '').trim()}_';
}
