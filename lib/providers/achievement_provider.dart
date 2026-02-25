import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kangnok/models/achievements/achievement.dart';
import 'package:kangnok/services/achievement_service.dart';

/// Service singleton for achievement operations (seed, delete, fetch).
final achievementServiceProvider =
    Provider<AchievementService>((ref) => AchievementService());

/// Streams all achievements defined in Firestore.
final achievementsStreamProvider =
    StreamProvider.autoDispose<List<Achievement>>((ref) {
  final service = ref.read(achievementServiceProvider);
  return service.getAchievementsStream();
});

/// Streams the current user's progress stats (parkVisited, reviewCount, etc.)
/// so achievement unlock status can be evaluated reactively.
/// This also contains completedAchievements, unlockedThemes, and badges
/// once they have been written by claimAchievement().
final userProgressStreamProvider =
    StreamProvider.autoDispose<Map<String, dynamic>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    return Stream.value({'parkVisited': [], 'reviewCount': 0, 'reviewLikes': 0});
  }
  final service = ref.read(achievementServiceProvider);
  return service.getUserProgressStream(uid);
});

/// Derives the set of achievement titles the current user has already claimed.
/// Reads from the same user doc stream so it stays in sync automatically.
final completedAchievementTitlesProvider =
    Provider.autoDispose<Set<String>>((ref) {
  final progress = ref.watch(userProgressStreamProvider).value ?? {};
  final list = progress['completedAchievements'] as List<dynamic>? ?? [];
  return list.cast<String>().toSet();
});
