import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kangnok/models/roles/explorer.dart';
import 'package:kangnok/models/roles/ranger.dart';
import 'package:kangnok/models/roles/user.dart';

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

  Future<User?> getUser(String uid, {String? email}) async {
    final doc = await _usersCollection.doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserFactory.fromJson(doc.data()!);
    }

    // Fallback: query by email if UID lookup fails (e.g. after account recreation)
    if (email != null && email.isNotEmpty) {
      final query = await _usersCollection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        // Update the document to use the new UID
        final data = query.docs.first.data();
        await _usersCollection.doc(uid).set(data);
        await _usersCollection.doc(query.docs.first.id).delete();
        return UserFactory.fromJson(data);
      }
    }

    return null;
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
    String parkId,
    String title,
  ) async {
    final ranger = Ranger(email: email, parkId: parkId, title: title);
    await saveUser(uid, ranger);
    return ranger;
  }
}
