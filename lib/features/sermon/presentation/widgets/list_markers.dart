/// Repères de début de ligne : chiffres romains (I, II, IV...), chiffres,
/// lettres, tirets, étoiles et autres symboles.
///
/// Ils sont insérés comme texte au début de la ligne : ils restent donc
/// identiques dans le partage WhatsApp, l'export et la sauvegarde.
/// Dart pur : aucune dépendance à l'éditeur.
enum MarkerStyle {
  roman,
  number,
  letterUpper,
  letterLower,
  dash,
  star,
  bullet,
  arrow,
  cross,
  check,
  diamond,
  none,
}

class MarkerEdit {
  final int lineStart;
  final int removeLength;
  final String insertText;
  const MarkerEdit(this.lineStart, this.removeLength, this.insertText);
}

class ListMarkers {
  const ListMarkers._();

  static const _symbols = <MarkerStyle, String>{
    MarkerStyle.dash: '–',
    MarkerStyle.star: '★',
    MarkerStyle.bullet: '•',
    MarkerStyle.arrow: '➤',
    MarkerStyle.cross: '✝',
    MarkerStyle.check: '✓',
    MarkerStyle.diamond: '◆',
  };

  /// Un repère reconnu au début d'une ligne.
  static final _anyMarker =
      RegExp(r'^(?:[–★•➤✝✓◆]|\d+\.|[IVXLCDM]+\.|[A-Za-z]\.)[ \t]+');
  static final _numberMarker = RegExp(r'^(\d+)\.[ \t]');
  static final _romanMarker = RegExp(r'^([IVXLCDM]+)\.[ \t]');
  static final _upperMarker = RegExp(r'^([A-Z])\.[ \t]');
  static final _lowerMarker = RegExp(r'^([a-z])\.[ \t]');

  /// Calcule la modification à faire sur la ligne du curseur.
  /// [text] = texte brut du document, [offset] = position du curseur.
  static MarkerEdit plan(String text, int offset, MarkerStyle style) {
    final off = offset.clamp(0, text.length);
    final lineStart = off == 0 ? 0 : text.lastIndexOf('\n', off - 1) + 1;
    var lineEnd = text.indexOf('\n', lineStart);
    if (lineEnd == -1) lineEnd = text.length;

    final line = text.substring(lineStart, lineEnd);
    final removeLength = _anyMarker.firstMatch(line)?.end ?? 0;

    // Dernière ligne non vide située avant celle du curseur.
    var previous = '';
    var cursor = lineStart;
    while (cursor > 0 && previous.trim().isEmpty) {
      final prevEnd = cursor - 1;
      final prevStart = prevEnd == 0 ? 0 : text.lastIndexOf('\n', prevEnd - 1) + 1;
      previous = text.substring(prevStart, prevEnd);
      cursor = prevStart;
    }

    final marker = _markerFor(style, previous);
    return MarkerEdit(lineStart, removeLength, marker.isEmpty ? '' : '$marker ');
  }

  static String _markerFor(MarkerStyle style, String previous) {
    switch (style) {
      case MarkerStyle.number:
        final n = int.tryParse(_numberMarker.firstMatch(previous)?.group(1) ?? '');
        return '${(n ?? 0) + 1}.';
      case MarkerStyle.roman:
        final r = fromRoman(_romanMarker.firstMatch(previous)?.group(1) ?? '');
        return '${toRoman((r ?? 0) + 1)}.';
      case MarkerStyle.letterUpper:
        return '${_nextLetter(_upperMarker.firstMatch(previous)?.group(1), 65)}.';
      case MarkerStyle.letterLower:
        return '${_nextLetter(_lowerMarker.firstMatch(previous)?.group(1), 97)}.';
      case MarkerStyle.none:
        return '';
      default:
        return _symbols[style] ?? '';
    }
  }

  static String _nextLetter(String? previous, int base) {
    if (previous == null) return String.fromCharCode(base);
    final index = previous.codeUnitAt(0) - base + 1;
    return String.fromCharCode(base + (index % 26));
  }

  static String toRoman(int n) {
    if (n <= 0) return 'I';
    const values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
    const symbols = ['M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I'];
    var rest = n;
    final b = StringBuffer();
    for (var i = 0; i < values.length; i++) {
      while (rest >= values[i]) {
        b.write(symbols[i]);
        rest -= values[i];
      }
    }
    return b.toString();
  }

  /// Retourne null si [roman] n'est pas un chiffre romain valide.
  static int? fromRoman(String roman) {
    if (roman.isEmpty) return null;
    const map = {'I': 1, 'V': 5, 'X': 10, 'L': 50, 'C': 100, 'D': 500, 'M': 1000};
    var total = 0;
    for (var i = 0; i < roman.length; i++) {
      final v = map[roman[i]];
      if (v == null) return null;
      final next = i + 1 < roman.length ? map[roman[i + 1]] : null;
      total += (next != null && next > v) ? -v : v;
    }
    return toRoman(total) == roman ? total : null;
  }
}
