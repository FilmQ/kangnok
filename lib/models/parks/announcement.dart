import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  String? id; // Firestore document ID (null when creating, populated on fetch)
  String rangerId;
  String parkId;
  String title;
  String content;
  String type;
  String? imageUrl;
  DateTime createdAt;

  Announcement({
    this.id,
    required this.rangerId,
    required this.parkId,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'rangerId': rangerId,
    'parkId': parkId,
    'title': title,
    'content': content,
    'type': type,
    'createdAt': Timestamp.fromDate(createdAt),
    if (imageUrl != null) 'imageUrl': imageUrl,
  };

  factory Announcement.fromJson(Map<String, dynamic> json, {String? id}) =>
      Announcement(
        id: id,
        rangerId: json['rangerId'] as String,
        parkId: json['parkId'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        type: json['type'] as String,
        createdAt: (json['createdAt'] as Timestamp).toDate(),
        imageUrl: json['imageUrl'] as String?,
      );
}
