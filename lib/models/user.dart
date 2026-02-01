import 'package:kangnok/services/validator.dart';

/*
  This class contains the blueprint for both the explorers and rangers, not a lot
  is defined here to comply with Liskov Substitution 
  aside from the email and passwordHash that both has in common.
*/

abstract class User {
  late String _email;
  late String _passwordHash;

  User({required String email, required String passwordHash}) {
    if (!Validator.isValidEmail(email)) {
      throw ArgumentError("$email is not a valid email.");
    }
    _email = email;
    _passwordHash = passwordHash;
  }

  String get email => _email;
  set email(String newEmail) => _email = newEmail;

  String get passwordHash => _passwordHash;
  set passwordHash(String newPasswordHash) => _passwordHash = newPasswordHash;
}
