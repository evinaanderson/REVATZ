import 'dart:convert';

/// Le contenu d'un sermon est soit :
///  - du texte simple (sermons créés avant la version 3.0),
///  - un document « Delta » (JSON) produit par l'éditeur de texte riche.
///
/// Cette classe (Dart pur) lit les deux formats sans dépendre de l'éditeur :
/// recherche, export texte et partage WhatsApp.
class RichContent {
  const RichContent._();

  /// Vrai si [content] est un document Delta (liste d'opérations « insert »).
  static bool isDelta(String content) {
    final t = content.trimLeft();
    if (!t.startsWith('[')) return false;
    try {
      final d = jsonDecode(t);
      return d is List &&
          d.isNotEmpty &&
          d.every((e) => e is Map && e.containsKey('insert'));
    } catch (_) {
      return false;
    }
  }

  static bool isBlank(String content) => toSearchText(content).trim().isEmpty;

  /// Texte brut sans aucune mise en forme (pour la recherche).
  static String toSearchText(String content) {
    if (!isDelta(content)) return content;
    final b = StringBuffer();
    for (final op in jsonDecode(content) as List) {
      final insert = op['insert'];
      if (insert is String) b.write(insert);
    }
    return b.toString();
  }

  /// Texte lisible : titres sans balises, listes avec leurs puces ou numéros.
  static String toPlainText(String content) => _convert(content, whatsapp: false);

  /// Texte au format WhatsApp : *gras*, _italique_, ~barré~.
  /// Les titres deviennent des lignes en gras ; les listes gardent leurs repères.
  /// (WhatsApp ne gère ni le souligné, ni les couleurs, ni l'alignement.)
  static String toWhatsApp(String content) => _convert(content, whatsapp: true);

  // ---------------------------------------------------------------------

  static String _convert(String content, {required bool whatsapp}) {
    if (!isDelta(content)) return content.trim();

    final ops = jsonDecode(content) as List;
    final lines = <String>[];
    final formatted = StringBuffer();
    final plain = StringBuffer();
    final counters = <int, int>{};

    void finish(Map<String, dynamic> attrs) {
      final plainText = plain.toString();
      var line = formatted.toString();
      formatted.clear();
      plain.clear();

      final list = attrs['list'];
      final indent = attrs['indent'] is int ? attrs['indent'] as int : 0;

      if (attrs['header'] != null && plainText.trim().isNotEmpty) {
        final t = plainText.trim();
        line = whatsapp ? '*${t.replaceAll('*', '')}*' : t;
      }

      var prefix = '';
      final pad = '   ' * indent;
      if (list == 'bullet') {
        prefix = '$pad• ';
      } else if (list == 'ordered') {
        counters.removeWhere((k, _) => k > indent);
        counters[indent] = (counters[indent] ?? 0) + 1;
        prefix = '$pad${counters[indent]}. ';
      } else if (list == 'checked') {
        prefix = '☑ ';
      } else if (list == 'unchecked') {
        prefix = '☐ ';
      } else if (attrs['blockquote'] == true) {
        prefix = '> ';
      }
      if (list != 'ordered') counters.clear();

      lines.add(plainText.trim().isEmpty ? '' : '$prefix$line');
    }

    for (final op in ops) {
      final insert = op['insert'];
      if (insert is! String) continue;
      final attrs = (op['attributes'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{};
      final parts = insert.split('\n');
      for (var i = 0; i < parts.length; i++) {
        final part = parts[i];
        if (part.isNotEmpty) {
          plain.write(part);
          formatted.write(whatsapp ? _inline(part, attrs) : part);
        }
        if (i < parts.length - 1) finish(attrs);
      }
    }
    if (plain.isNotEmpty) finish(const <String, dynamic>{});

    return lines.join('\n').replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }

  /// Entoure [part] de *, _ ou ~ en laissant les espaces à l'extérieur
  /// (WhatsApp refuse « * texte * »).
  static String _inline(String part, Map<String, dynamic> attrs) {
    final bold = attrs['bold'] == true;
    final italic = attrs['italic'] == true;
    final strike = attrs['strike'] == true;
    if (!bold && !italic && !strike) return part;

    final m = RegExp(r'^(\s*)(.*?)(\s*)$', dotAll: true).firstMatch(part);
    final lead = m?.group(1) ?? '';
    var core = m?.group(2) ?? part;
    final trail = m?.group(3) ?? '';
    if (core.isEmpty) return part;

    if (strike) core = '~${core.replaceAll('~', '')}~';
    if (italic) core = '_${core.replaceAll('_', '')}_';
    if (bold) core = '*${core.replaceAll('*', '')}*';
    return '$lead$core$trail';
  }
}
