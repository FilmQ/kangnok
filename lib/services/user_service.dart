import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kangnok/models/explorer.dart';
import 'package:kangnok/models/ranger.dart';
import 'package:kangnok/models/user.dart';

/// Handles user persistence with Firestore.
///
/// Provides methods to save, retrieve, and create (empty) users 
/// (Explorer or Ranger)
/// in the 'users' collection. Uses [UserFactory] to deserialize users based
/// on their stored role type.
class UserService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firebaseFirestore.collection('users');

  Future<void> saveUser(String uid, User user) async {
    await _usersCollection.doc(uid).set(user.toJson());
  }

  Future<User?> getUser(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserFactory.fromJson(doc.data()!);
  }

  Future<User> createExplorer(String uid, String email, String name) async {
    final explorer = Explorer(
      email: email,
      name: name,
      parkVisited: [],
      reviewCount: 0,
      reviewLikes: 0,
    );
    await saveUser(uid, explorer);
    return explorer;
  }

  Future<User> createRanger(
    String uid,
    String email,
    String parkStation,
    String title,
  ) async {
    final ranger = Ranger(email: email, parkStation: parkStation, title: title);
    await saveUser(uid, ranger);
    return ranger;
  }
}
