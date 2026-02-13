class Landmark {
  String name;
  String nameTh;
  String description;
  String descriptionTh;
  String parkName;
  String businessHour; // closing and opening time
  List<String> transportOptions;
  List<String> transportOptionsTh;
  int fee;
  int feeForeigner; // fee for foreigners

  Landmark({
    required this.name,
    required this.nameTh,
    required this.description,
    required this.descriptionTh,
    required this.parkName,
    required this.businessHour,
    required this.transportOptions,
    required this.transportOptionsTh,
    required this.fee,
    required this.feeForeigner,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'nameTh': nameTh,
    'description': description,
    'descriptionTh': descriptionTh,
    'parkName': parkName,
    'businessHour': businessHour,
    'transportOptions': transportOptions,
    'transportOptionsTh': transportOptionsTh,
    'fee': fee,
    'feeForeigner': feeForeigner,
  };

  factory Landmark.fromJson(Map<String, dynamic> json) {
    print('[Landmark.fromJson] keys: ${json.keys.toList()}');
    print('[Landmark.fromJson] parsing: ${json['name']}');

    return Landmark(
      name: json['name'] as String,
      nameTh: json['nameTh'] as String? ?? '',
      description: json['description'] as String? ?? '',
      descriptionTh: json['descriptionTh'] as String? ?? '',
      parkName: json['parkName'] as String? ?? '',
      businessHour: json['businessHour'] as String? ?? '',
      transportOptions: List<String>.from(json['transportOptions'] as List? ?? []),
      transportOptionsTh: List<String>.from(json['transportOptionsTh'] as List? ?? []),
      fee: json['fee'] as int? ?? 0,
      feeForeigner: json['feeForeigner'] as int? ?? 0,
    );
  }
}
