import 'package:kangnok/models/criterion.dart';

/// Two classes exist here:
///   ReviewCountCriterion: how many reviews user has posted
///   ReviewLikesCriterion: how many likes were received during posting

class ReviewCountCriterion extends Criterion {
  @override
  String get type => "review_count";
  int requiredCount;

  ReviewCountCriterion({required this.requiredCount}) {
    if (requiredCount <= 0) {
      throw ArgumentError("$requiredCount is not a valid range");
    }
  }

  @override
  bool isSatisfied(Map<String, dynamic> userProgress) {
    return userProgress['reviewCount'] >= requiredCount;
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'requiredCount': requiredCount,
  };

  factory ReviewCountCriterion.fromJson(Map<String, dynamic> json) =>
      ReviewCountCriterion(requiredCount: json['requiredCount'] as int);
}

class ReviewLikesCriterion extends Criterion {
  @override
  String get type => "review_likes";
  int requiredLikes;

  ReviewLikesCriterion({required this.requiredLikes}) {
    if (requiredLikes <= 0) {
      throw ArgumentError("$requiredLikes is not a valid range");
    }
  }

  @override
  bool isSatisfied(Map<String, dynamic> userProgress) {
    return userProgress['reviewLikes'] >= requiredLikes;
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'requiredLikes': requiredLikes,
  };

  factory ReviewLikesCriterion.fromJson(Map<String, dynamic> json) =>
      ReviewLikesCriterion(requiredLikes: json['requiredLikes'] as int);
}
