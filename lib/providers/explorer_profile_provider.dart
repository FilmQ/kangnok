import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kangnok/models/roles/explorer.dart';

final explorerProfileProvider = StreamProvider.autoDispose<Explorer?>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists || snapshot.data() == null) return null;
    final explorer = Explorer.fromJson(snapshot.data()!);
    explorer.uid = snapshot.id;
    return explorer;
  });
});