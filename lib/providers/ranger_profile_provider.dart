import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kangnok/models/roles/ranger.dart';

final rangerProfileProvider = StreamProvider.autoDispose<Ranger?>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists || snapshot.data() == null) return null;
    return Ranger.fromJson(snapshot.data()!, id: snapshot.id);
  });
});

final rangerParkNameProvider = FutureProvider.autoDispose<String>((ref) async {
  // .future จะรอจนกว่า stream ของ rangerProfileProvider ดึงข้อมูลเสร็จ
  final ranger = await ref.watch(rangerProfileProvider.future);
  
  // ถ้าไม่มีข้อมูล Ranger ให้คืนค่า Default
  if (ranger == null || ranger.parkId.isEmpty) {
    return "Unknown Station";
  }

  // เอา parkId ไปดึงชื่ออุทยานจาก Firestore แค่ครั้งเดียว
  final parkDoc = await FirebaseFirestore.instance
      .collection('parks')
      .doc(ranger.parkId)
      .get();

  if (parkDoc.exists && parkDoc.data() != null) {
    return parkDoc.data()!['name'] ?? "Unknown Station";
  }
  
  return "Unknown Station";
});