import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/achievements/achievement.dart';
import '../services/achievement_service.dart';

class AchievementPage extends StatelessWidget {
  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AchievementService service = AchievementService();
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    // กรณีไม่ได้ Login
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to see your achievements")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Achievements", 
          style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        // 1. ดึงข้อมูล Progress ของ User (สถิติ)
        stream: service.getUserProgressStream(uid),
        builder: (context, userSnapshot) {
          // หากไม่มีข้อมูลใน Firestore หรือโหลดอยู่ ให้ใช้ค่าเริ่มต้นป้องกัน Error
          final userProgress = userSnapshot.data ?? {
            'parkVisited': [],
            'reviewCount': 0,
            'reviewLikes': 0
          };

          return StreamBuilder<List<Achievement>>(
            // 2. ดึงรายการ Achievement จาก Firestore
            stream: service.getAchievementsStream(),
            builder: (context, achSnapshot) {
              // สถานะกำลังโหลดข้อมูล
              if (achSnapshot.connectionState == ConnectionState.waiting && !achSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              // สถานะเกิด Error
              if (achSnapshot.hasError) {
                return Center(child: Text("Error: ${achSnapshot.error}"));
              }

              // ดึงข้อมูล List (ถ้าไม่มีใน DB เลยจะส่งค่าว่าง [])
              final List<Achievement> displayList = achSnapshot.data ?? [];

              // 3. กรณีไม่มีข้อมูลใน Firestore (Blank State)
              if (displayList.isEmpty) {
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

              // 4. แสดงรายการแบบ Horizontal ตามจริงจาก Firestore
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  final ach = displayList[index];
                  // ตรวจสอบเงื่อนไขการปลดล็อก
                  final bool unlocked = ach.isUnlocked(userProgress);
                  return _buildHorizontalAchievementCard(ach, unlocked);
                },
              );
            },
          );
        },
      ),
    );
  }

  // --- ส่วนประกอบ UI ของเหรียญแต่ละใบ (Horizontal Card) ---
  Widget _buildHorizontalAchievementCard(Achievement ach, bool unlocked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: unlocked 
            ? [Colors.white, Colors.blue.shade50] 
            : [Colors.grey.shade50, Colors.grey.shade100],
        ),
        boxShadow: [
          BoxShadow(
            color: unlocked 
                ? Colors.blue.withOpacity(0.1) 
                : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ไอคอนตกแต่งพื้นหลังจางๆ
          Positioned(
            right: -15,
            bottom: -15,
            child: Icon(
              unlocked ? Icons.emoji_events : Icons.lock_person,
              size: 90,
              color: unlocked ? Colors.blue.withOpacity(0.05) : Colors.black.withOpacity(0.02),
            ),
          ),
          
          Row(
            children: [
              // 1. ส่วนรูปภาพ
              Container(
                width: 90,
                height: 90,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: unlocked ? Colors.white : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: unlocked ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)] : [],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                child: ColorFiltered(
                    colorFilter: unlocked 
                        ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                        : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                    child: Image.network(
                      ach.thumbnail,
                      fit: BoxFit.cover, 
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                      },
                      errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.military_tech, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
              ),

              // 2. ส่วนเนื้อหา
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ach.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: unlocked ? Colors.blue.shade900 : Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ach.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: unlocked ? Colors.blue.shade700 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. ส่วนสถานะ
              Padding(
                padding: const EdgeInsets.only(right: 20, left: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      unlocked ? Icons.check_circle_rounded : Icons.lock_rounded,
                      color: unlocked ? Colors.blue : Colors.grey.shade400,
                      size: 30,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      unlocked ? "DONE" : "LOCKED",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: unlocked ? Colors.blue : Colors.grey.shade400,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}