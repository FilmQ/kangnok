import 'package:kangnok/models/achievements/criterion.dart';

class ParkVisitedCountCriterion extends Criterion {
  @override
  String get type => "park_visit_count";
  int requiredCount;

  ParkVisitedCountCriterion({required this.requiredCount}) {
    if (requiredCount <= 0) {
      throw ArgumentError("$requiredCount is not a valid range");
    }
  }

  @override
  bool isSatisfied(Map<String, dynamic> userProgress) {
    final visitedParks = userProgress['parkVisited'] as List<dynamic>? ?? [];
    return visitedParks.length >= requiredCount;
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'requiredCount': requiredCount,
  };

  factory ParkVisitedCountCriterion.fromJson(Map<String, dynamic> json) =>
      ParkVisitedCountCriterion(requiredCount: json['requiredCount'] as int);
}


class ParkVisitedNameCriterion extends Criterion {
  @override
  String get type => "park_visit_name";
  String requiredName;

  ParkVisitedNameCriterion({required this.requiredName});

  @override
  bool isSatisfied(Map<String, dynamic> userProgress) {
  final visitedParks = userProgress['parkVisited'] as List<dynamic>?;
  return visitedParks?.contains(requiredName) ?? false; 
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'requiredName': requiredName};

  factory ParkVisitedNameCriterion.fromJson(Map<String, dynamic> json) =>
      ParkVisitedNameCriterion(requiredName: json["requiredName"] as String);
}
