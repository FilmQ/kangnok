import 'package:kangnok/models/achievements/reward.dart';

/// A theme reward that changes the application's theme when unlocked.
///
/// [value] acts as the theme key (e.g. "Forest", "Ocean").
class ThemeReward extends Reward {
  ThemeReward({required super.type, required super.value});
}
