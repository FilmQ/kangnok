import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kangnok/models/parks/fauna.dart';
import 'package:kangnok/models/parks/flora.dart';
import 'package:kangnok/models/parks/landmark.dart';
import 'package:kangnok/models/roles/ranger.dart';

/*
  Note: Pattern to remember for lists when serializing and deserializing:
  - List<String> → List<String>.from(json['key'] as List)
  - List<YourClass> → (json['key'] as List).map((e) => YourClass.fromJson(e
   as Map<String, dynamic>)).toList()

  The key difference: primitive lists use .from() constructor, object lists
   need .map() with explicit deserialization.
*/

class Park {
  String name;
  String nameTh;
  String description; // the park's brief description
  String descriptionTh;
  String location;
  String locationTh;
  String coordinate;

  String businessHour; // park's opening and close time.
  String businessHourTh; 

  int visitorCount;

  List<String> imageUrl;
  List<Landmark> landmarks;
  List<Ranger> rangers;
  List<Fauna> faunas; // local animals
  List<Flora> floras; // local plants

  DateTime createdAt;

  Park({
    required this.name,
    required this.nameTh,
    required this.description,
    required this.descriptionTh,
    required this.location,
    required this.locationTh,
    required this.coordinate,
    required this.businessHour,
    required this.businessHourTh,
    required this.imageUrl,
    required this.visitorCount,
    required this.landmarks,
    required this.rangers,
    required this.faunas,
    required this.floras,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'nameTh': nameTh,
    'description': description,
    'descriptionTh': descriptionTh,
    'location': location,
    'locationTh': locationTh,
    'coordinate': coordinate,
    'businessHour': businessHour,
    'businessHourTh': businessHourTh,
    'imageUrl': imageUrl,
    'visitorCount': visitorCount,
    'landmarks': landmarks.map((l) => l.toJson()).toList(),
    'rangers': rangers.map((r) => r.toJson()).toList(),
    'faunas': faunas.map((f) => f.toJson()).toList(),
    'floras': floras.map((f) => f.toJson()).toList(),
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory Park.fromJson(Map<String, dynamic> json) {
    print('[Park.fromJson] keys: ${json.keys.toList()}');
    print('[Park.fromJson] parsing park: ${json['name']}');

    return Park(
      name: json['name'] as String,
      nameTh: json['nameTh'] as String,
      description: json['description'] as String,
      descriptionTh: json['descriptionTh'] as String,
      location: json['location'] as String,
      locationTh: json['locationTh'] as String,
      coordinate: json['coordinate'] as String? ?? '',
      businessHour: json['businessHour'] as String? ?? '',
      businessHourTh: json['businessHourTh'] as String? ?? '',
      imageUrl: List<String>.from(json['imageUrl'] as List? ?? []),
      visitorCount: json['visitorCount'] as int? ?? 0,
      landmarks: (json['landmarks'] as List? ?? [])
          .map((l) => Landmark.fromJson(l as Map<String, dynamic>))
          .toList(),
      rangers: (json['rangers'] as List? ?? [])
          .map((r) => Ranger.fromJson(r as Map<String, dynamic>))
          .toList(),
      faunas: (json['faunas'] as List? ?? [])
          .map((f) => Fauna.fromJson(f as Map<String, dynamic>))
          .toList(),
      floras: (json['floras'] as List? ?? [])
          .map((f) => Flora.fromJson(f as Map<String, dynamic>))
          .toList(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }
}
