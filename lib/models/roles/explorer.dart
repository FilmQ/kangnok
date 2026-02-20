import 'package:kangnok/models/roles/user.dart';

class Explorer extends User {
  @override
  String get type => 'explorer';

  String _name;
  List<String> _parkVisited;
  int _reviewCount;
  int _reviewLikes;
  String? _bio;
  String? _profileImageUrl;

  Explorer({
    required super.email,
    required String name,
    required List<String> parkVisited,
    required int reviewCount,
    required int reviewLikes,
    String? bio,              
    String? profileImageUrl,  
  }) : _name = name,
       _parkVisited = parkVisited,
       _reviewCount = reviewCount,
       _reviewLikes = reviewLikes,
       _bio = bio,
       _profileImageUrl = profileImageUrl;

  String get name => _name;
  set name(String newName) => _name = newName;

  List<String> get parkVisited => _parkVisited;
  set parkVisited(List<String> newParkVisited) => _parkVisited = newParkVisited;

  int get reviewCount => _reviewCount;
  set reviewCount(int newReviewCount) => _reviewCount = newReviewCount;

  int get reviewLikes => _reviewLikes;
  set reviewLikes(int newReviewLikes) => _reviewLikes = newReviewLikes;

  String? get bio => _bio;
  set bio(String? newBio) => _bio = newBio;

  String? get profileImageUrl => _profileImageUrl;
  set profileImageUrl(String? newUrl) => _profileImageUrl = newUrl;

  factory Explorer.fromJson(Map<String, dynamic> json) {
    return Explorer(
      email: json['email'] as String,
      name: json['name'] as String,
      parkVisited: List<String>.from(json['parkVisited'] ?? []),
      reviewCount: json['reviewCount'] as int? ?? 0,
      reviewLikes: json['reviewLikes'] as int? ?? 0,
      bio: json['bio'] as String?,                     
      profileImageUrl: json['profileImageUrl'] as String?,   
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'explorer',
      'email': email,
      'name': name,
      'parkVisited': parkVisited,
      'reviewCount': reviewCount,
      'reviewLikes': reviewLikes,
      'bio': bio,                       
      'profileImageUrl': profileImageUrl, 
    };
  }
}
