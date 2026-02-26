import 'package:kangnok/models/achievements/badge.dart';
import 'package:kangnok/models/achievements/theme_reward.dart';

/// A reward granted when an achievement is completed.
///
/// Supported types:
///   - "theme"  : unlocks an explorer theme (value = theme key, e.g. "Forest")
///   - "badge"  : grants a profile badge  (value = badge identifier)
abstract class Reward {
  final String type;
  final String value;

  Reward({required this.type, required this.value});

  Map<String, dynamic> toJson() => {'type': type, 'value': value};
}

class RewardFactory {
  static Reward fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'badge':
        return Badge(
          type: json['type'],
          value: json['value'],
          imageUrl: json['imageUrl'],
        );
      case 'theme':
        return ThemeReward(
          type: json['type'],
          value: json['value'],
        );
      default:
        throw Exception("Cannot create a reward of type ${json['type']}");
    }
  }
}
