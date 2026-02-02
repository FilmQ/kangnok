import 'package:kangnok/models/criterion.dart';

class ReviewCriterion extends Criterion {
  @override
  String get type => "review";
  int requiredLike;

  ReviewCriterion({required this.requiredLike});

  @override
  bool isSatisfied(Map<String, dynamic> userProgress) {
    return userProgress['like'] >= requiredLike;
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'requiredLike': requiredLike};

  factory ReviewCriterion.fromJson(Map<String, dynamic> json) =>
      ReviewCriterion(requiredLike: json['requiredLike'] as int);
}
