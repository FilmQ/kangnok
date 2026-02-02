/* Abstract class to be used with Achievement.

  if: Achievement satisfies ALL of the criterion,
  it is then marked as accomplished.

  This class must be extended and the child must implement its own criteria.
 */
import 'package:kangnok/models/review_criterion.dart';
import 'package:kangnok/models/visit_parks_criterion.dart';

abstract class Criterion {
  String get type;

  bool isSatisfied(Map<String, dynamic> userProgress);

  Map<String, dynamic> toJson();
}

/// Factory for deserializing Criterion subclasses from JSON.
/// Add new cases here as more criterion types exist.
class CriterionFactory {
  static Criterion fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      // Add cases here as you implement criterion subclasses:
      case 'visit_parks':
        return VisitParksCriterion.fromJson(json);
      case 'review':
        return ReviewCriterion.fromJson(json);
      default:
        throw ArgumentError('Unknown criterion type: ${json['type']}');
    }
  }
}