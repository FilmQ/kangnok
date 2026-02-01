import 'package:kangnok/models/user.dart';

class Ranger extends User {
  String _parkStation;
  String _title;

  Ranger({
    required super.email,
    required super.passwordHash,
    required String parkStation,
    required String title,
  }) : _parkStation = parkStation,
       _title = title;

  String get parkStation => _parkStation;
  String get title => _title;

  set parkStation(String value) => _parkStation = value;
  set title(String value) => _title = value;

  Map<String, dynamic> toJson() => {
    // super
    'email': super.email,
    'passwordHash': super.passwordHash,
    // this
    'parkStation': parkStation,
    'title': title,
  };

  factory Ranger.fromJson(Map<String, dynamic> json) => Ranger(
    email: json['email'] as String,
    passwordHash: json['passwordHash'] as String,
    parkStation: json['parkStation'] as String,
    title: json['title'] as String,
  );
}
