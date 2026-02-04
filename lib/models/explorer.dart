import 'package:kangnok/models/user.dart';

class Explorer extends User {
  String _name;
  List<String> _parkVisited;
  int _reviewCount;
  int _reviewLikes;

  Explorer({
    required super.email,
    required super.passwordHash,
    required String name,
    required List<String> parkVisited,
    required int reviewCount,
    required int reviewLikes,
  }) : _name = name,
       _parkVisited = parkVisited,
       _reviewCount = reviewCount,
       _reviewLikes = reviewLikes;

  String get name => _name;
  set name(String newName) => _name = newName;

  List<String> get parkVisited => _parkVisited;
  set parkVisited(List<String> newParkVisited) => _parkVisited = newParkVisited;

  int get reviewCount => _reviewCount;
  set reviewCount(int newReviewCount) => _reviewCount = newReviewCount;

  int get reviewLikes => _reviewLikes;
  set reviewLikes(int newReviewLikes) => _reviewLikes = newReviewLikes;

  factory Explorer.fromJson(Map<String, dynamic> json) {
    return Explorer(
      email: json['email'] as String,
      passwordHash: json['passwordHash'] as String,
      name: json['name'] as String,
      parkVisited: List<String>.from(json['parkVisited'] as List),
      reviewCount: json['reviewCount'] as int,
      reviewLikes: json['reviewLikes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'passwordHash': passwordHash,
      'name': name,
      'parkVisited': parkVisited,
      'reviewCount': reviewCount,
      'reviewLikes': reviewLikes,
    };
  }
}
