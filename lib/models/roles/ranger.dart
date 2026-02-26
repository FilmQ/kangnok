import 'package:kangnok/models/roles/user.dart';

class Ranger extends User {
  @override
  String get type => 'ranger';

  String _parkId;
  String _title;
  String? _profileImageUrl;

  Ranger({
    super.uid,
    required super.email,
    required String parkId,
    required String title,
    String? profileImageUrl,
  }) : _parkId = parkId,
       _title = title,
       _profileImageUrl = profileImageUrl;

  String get parkId => _parkId;
  String get title => _title;
  String? get profileImageUrl => _profileImageUrl;

  set parkId(String value) => _parkId = value;
  set title(String value) => _title = value;
  set profileImageUrl(String? value) => _profileImageUrl = value;

  @override
  Map<String, dynamic> toJson() => {
    // super
    'email': super.email,
    // this
    'type': 'ranger',
    'parkId': parkId,
    'title': title,
    'profileImageUrl': profileImageUrl,
  };

  factory Ranger.fromJson(Map<String, dynamic> json, {String? id}) => Ranger(
    uid: id,
    email: json['email'] as String,
    parkId: (json['parkId'] ?? json['parkStation']) as String,
    title: json['title'] as String,
    profileImageUrl: json['profileImageUrl'] as String?,
  );
}
