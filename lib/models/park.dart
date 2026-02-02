import 'package:kangnok/models/ranger.dart';

/*
  Note: 
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
