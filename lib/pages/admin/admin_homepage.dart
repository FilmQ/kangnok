import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kangnok/services/park_service.dart';
import 'package:kangnok/services/achievement_service.dart';

class AdminHomepage extends ConsumerStatefulWidget {
  const AdminHomepage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AdminHomepageState();
}

class _AdminHomepageState extends ConsumerState<AdminHomepage> {
  Widget _mainScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome admin."),
        actions: [
          IconButton(
            onPressed: FirebaseAuth.instance.signOut,
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: ParkService().seedParks, child: Text("Seed Parks")),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: AchievementService().seedAchievements, child: Text("Seed Achievements")),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: AchievementService().deleteAllAchievements, child: Text("Delete All Achievements")),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: AchievementService().resetAndSeedAchievements, child: Text("Reset Achievements")),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () {}, child: Text("Seed Rangers")),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/admin_create_ranger'), child: Text("Create ranger...")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _mainScreen();
  }


}
