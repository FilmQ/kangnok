class Fauna {
  String _name;
  String _nameTh;
  String _sciName;
  String _description;
  String _descriptionTh;
  String _imageUrl;

  Fauna({
    required String name,
    required String nameTh,
    required String description,
    required String descriptionTh,
    required String imageUrl,
    required String sciName,
  }) : _name = name,
       _nameTh = nameTh,
       _description = description,
       _descriptionTh = descriptionTh,
       _imageUrl = imageUrl,
       _sciName = sciName;

  String get name => _name;
  String get nameTh => _nameTh;
  String get description => _description;
  String get descriptionTh => _descriptionTh;
  String get imageUrl => _imageUrl;
  String get sciName => _sciName;

  set name(String name) => _name = name;
  set nameTh(String nameTh) => _nameTh = nameTh;
  set description(String description) => _description = description;
  set descriptionTh(String descriptionTh) => _descriptionTh = descriptionTh;
  set imageUrl(String imageUrl) => _imageUrl = imageUrl;
  set sciName(String sciName) => _sciName = sciName;

  Map<String, dynamic> toJson() => {
    'name': _name,
    'nameTh': _nameTh,
    'description': _description,
    'descriptionTh': _descriptionTh,
    'imageUrl': _imageUrl,
    'sciName': _sciName,
  };

  factory Fauna.fromJson(Map<String, dynamic> json) => Fauna(
    name: json['name'] as String,
    nameTh: json['nameTh'] as String,
    description: json['description'] as String,
    descriptionTh: json['descriptionTh'] as String,
    imageUrl: json['imageUrl'] as String,
    sciName: json['sciName'] as String,
  );
}
