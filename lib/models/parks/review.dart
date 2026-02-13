import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  String authorId;
  String parkId;
  String content;
  List<String> imageUrls;
  int likeCount;
  List<String> likedBy;
  DateTime createdAt;

  Review({
    required this.authorId,
    required this.parkId,
    required this.content,
    required this.imageUrls,
    required this.likeCount,
    required this.likedBy,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'authorId': authorId,
    'parkId': parkId,
    'content': content,
    'imageUrls': imageUrls,
    'likeCount': likeCount,
    'likedBy': likedBy,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    authorId: json['authorId'] as String,
    parkId: json['parkId'] as String,
    content: json['content'] as String,
    imageUrls: List<String>.from(json['imageUrls'] as List),
    likeCount: json['likeCount'] as int,
    likedBy: List<String>.from(json['likedBy'] as List),
    createdAt: (json['createdAt'] as Timestamp).toDate(),
  );
}
