import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kangnok/models/parks/review.dart';

class ReviewService {
  final CollectionReference collections = FirebaseFirestore.instance.collection(
    'reviews',
  );

  // CREATE:
  Future<void> createReview(Review review) async {
    try {
      await collections.add(review.toJson());
      debugPrint("Successfully added a review!");
    } on FirebaseException catch (e) {
      debugPrint("An error occured: $e");
    }
  }

  // READ:
  Stream<QuerySnapshot> getReviews() {
    return collections.orderBy('createdAt', descending: false).snapshots();
  }

  Stream<QuerySnapshot> getReviewsFromPark(String parkId) {
    return collections
        .where("parkId", isEqualTo: parkId)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  // UPDATE:
  Future<void> updateReview(String reviewId, Review review) async {
    try {
      await collections.doc(reviewId).update(review.toJson());
    } on FirebaseException catch (e) {
      debugPrint("Cannot update review due to: $e");
    }
  }

  // LIKE/UNLIKE:
  Future<void> toggleLike(String reviewId, String uid) async {
    try {
      final doc = await collections.doc(reviewId).get();
      final data = doc.data() as Map<String, dynamic>?;
      final likedBy = List<String>.from(data?['likedBy'] ?? []);

      if (likedBy.contains(uid)) {
        await collections.doc(reviewId).update({
          'likeCount': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([uid]),
        });
      } else {
        await collections.doc(reviewId).update({
          'likeCount': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([uid]),
        });
      }
    } on FirebaseException catch (e) {
      debugPrint("Cannot toggle like due to: $e");
    }
  }

  // DELETE:
  Future<void> deleteReview(String reviewId) async {
    try {
      await collections.doc(reviewId).delete();
    } on FirebaseException catch (e) {
      debugPrint("Cannot delete review due to: $e");
    }
  }
}
