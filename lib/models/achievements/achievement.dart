import 'package:kangnok/models/achievements/criterion.dart';

class Achievement {
  String title;
  String description;
  String thumbnail;
  bool achieved;
  List<Criterion> criterias;

  Achievement({
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.achieved,
    required this.criterias,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'thumbnail': thumbnail,
    'achieved': achieved,
    'criterias': criterias.map((c) => c.toJson()).toList(),
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    title: json['title'] as String,
    description: json['description'] as String,
    thumbnail: json['thumbnail'] as String,
    achieved: json['achieved'] as bool,
    criterias: (json['criterias'] as List)
        .map((c) => CriterionFactory.fromJson(c as Map<String, dynamic>))
        .toList(),
  );

  bool isUnlocked(Map<String, dynamic> userProgress) {
    return criterias.every((c) => c.isSatisfied(userProgress));
  }
}
