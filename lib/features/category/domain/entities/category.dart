class Category {
  final String id;
  final String name;
  final int? colorValue; // ex. 0xFF2196F3
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.createdAt,
    this.colorValue,
  });

  Category copyWith({String? name, int? colorValue}) => Category(
        id: id,
        name: name ?? this.name,
        colorValue: colorValue ?? this.colorValue,
        createdAt: createdAt,
      );

  @override
  bool operator ==(Object other) => other is Category && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
