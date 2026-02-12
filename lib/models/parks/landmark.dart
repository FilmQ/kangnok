class Landmark {
  String _name;
  String _nameTh;
  String _description;
  String _descriptionTh;
  String _parkName;
  int _visitorCount;

  Landmark({
    required String name,
    required String nameTh,
    required String description,
    required String descriptionTh,
    required String parkName,
    required int visitorCount,
  }) : _name = name,
       _nameTh = nameTh,
       _description = description,
       _descriptionTh = descriptionTh,
       _parkName = parkName,
       _visitorCount = visitorCount;

  String get name => _name;
  String get nameTh => _nameTh;
  String get description => _description;
  String get descriptionTh => _descriptionTh;
  String get parkName => _parkName;
  int get visitorCount => _visitorCount;

  set name(String name) => _name = name;
  set nameTh(String nameTh) => _nameTh = nameTh;
  set description(String description) => _description = description;
  set descriptionTh(String descriptionTh) => _descriptionTh = descriptionTh;
  set parkName(String parkName) => _parkName = parkName;
  set visitor(int visitorCount) => _visitorCount = visitorCount;

  Map<String, dynamic> toJson() => {
    'name': _name,
    'nameTh': _nameTh,
    'description': _description,
    'descriptionTh': _descriptionTh,
    'parkName': _parkName,
    'visitorCount': _visitorCount,
  };

  factory Landmark.fromJson(Map<String, dynamic> json) => Landmark(
    name: json['name'] as String,
    nameTh: json['nameTh'] as String,
    description: json['description'] as String,
    descriptionTh: json['descriptionTh'] as String,
    parkName: json['parkName'] as String,
    visitorCount: json['visitorCount'] as int,
  );
}
