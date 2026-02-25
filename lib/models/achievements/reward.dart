/// A reward granted when an achievement is completed.
///
/// Supported types:
///   - "theme"  : unlocks an explorer theme (value = theme key, e.g. "Forest")
///   - "badge"  : grants a profile badge  (value = badge identifier)
class Reward {
  final String type;
  final String value;

  Reward({required this.type, required this.value});

  Map<String, dynamic> toJson() => {'type': type, 'value': value};

  factory Reward.fromJson(Map<String, dynamic> json) => Reward(
        type: json['type'] as String,
        value: json['value'] as String,
      );
}
