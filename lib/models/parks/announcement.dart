import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  String rangerId;
  String parkId;
  String title;
  String content;
  String type;
  DateTime createdAt;

  Announcement({
    required this.rangerId,
    required this.parkId,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'rangerId': rangerId,
    'parkId': parkId,
    'title': title,
    'content': content,
    'type': type,
    'createdAt': Timestamp.fromDate(createdAt),
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
