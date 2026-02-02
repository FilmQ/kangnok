import 'package:kangnok/models/criterion.dart';

class VisitParksCriterion extends Criterion {
  @override
  String get type => "visit_parks";
  int requiredCount;

  VisitParksCriterion({required this.requiredCount}) {
    if (requiredCount <= 0) {
      throw ArgumentError("$requiredCount is not a valid range");
    }
  }

  @override
  bool isSatisfied(Map<String, dynamic> userProgress) {
    return userProgress['parkVisited'] >= requiredCount;
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'requiredCount': requiredCount
  };

  factory VisitParksCriterion.fromJson(Map<String, dynamic> json) =>
      VisitParksCriterion(
        requiredCount: json['requiredCount'] as int,
      );
}
