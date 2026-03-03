import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kangnok/models/achievements/achievement.dart';
import 'package:kangnok/providers/achievement_provider.dart';
import 'package:kangnok/providers/theme_provider.dart';

/// Three visual states for each achievement card.
enum _AchState { locked, claimable, claimed }

class AchievementPage extends ConsumerWidget {
  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementsStreamProvider);
    final progressAsync = ref.watch(userProgressStreamProvider);
    final claimed = ref.watch(completedAchievementTitlesProvider);

    final themeData = ref.watch(explorerThemeDataProvider);

    return Scaffold(
      backgroundColor: themeData.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "My Achievements",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: themeData.appBarColor,
        foregroundColor: Colors.white,
      ),
      body: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (userProgress) {
          return achievementsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) {
              return Center(child: Text("Error: $e"));
            },
            data: (achievements) {
              if (achievements.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  final ach = achievements[index];
                  final unlocked = ach.isUnlocked(userProgress);
                  final isClaimed = claimed.contains(ach.title);

                  final _AchState state;
                  if (isClaimed) {
                    state = _AchState.claimed;
                  } else if (unlocked) {
                    state = _AchState.claimable;
                  } else {
                    state = _AchState.locked;
                  }

                  return _buildAchievementCard(context, ref, ach, state);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No achievements found in database",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            "Make sure you seeded the JSON file.",
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

  // --- Achievement card with three states: locked / claimable / claimed ---
  Widget _buildAchievementCard(
    BuildContext context,
    WidgetRef ref,
    Achievement ach,
    _AchState state,
  ) {
    final isActive = state != _AchState.locked;

    // Gradient colours per state
    final List<Color> gradientColors = switch (state) {
      _AchState.claimed => [Colors.white, Colors.blue.shade50],
      _AchState.claimable => [Colors.white, Colors.amber.shade50],
      _AchState.locked => [Colors.grey.shade50, Colors.grey.shade100],
    };

    final Color shadowColor = switch (state) {
      _AchState.claimed => Colors.blue.withValues(alpha: 0.1),
      _AchState.claimable => Colors.amber.withValues(alpha: 0.12),
      _AchState.locked => Colors.black.withValues(alpha: 0.03),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background watermark icon
          Positioned(
            right: -15,
            bottom: -15,
            child: Icon(
              isActive ? Icons.emoji_events : Icons.lock_person,
              size: 90,
              color: isActive
                  ? Colors.blue.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.02),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // 1. Thumbnail
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 5,
                            ),
                          ]
                        : [],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Colors.transparent,
                        BlendMode.multiply,
                      ),
                      child: const Icon(
                        Icons.military_tech,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // 2. Title, description, reward label
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ach.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isActive
                              ? Colors.blue.shade900
                              : Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ach.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isActive
                              ? Colors.blue.shade700
                              : Colors.grey.shade500,
                        ),
                      ),
                      if (ach.reward != null) ...[
                        const SizedBox(height: 6),
                        _buildRewardLabel(ach.reward!.type, ach.reward!.value),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // 3. Status area: icon or claim button
                _buildStatusArea(context, ref, ach, state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Small label showing the reward type + value (e.g. "Theme: Forest").
  Widget _buildRewardLabel(String type, String value) {
    final IconData icon;
    final String label;
    switch (type) {
      case 'theme':
        icon = Icons.palette_outlined;
        label = 'Theme: $value';
      case 'badge':
        icon = Icons.verified_outlined;
        label = 'Badge: $value';
      default:
        icon = Icons.card_giftcard;
        label = value;
    }

    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.amber.shade700),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.amber.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Right-side status: locked icon, claim button, or claimed checkmark.
  Widget _buildStatusArea(
    BuildContext context,
    WidgetRef ref,
    Achievement ach,
    _AchState state,
  ) {
    switch (state) {
      case _AchState.locked:
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded, color: Colors.grey.shade400, size: 30),
              const SizedBox(height: 4),
              Text(
                "LOCKED",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade400,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        );

      case _AchState.claimable:
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: ElevatedButton(
            onPressed: () => _onClaim(context, ref, ach),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              "Claim",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        );

      case _AchState.claimed:
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.blue, size: 30),
              const SizedBox(height: 4),
              Text(
                "CLAIMED",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        );
    }
  }

  Future<void> _onClaim(
    BuildContext context,
    WidgetRef ref,
    Achievement ach,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final service = ref.read(achievementServiceProvider);
    await service.claimAchievement(uid, ach);

    if (!context.mounted) return;

    final reward = ach.reward;
    final rewardText = reward != null
        ? 'You earned: ${reward.type == "theme" ? "Theme:" : "Badge:"} ${reward.value}'
        : 'Achievement completed!';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(rewardText),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }
}
