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
    'rangers': rangers,
  };

  factory Park.fromJson(Map<String, dynamic> json) => Park(
    visitorCount: json['visitorCount'] as int,
    landmarks: json['landmarks'] as Map<String, String>,
    rangers: json['rangers'] as List<Ranger>,
  );
}
