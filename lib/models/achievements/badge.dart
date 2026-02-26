import 'package:kangnok/models/achievements/reward.dart';

/// A badge reward displayed next to the user's profile display name.
class Badge extends Reward {
  final String imageUrl;

  Badge({required super.type, required super.value, required this.imageUrl});

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'imageUrl': imageUrl,
  };
}
