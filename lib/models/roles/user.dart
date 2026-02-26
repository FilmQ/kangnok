import 'package:kangnok/models/roles/explorer.dart';
import 'package:kangnok/models/roles/ranger.dart';
import 'package:kangnok/services/validator.dart';

/*
  This class contains the blueprint for both the explorers and rangers, not a lot
  is defined here to comply with Liskov Substitution.

  Firebase Auth handles authentication - we only store profile data here.
*/

abstract class User {
  late String _email;

  /// The Firestore document ID (Firebase Auth UID).
  /// Not serialized — it comes from the document ID, not the document data.
  String? uid;

  User({required String email, this.uid}) {
    if (!Validator.isValidEmail(email)) {
      throw ArgumentError("$email is not a valid email.");
    }
    _email = email;
  }

  String get email => _email;
  set email(String newEmail) {
    if (!Validator.isValidEmail(newEmail)) {
      throw ArgumentError("$newEmail is not a valid email.");
    }
    _email = newEmail;
  }

  /// Type discriminator for polymorphic serialization (explorer or ranger)?
  String get type;

  /// Subclasses must implement their own serialization
  Map<String, dynamic> toJson();
}

class UserFactory {
  static User fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'explorer':
        return Explorer.fromJson(json);
      case 'ranger':
        return Ranger.fromJson(json);
      default:
        throw ArgumentError("Unknown instance of: ${json['type']}");
    }
  }
}
