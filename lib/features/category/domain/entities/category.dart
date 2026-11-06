class Category {
  String _id;
  String _name;
  String _description;
  String? imageUrl;
  

  Category({
    required String id,
    required String name,
    required String description,
    this.imageUrl,
  })  : _id = id,
        _name = name,
        _description = description;

  String get getId {
    return _id;
  }
  String get getName {
    return _name;
  }
  String get getDescription {
    return _description;
  }
  String? get getImageUrl {
    return imageUrl;
  }
  void setImageUrl(String? value) {
    if (value != null && value.isEmpty) {
      imageUrl = null;
      return;
    } 
    imageUrl = value;
  }
  void setName(String value) {
    _name = value;
  }
  void setDescription(String value) {
    _description = value;
  }


}