class Achievement {
  String title;
  String description;
  String thumbnail;
  bool achieved;

  Achievement({
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.achieved,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'thumbnail': thumbnail,
    'achieved': achieved,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    title: json['title'] as String,
    description: json['description'] as String,
    thumbnail: json['thumbnail'] as String,
    achieved: json['achieved'] as bool,
  );
}
