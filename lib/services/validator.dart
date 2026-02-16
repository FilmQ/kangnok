/// A class for all your validation need, expand the utility if you wish so.
class Validator {
  // Validate email using Email's normal regex form.
  static bool isValidEmail(String emailToValidate) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(emailToValidate);
  }

  static bool isRangerEmail(String emailToValidate) {
    final RegExp rangerEmail = RegExp(r'^[a-zA-Z0-9._%+-]+@dnp\.th$');
    return rangerEmail.hasMatch(emailToValidate);
  }

  static const List<String> _explorerBlacklistedDomains = ['dnp.th'];

  static bool isExplorerBlacklistedEmail(String emailToValidate) {
    final domain = emailToValidate.split('@').last.toLowerCase();
    return _explorerBlacklistedDomains.contains(domain);
  }
}