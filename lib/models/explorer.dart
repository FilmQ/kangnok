import 'package:kangnok/models/user.dart';

class Explorer extends User {
  String _name;

  Explorer({
    required super.email,
    required super.passwordHash,
    required String name,
  }) : _name = name;

  String get name => _name;
  set name(String newName) => _name = newName;

  factory Explorer.fromJson(Map<String, dynamic> json) {
    return Explorer(
      email: json['email'] as String,
      passwordHash: json['passwordHash'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'passwordHash': passwordHash,
      'name': name,
    };
  }
}
