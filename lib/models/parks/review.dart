import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  String _authorId;
  String _parkId;
  String _content;
  List<String> _imageUrls;
  int _likeCount;
  List<String> _likedBy;
  DateTime _createdAt;

  Review({
    required String authorId,
    required String parkId,
    required String content,
    required List<String> imageUrls,
    required int likeCount,
    required List<String> likedBy,
    required DateTime createdAt,
  })  : _authorId = authorId,
        _parkId = parkId,
        _content = content,
        _imageUrls = imageUrls,
        _likeCount = likeCount,
        _likedBy = likedBy,
        _createdAt = createdAt;

  String get authorId => _authorId;
  String get parkId => _parkId;
  String get content => _content;
  List<String> get imageUrls => _imageUrls;
  int get likeCount => _likeCount;
  List<String> get likedBy => _likedBy;
  DateTime get createdAt => _createdAt;

  set authorId(String authorId) => _authorId = authorId;
  set parkId(String parkId) => _parkId = parkId;
  set content(String content) => _content = content;
  set imageUrls(List<String> imageUrls) => _imageUrls = imageUrls;
  set likeCount(int likeCount) => _likeCount = likeCount;
  set likedBy(List<String> likedBy) => _likedBy = likedBy;
  set createdAt(DateTime createdAt) => _createdAt = createdAt;

  Map<String, dynamic> toJson() => {
    'authorId': _authorId,
    'parkId': _parkId,
    'content': _content,
    'imageUrls': _imageUrls,
    'likeCount': _likeCount,
    'likedBy': _likedBy,
    'createdAt': Timestamp.fromDate(_createdAt),
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
