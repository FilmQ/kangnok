import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../models/achievements/achievement.dart';

class AchievementService {
  final _db = FirebaseFirestore.instance;

  // สำหรับหน้า Ranger: ส่ง JSON ขึ้น Firestore
  Future<void> seedAchievements() async {
    final String response = await rootBundle.loadString('assets/achievements/achievements_data.json');
    final List<dynamic> data = json.decode(response);
    final batch = _db.batch();

    for (var item in data) {
      final docRef = _db.collection('achievements').doc(); 
      batch.set(docRef, item);
    }
    await batch.commit();
  }

  // สำหรับหน้า Explorer: ดึง Achievement ทั้งหมด
  Stream<List<Achievement>> getAchievementsStream() {
    return _db.collection('achievements').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Achievement.fromJson(doc.data())).toList();
    });
  }

  // ดึงสถิติของ User คนนั้นๆ
  Stream<Map<String, dynamic>> getUserProgressStream(String uid) {
  return _db.collection('users').doc(uid).snapshots().map((doc) {
    if (!doc.exists) return {'parkVisited': [], 'reviewCount': 0}; // คืนค่า Default ถ้าไม่เจอ User Doc
    return doc.data() as Map<String, dynamic>;
  });
  }

  /// 1. ลบ Achievement ทั้งหมดที่มีในคอลเลกชัน (มีประโยชน์มากเวลาจะ Re-seed ข้อมูล)
  Future<void> deleteAllAchievements() async {
    final collection = await _db.collection('achievements').get();
    final batch = _db.batch();

    for (final doc in collection.docs) {
      batch.delete(doc.reference);
    }

    return batch.commit();
  }

  /// 2. ลบ Achievement เฉพาะรายการ (ต้องใช้ Document ID)
  Future<void> deleteAchievementById(String docId) async {
    try {
      await _db.collection('achievements').doc(docId).delete();
    } catch (e) {
      throw Exception("Failed to delete achievement: $e");
    }
  }

  /// 3. (แนะนำเพิ่ม) ล้างและลงข้อมูลใหม่ในฟังก์ชันเดียว
  Future<void> resetAndSeedAchievements() async {
    await deleteAllAchievements(); // ลบของเก่าก่อน
    await seedAchievements();      // ลงของใหม่ตาม JSON
  }

  /// Claims an achievement for the user: records the title and applies the
  /// reward (theme unlock or badge) atomically on the user document.
  Future<void> claimAchievement(String uid, Achievement achievement) async {
    final userRef = _db.collection('users').doc(uid);
    final updates = <String, dynamic>{
      'completedAchievements': FieldValue.arrayUnion([achievement.title]),
    };

    final reward = achievement.reward;
    if (reward != null) {
      switch (reward.type) {
        case 'theme':
          updates['unlockedThemes'] = FieldValue.arrayUnion([reward.value]);
          break;
        case 'badge':
          updates['badges'] = FieldValue.arrayUnion([reward.value]);
          break;
      }
    }

    await userRef.update(updates);
  }
}