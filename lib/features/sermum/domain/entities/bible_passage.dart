/// Texte biblique associé à un sermon (ex. « Jean 3:16 »).
class BiblePassage {
  final String reference;
  final String text;

  const BiblePassage({required this.reference, this.text = ''});

  BiblePassage copyWith({String? reference, String? text}) =>
      BiblePassage(reference: reference ?? this.reference, text: text ?? this.text);

  @override
  bool operator ==(Object other) =>
      other is BiblePassage && other.reference == reference && other.text == text;

  @override
  int get hashCode => Object.hash(reference, text);
}
