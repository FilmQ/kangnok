import 'package:kangnok/models/achievement.dart';

abstract class User {
  String _email;
  String _passwordHash;
  List<Achievement> _achievements;

  User({
    required String email,
    required String passwordHash,
    required List<Achievement> achievements,
  }) : _email = email,
       _passwordHash = passwordHash,
       _achievements = achievements;

  String get email => _email;
  set email(String newEmail) => _email = newEmail;

  String get passwordHash => _passwordHash;
  set passwordHash(String newPasswordHash) => _passwordHash = newPasswordHash;

  List<Achievement> get achievements => _achievements;
  set achievements(List<Achievement> newAchievements) =>
      _achievements = newAchievements;

  // TODO: add more functionalities later
}
