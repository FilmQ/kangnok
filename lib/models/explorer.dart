import 'package:kangnok/models/user.dart';

class Explorer extends User {
  String _name;
  List<String> _parkVisited;
  int _likeCount;

  Explorer({
    required super.email,
    required super.passwordHash,
    required String name,
    required List<String> parkVisited,
    required int likeCount
  }) : _name = name,
       _parkVisited = parkVisited,
       _likeCount = likeCount;

  String get name => _name;
  set name(String newName) => _name = newName;

  List<String> get parkVisited => _parkVisited;
  set parkVisited(List<String> newParkVisited) => _parkVisited = newParkVisited;

  int get likeCount => _likeCount;
  set likeCount(int newLikeCount) => _likeCount = newLikeCount;

  factory Explorer.fromJson(Map<String, dynamic> json) {
    return Explorer(
      email: json['email'] as String,
      passwordHash: json['passwordHash'] as String,
      name: json['name'] as String,
      parkVisited: List<String>.from(json['parkVisited'] as List),
      likeCount: json['likeCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'passwordHash': passwordHash,
      'name': name,
      'parkVisited': parkVisited,
      'likeCount': likeCount,
    };
  }
}
