/// Photo de référence d'un sermon (le chemin pointe vers le stockage de l'app).
class ReferencePhoto {
  final String id;
  final String path;
  final String? caption;

  const ReferencePhoto({required this.id, required this.path, this.caption});

  ReferencePhoto copyWith({String? path, String? caption}) =>
      ReferencePhoto(id: id, path: path ?? this.path, caption: caption ?? this.caption);

  @override
  bool operator ==(Object other) => other is ReferencePhoto && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
