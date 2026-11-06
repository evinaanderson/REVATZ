class Sermum {
  int _idSermum;
  String titre;
  String description;
  String? imageUrl;

  Sermum({required int idSermum, required String titre, required String description, this.imageUrl})
      : _idSermum = idSermum,
        titre = titre,
        description = description;

  String getTitre() {
    return titre;
  }

  String getDescription() {
    return description;
  }

  String? getImageUrl() {
    return imageUrl;
  }

  int get idSermum => _idSermum;

  void set idSermum(int value) {
    _idSermum = value;
  }

  void setTitre(String value) {
    titre = value;
  }

  void setDescription(String value) {
    description = value;
  }
  void setImageUrl(String? value) {
    if (value != null && value.isEmpty) {
      imageUrl = null;
      return;
    } 
    imageUrl = value;

  }

}
