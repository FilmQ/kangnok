import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  String? id; 
  String authorId;
  String authorName;
  String parkId;
  String content;
  List<String>? imageUrls;
  int likeCount;
  List<String> likedBy;
  DateTime createdAt;

  Review({
    this.id,
    required this.authorId,
    required this.authorName,
    required this.parkId,
    required this.content,
    this.imageUrls,
    required this.likeCount,
    required this.likedBy,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'authorId': authorId,
    'authorName': authorName,
    'parkId': parkId,
    'content': content,
    'imageUrls': imageUrls,
    'likeCount': likeCount,
    'likedBy': likedBy,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory Review.fromJson(Map<String, dynamic> json, {String? id}) => Review(
    id: id,
    authorId: json['authorId'] as String,
    authorName: json['authorName'] as String,
    parkId: json['parkId'] as String,
    content: json['content'] as String,
    imageUrls: json['imageUrls'] != null
        ? List<String>.from(json['imageUrls'] as List)
        : null,
    likeCount: json['likeCount'] as int,
    likedBy: List<String>.from(json['likedBy'] as List),
    createdAt: (json['createdAt'] as Timestamp).toDate(),
  );
}
