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
    print("Seed Achievements Success!");
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
}