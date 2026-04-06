import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide User; // ซ่อน User ของ Firebase ไม่ให้ชนกับ Model ของคุณ
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kangnok/models/achievements/achievement.dart';
import 'package:kangnok/models/achievements/badge.dart';
import 'package:kangnok/providers/achievement_provider.dart';
import 'package:kangnok/providers/theme_provider.dart';
import 'package:kangnok/providers/explorer_profile_provider.dart';

class ExplorerProfilePage extends ConsumerStatefulWidget {
  const ExplorerProfilePage({super.key});

  @override
  ConsumerState<ExplorerProfilePage> createState() =>
      _ExplorerProfilePageState();
}

class _ExplorerProfilePageState extends ConsumerState<ExplorerProfilePage> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _firebaseStorage = FirebaseStorage.instance.ref();

  // ฟังก์ชันอัปเดตข้อมูล (ไม่ต้องใช้ setState แล้ว เพราะ Riverpod จะจัดการให้)
  Future<void> _updateProfileData(String field, String value) async {
    if (uid == null) return;
    try {
      await _db.collection('users').doc(uid).update({field: value});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null || uid == null) return;

    setState(() => _profileImage = File(picked.path));

    // save to firestore and save the url to firestore
    try {
      final storageRef = _firebaseStorage.child('profile_pics/$uid.jpg');
      await storageRef.putFile(_profileImage!);
      final downloadUrl = await storageRef.getDownloadURL();
      await _db.collection('users').doc(uid).update({
        'profileImageUrl': downloadUrl,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!')),
        );
      }
    } on FirebaseException catch (e) {
      debugPrint("Cannot store profile picture: $e");
    }
  }

  Future<void> _editField({
    required String title,
    required String dbField,
    required String currentValue,
  }) async {
    final controller = TextEditingController(text: currentValue);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Edit $title"),
        content: TextField(
          controller: controller,
          maxLines: title == "Bio" ? 3 : 1,
          decoration: InputDecoration(
            hintText: "Enter your $title",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    // หากพิมพ์ข้อมูลใหม่และกดยืนยัน ให้อัปเดตขึ้น Firestore ทันที
    if (result != null && result.isNotEmpty && result != currentValue) {
      await _updateProfileData(dbField, result);
    }
  }

  void _showBadgeDetail(
    BuildContext context, {
    required Badge badge,
    required Achievement achievement,
    required bool isOwned,
    required String effectiveUrl,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: effectiveUrl.startsWith('http')
                  ? Image.network(effectiveUrl, fit: BoxFit.contain)
                  : Image.asset(effectiveUrl, fit: BoxFit.contain),
            ),
            const SizedBox(height: 16),
            Text(
              badge.value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              achievement.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isOwned ? Colors.green.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isOwned ? "Owned" : "Not yet earned",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isOwned ? Colors.green.shade700 : Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeName = ref.watch(explorerThemeProvider);
    final themeData = ref.watch(explorerThemeDataProvider);
    final profileAsyncValue = ref.watch(explorerProfileProvider);
    final achievementsAsync = ref.watch(achievementsStreamProvider);
    final unlockedThemes = ref.watch(unlockedThemeNamesProvider);

    debugPrint('[PROFILE] build() called');
    debugPrint('[PROFILE] themeName: $themeName');
    debugPrint('[PROFILE] unlockedThemes: $unlockedThemes');
    debugPrint('[PROFILE] profileAsyncValue: $profileAsyncValue');
    debugPrint('[PROFILE] achievementsAsync state: ${achievementsAsync.isLoading ? "loading" : achievementsAsync.hasError ? "error: ${achievementsAsync.error}" : "data(${achievementsAsync.value?.length} items)"}');

    if (uid == null) {
      return const Scaffold(body: Center(child: Text("Please log in first.")));
    }

    return Scaffold(
      backgroundColor: themeData.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeData.appBarColor,
        foregroundColor: Colors.white,
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: profileAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (explorer) {
          if (explorer == null) {
            return const Center(child: Text("Profile data not found."));
          }

          // จัดการค่าเริ่มต้นในกรณีที่ไม่มีข้อมูล
          final String displayName = explorer.name.isNotEmpty
              ? explorer.name
              : "New Explorer";
          final String bioText = explorer.bio?.isNotEmpty == true
              ? explorer.bio!
              : "Nature enthusiast and wildlife photographer. Love exploring national parks.";

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                // --- 1. Profile Avatar ---
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 65,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : (explorer.profileImageUrl != null
                                    ? NetworkImage(explorer.profileImageUrl!)
                                          as ImageProvider
                                    : null),
                          child:
                              (_profileImage == null &&
                                  explorer.profileImageUrl == null)
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: themeData.appBarColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // --- 2. Display Name ---
                Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior
                        .opaque, // ช่วยให้กดติดง่ายขึ้นแม้จะกดโดนช่องว่าง
                    onTap: () => _editField(
                      title: "Name",
                      dbField: "name",
                      currentValue: displayName,
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min, // ให้แถวมีขนาดเท่าที่จำเป็น
                      children: [
                        // Fake Icon for padding
                        Opacity(
                          opacity: 0,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.edit_rounded, size: 20),
                          ),
                        ),

                        Flexible(
                          child: Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: themeData.textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.edit_rounded,
                            size: 20,
                            color: themeData.textColor.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // --- 3. Bio Card ---
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "About Me",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _editField(
                                title: "Bio",
                                dbField: "bio",
                                currentValue: bioText, // โยนค่าจริงจาก Provider
                              ),
                              icon: Icon(
                                Icons.edit_note,
                                color: Colors.grey.shade600,
                              ),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          bioText,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // --- 4. Stats & Settings Card ---
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.park_rounded,
                            color: Colors.green,
                          ),
                        ),
                        title: const Text(
                          "Parks Visited",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: Text(
                          "${explorer.parkVisited.length}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const Divider(height: 1, indent: 60),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.palette_rounded,
                            color: Colors.deepPurple,
                          ),
                        ),
                        title: const Text(
                          "App Theme",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: themeName,
                            alignment: Alignment.centerRight,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            onChanged: (value) {
                              if (value != null) {
                                ref
                                    .read(explorerThemeProvider.notifier)
                                    .setTheme(value);
                              }
                            },
                            items: ref
                                .watch(unlockedThemeNamesProvider)
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(
                                      t,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // -- 4. Badge Zone ---
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Badges",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        achievementsAsync.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (e, _) =>
                              const Text("Could not load badges."),
                          data: (achievements) {
                            debugPrint('[PROFILE] achievements loaded: ${achievements.length}');
                            for (final a in achievements) {
                              debugPrint('[PROFILE] achievement: "${a.title}", reward type: ${a.reward?.type}, reward runtimeType: ${a.reward.runtimeType}');
                              if (a.reward?.type == 'badge') {
                                final badge = a.reward as Badge;
                                debugPrint('[PROFILE]   badge imageUrl: "${badge.imageUrl}"');
                              }
                            }
                            final badgeAchievements = achievements
                                .where((a) => a.reward?.type == 'badge')
                                .toList();

                            if (badgeAchievements.isEmpty) {
                              return const Text("No badges available yet.");
                            }

                            final ownedValues = explorer.badges
                                .map((b) => b.value)
                                .toSet();

                            return GridView.count(
                              crossAxisCount: 5,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              children: badgeAchievements.map((ach) {
                                final badge = ach.reward as Badge;
                                final isOwned =
                                    ownedValues.contains(badge.value);
                                final effectiveUrl = badge.imageUrl.isEmpty
                                    ? 'assets/achievements/badges/badge.png'
                                    : badge.imageUrl;
                                Widget img = effectiveUrl.startsWith('http')
                                    ? Image.network(
                                        effectiveUrl,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, _, _) =>
                                            const Icon(Icons.verified, size: 32),
                                      )
                                    : Image.asset(
                                        effectiveUrl,
                                        fit: BoxFit.contain,
                                      );
                                if (!isOwned) {
                                  img = ColorFiltered(
                                    colorFilter: const ColorFilter.matrix(
                                      <double>[
                                        0.2126, 0.7152, 0.0722, 0, 0,
                                        0.2126, 0.7152, 0.0722, 0, 0,
                                        0.2126, 0.7152, 0.0722, 0, 0,
                                        0,      0,      0,      1, 0,
                                      ],
                                    ),
                                    child: img,
                                  );
                                }
                                return GestureDetector(
                                  onTap: () => _showBadgeDetail(
                                    context,
                                    badge: badge,
                                    achievement: ach,
                                    isOwned: isOwned,
                                    effectiveUrl: effectiveUrl,
                                  ),
                                  child: img,
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                // --- 5. Logout Button ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
