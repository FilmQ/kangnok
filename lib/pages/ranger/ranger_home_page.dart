import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kangnok/pages/ranger/ranger_post_announcement_page.dart';
import 'package:kangnok/pages/ranger/ranger_reviews_history_page.dart';
import 'package:kangnok/providers/ranger_profile_provider.dart';
import 'package:kangnok/models/roles/ranger.dart';

class RangerHomePage extends ConsumerWidget {
  const RangerHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rangerAsync = ref.watch(rangerProfileProvider);
    final parkNameAsync = ref.watch(rangerParkNameProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Ranger Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, "/ranger_profile_page"),
            icon: Icon(Icons.person),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              onTap: () => _showLogoutConfirmDialog(context),
              child: Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                child: Icon(Icons.logout_sharp, size: 40),
              ),
            ),
          ),
        ],
      ),
      body: rangerAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.green)),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (ranger) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRangerHeader(
                    ranger,
                    parkNameAsync.maybeWhen(
                      data: (name) => name,
                      orElse: () => "Loading...",
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    "Park Management",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActionCards(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- ฟังก์ชันแสดง Popup ยืนยันการออกจากระบบ ---
  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(), // ปิด Popup
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                // ปิด Popup ก่อน
                Navigator.of(dialogContext).pop();

                // สั่ง Sign out จาก Firebase
                await FirebaseAuth.instance.signOut();

                // เด้งกลับไปหน้า Login และเคลียร์ประวัติหน้าจอ (ปรับชื่อ Route ตามของคุณได้เลย)
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  // --- ส่วน Header แสดงโปรไฟล์ของ Ranger ---
  Widget _buildRangerHeader(Ranger? ranger, String parkName) {
    if (ranger == null) return const SizedBox();

    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.green[100],
          backgroundImage: ranger.profileImageUrl != null
              ? NetworkImage(ranger.profileImageUrl!)
              : null,
          child: ranger.profileImageUrl == null
              ? Icon(Icons.shield, color: Colors.green[700], size: 30)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back,",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              Text(
                ranger.title.isNotEmpty ? ranger.title : "Park Ranger",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Station: $parkName",
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- ส่วนของ List Cards ---
  Widget _buildActionCards(BuildContext context) {
    return Column(
      children: [
        _menuCard(
          title: "Park Update",
          subtitle: "Update status, capacity, and current weather",
          icon: Icons.edit_location_alt,
          gradientColors: [Colors.orange, Colors.red],
          onTap: () {
            /* Navigate */
          },
        ),
        const SizedBox(height: 16),

        _menuCard(
          title: "Post Announcement",
          subtitle: "Broadcast news, alerts, and events to explorers",
          icon: Icons.campaign,
          gradientColors: [Colors.yellow.shade600, Colors.orange],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RangerPostAnnouncementPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        _menuCard(
          title: "Explorers's Reviews",
          subtitle: "Check explorer's reviews and experiences of the park",
          icon: Icons.comment_rounded,
          gradientColors: [Colors.lightGreen, Colors.blue],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RangerReviewsHistoryPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        _menuCard(
          title: "Check-In History",
          subtitle: "View recent visitor logs and submitted reports",
          icon: Icons.fact_check,
          gradientColors: [Colors.indigo, Colors.purple],
          onTap: () {
            /* Navigate */
          },
        ),
      ],
    );
  }

  // --- Template สำหรับการ์ดแต่ละใบ ---
  Widget _menuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors, // รับค่าสีตรงนี้
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors, // นำสีที่รับมาไปใช้
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3), // ใช้สีแรกเป็นเงา
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.8),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
