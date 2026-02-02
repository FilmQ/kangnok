import 'package:kangnok/models/ranger.dart';

/*
  Note: Pattern to remember for lists when serializing and deserializing:                                           
  - List<String> → List<String>.from(json['key'] as List)                  
  - List<YourClass> → (json['key'] as List).map((e) => YourClass.fromJson(e
   as Map<String, dynamic>)).toList()                                      
                                                                           
  The key difference: primitive lists use .from() constructor, object lists
   need .map() with explicit deserialization.  
*/

class Park {
  int visitorCount;
  Map<String, String> landmarks; // the landmark's name maps to its description.
  List<Ranger> rangers;

  Park({
    required this.visitorCount,
    required this.landmarks,
    required this.rangers,
  });

  Map<String, dynamic> toJson() => {
    'visitorCount': visitorCount,
    'landmarks': landmarks,
    'rangers': rangers.map((r) => r.toJson()).toList(),
  };

  factory Park.fromJson(Map<String, dynamic> json) => Park(
    visitorCount: json['visitorCount'] as int,
    landmarks: Map<String, String>.from(json['landmarks'] as Map),
    rangers: (json['rangers'] as List)
        .map((r) => Ranger.fromJson(r as Map<String, dynamic>))
        .toList(), // map THIS to its Map<String, dynamic> counterpart as a list
  );
}
