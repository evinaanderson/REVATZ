class Sermum {
  int _idSermum;
  String _titre;
  String _description;
  String? imageUrl;

  Sermum({required int idSermum, required String titre, required String description, this.imageUrl})
      : _idSermum = idSermum,
        _titre = titre,
        _description = description;

  String getTitre() {
    return _titre;
  }

  String getDescription() {
    return _description;
  }

  String? getImageUrl() {
    return imageUrl;
  }

  int get idSermum => _idSermum;

  void set idSermum(int value) {
    _idSermum = value;
  }

  void setTitre(String value) {
    _titre = value;
  }

  void setDescription(String value) {
    _description = value;
  }
  void setImageUrl(String? value) {
    if (value != null && value.isEmpty) {
      imageUrl = null;
      return;
    } 
    imageUrl = value;

  }

}
