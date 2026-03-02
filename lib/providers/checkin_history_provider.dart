import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final checkInHistoryProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, parkId) {
  return FirebaseFirestore.instance
      .collection('checkins')
      .where('parkId', isEqualTo: parkId) // กรองเฉพาะอุทยานของ Ranger คนนี้
      .orderBy('checkInTime', descending: true) // เอาล่าสุดขึ้นก่อน
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
});