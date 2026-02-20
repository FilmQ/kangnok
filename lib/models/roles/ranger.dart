import 'package:kangnok/models/roles/user.dart';

class Ranger extends User {
  @override
  String get type => 'ranger';

  String? id; // Firestore document ID (usually the Firebase Auth UID)
  String _parkId;
  String _title;

  Ranger({
    this.id,
    required super.email,
    required String parkId,
    required String title,
  }) : _parkId = parkId,
       _title = title;

  String get parkId => _parkId;
  String get title => _title;

  set parkId(String value) => _parkId = value;
  set title(String value) => _title = value;

  @override
  Map<String, dynamic> toJson() => {
    // super
    'email': super.email,
    // this
    'type': 'ranger',
    'parkId': parkId,
    'title': title,
  };

  factory Ranger.fromJson(Map<String, dynamic> json, {String? id}) => Ranger(
    id: id,
    email: json['email'] as String,
    parkId: (json['parkId'] ?? json['parkStation']) as String,
    title: json['title'] as String,
  );
}
