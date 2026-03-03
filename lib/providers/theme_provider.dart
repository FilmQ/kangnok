//                Explorer Theme Provider Chain:
//
//     explorerThemeProvider (holds theme name, e.g. "Forest")
//                          |
//     explorerThemeDataProvider (resolves name -> colors)
//
// Usage:
//   // Read colors in any ConsumerWidget/ConsumerState:
//   final theme = ref.watch(explorerThemeDataProvider);
//   Scaffold(backgroundColor: theme.backgroundColor, ...)
//
//   // Change theme:
//   ref.read(explorerThemeProvider.notifier).setTheme("Ocean");
//
//   // Add a new theme: add an entry to [explorerThemes] map below.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kangnok/providers/achievement_provider.dart';
import 'package:kangnok/providers/explorer_profile_provider.dart';

class ExplorerThemeData {
  final Color backgroundColor;
  final Color appBarColor;
  final Color textColor;

  const ExplorerThemeData({
    required this.backgroundColor,
    required this.appBarColor,
    this.textColor = Colors.black,
  });
}

const Map<String, ExplorerThemeData> explorerThemes = {
  "Default": ExplorerThemeData(
    backgroundColor: Colors.white,
    appBarColor: Colors.blue,
  ),
  "Forest": ExplorerThemeData(
    backgroundColor: Colors.green,
    appBarColor: Color(0xFF1B5E20),
    textColor: Colors.white,
  ),
  "Ocean": ExplorerThemeData(
    backgroundColor: Color(0xFFE3F2FD),
    appBarColor: Color(0xFF0D47A1),
  ),
  "Starry": ExplorerThemeData(
    appBarColor: Color.fromARGB(95, 104, 0, 240),
    backgroundColor: Color.fromARGB(255, 34, 23, 58),
    textColor: Colors.white,
  ),
  "Cherry": ExplorerThemeData(
    appBarColor: Color.fromARGB(255, 171, 79, 159),
    backgroundColor: Color.fromARGB(255, 237, 135, 208),
  ),
};

class ExplorerThemeNotifier extends Notifier<String> {
  @override
  String build() {
    final explorer = ref.watch(explorerProfileProvider).value;
    return explorer?.selectedTheme ?? "Default";
  }

  void setTheme(String theme) {
    state = theme;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      FirebaseFirestore.instance.collection('users').doc(uid).update({
        'selectedTheme': theme,
      });
    }
  }
}

final explorerThemeProvider = NotifierProvider<ExplorerThemeNotifier, String>(
  ExplorerThemeNotifier.new,
);

final explorerThemeDataProvider = Provider<ExplorerThemeData>((ref) {
  final themeName = ref.watch(explorerThemeProvider);
  return explorerThemes[themeName] ?? explorerThemes["Default"]!;
});

/// Themes available to the current user: "Default" is always included,
/// plus any themes unlocked via achievements and the currently selected theme
/// (so the DropdownButton never crashes from a missing value).
final unlockedThemeNamesProvider = Provider.autoDispose<Set<String>>((ref) {
  final progress = ref.watch(userProgressStreamProvider).value ?? {};
  final unlocked = progress['unlockedThemes'] as List<dynamic>? ?? [];
  final selected = ref.watch(explorerThemeProvider);
  return {"Default", "Starry", selected, ...unlocked.cast<String>()};
});
