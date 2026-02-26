import 'package:kangnok/models/achievements/reward.dart';
import 'package:kangnok/providers/theme_provider.dart';

/// A theme reward that changes the application's theme when unlocked.
///
/// [value] acts as the theme key (e.g. "Forest", "Ocean") and must
/// correspond to an entry in the [explorerThemes] map.
class ThemeReward extends Reward {
  ThemeReward({required super.type, required super.value});

  /// Resolves this reward's theme key to the concrete [ExplorerThemeData].
  ExplorerThemeData? get themeData => explorerThemes[value];
}
