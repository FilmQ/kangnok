class Fauna {
  String name;
  String nameTh;
  String sciName;
  String description;
  String descriptionTh;
  String imageUrl;

  Fauna({
    required this.name,
    required this.nameTh,
    required this.description,
    required this.descriptionTh,
    required this.imageUrl,
    required this.sciName,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'nameTh': nameTh,
    'description': description,
    'descriptionTh': descriptionTh,
    'imageUrl': imageUrl,
    'sciName': sciName,
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
