/// A class for all your validation need, expand the utility if you wish so.
class Validator {
  // Validate email using Email's normal regex form.
  static bool isValidEmail(String emailToValidate) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(emailToValidate);
  }
}