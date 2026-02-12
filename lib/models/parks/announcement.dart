import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  String _rangerId;
  String _parkId;
  String _title;
  String _content;
  String _type;
  DateTime _createdAt;

  Announcement({
    required String rangerId,
    required String parkId,
    required String title,
    required String content,
    required String type,
    required DateTime createdAt,
  })  : _rangerId = rangerId,
        _parkId = parkId,
        _title = title,
        _content = content,
        _type = type,
        _createdAt = createdAt;

  String get rangerId => _rangerId;
  String get parkId => _parkId;
  String get title => _title;
  String get content => _content;
  String get type => _type;
  DateTime get createdAt => _createdAt;

  set rangerId(String rangerId) => _rangerId = rangerId;
  set parkId(String parkId) => _parkId = parkId;
  set title(String title) => _title = title;
  set content(String content) => _content = content;
  set type(String type) => _type = type;
  set createdAt(DateTime createdAt) => _createdAt = createdAt;

  Map<String, dynamic> toJson() => {
    'rangerId': _rangerId,
    'parkId': _parkId,
    'title': _title,
    'content': _content,
    'type': _type,
    'createdAt': Timestamp.fromDate(_createdAt),
  };

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
    rangerId: json['rangerId'] as String,
    parkId: json['parkId'] as String,
    title: json['title'] as String,
    content: json['content'] as String,
    type: json['type'] as String,
    createdAt: (json['createdAt'] as Timestamp).toDate(),
  );
}
