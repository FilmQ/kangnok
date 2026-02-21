import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kangnok/models/parks/announcement.dart';

class AnnouncementService {
  final CollectionReference announcements = FirebaseFirestore.instance
      .collection('announcements');

  // CREATE:
  Future<void> addAnnouncement(Announcement announcement) async {
    try {
      await announcements.add(announcement.toJson());
      print("Added an announcement to ${announcement.parkId}");
    } on FirebaseException catch (e) {
      print("Cannot properly add announcement due to: $e");
    }
  }

  // READ:
  Stream<QuerySnapshot> getAnnouncementStream() {
    return announcements.orderBy('createdAt').snapshots();
  }

  Stream<QuerySnapshot> getAnnouncementsFromPark(String parkId) {
    return announcements
        .where('parkId', isEqualTo: parkId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // UPDATE:
  Future<void> updateAnnouncement(
    String announcementId,
    Announcement announcement,
  ) async {
    try {
      await announcements.doc(announcementId).update(announcement.toJson());
    } on FirebaseException catch (e) {
      debugPrint("Cannot update announcement $announcementId: $e");
    }
  }

  // DELETE:
  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      await announcements.doc(announcementId).delete();
    } on FirebaseException catch (e) {
      debugPrint("Cannot delete announcement $announcementId: $e");
    }
  }
}
