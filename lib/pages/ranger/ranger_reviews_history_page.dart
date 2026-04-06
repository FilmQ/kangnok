import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kangnok/providers/ranger_profile_provider.dart';
import 'package:kangnok/models/parks/review.dart';

class RangerReviewsHistoryPage extends ConsumerWidget {
  const RangerReviewsHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rangerAsync = ref.watch(rangerProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorer Reviews', style: TextStyle(fontWeight: FontWeight.bold)),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.green],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: rangerAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
          error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.white))),
          data: (ranger) {
            if (ranger == null) return const Center(child: Text("No Ranger Data", style: TextStyle(color: Colors.white)));

            // Query: ดึงรีวิวตาม parkId ของ Ranger
            final reviewsStream = FirebaseFirestore.instance
                .collection('reviews')
                .where('parkId', isEqualTo: ranger.parkId)
                .orderBy('createdAt', descending: true)
                .snapshots();

            return StreamBuilder<QuerySnapshot>(
              stream: reviewsStream,
              builder: (context, snapshot) {
                // 1. เช็ค Error ก่อนเลย สำคัญมาก!
                if (snapshot.hasError) {
                  // ถ้าพังเพราะเรื่อง Index จะได้เห็นข้อความที่หน้าจอเลย
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Error: ${snapshot.error}", 
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                // 2. เช็คสถานะ Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                
                // 3. ป้องกันกรณีไม่มี data
                if (!snapshot.hasData) {
                  return _buildEmptyState();
                }
                
                // 4. เช็คว่ามีข้อมูลรีวิวหรือไม่
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return _buildEmptyState();
                }

                // 5. มีข้อมูล ก็แสดง ListView ปกติ
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final review = Review.fromJson(
                      docs[index].data() as Map<String, dynamic>,
                      id: docs[index].id,
                    );
                    return _buildReviewCard(review);
                  },
                );
              },
            );
          },
      ),
    );
  }

  // --- การ์ดแสดงรีวิวแต่ละใบ ---
  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ชื่อคนรีวิว + วันที่
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple[100],
              child: Text(review.authorName[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text(review.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(DateFormat('dd MMM yyyy HH:mm').format(review.createdAt)),
          ),

          // Content: ข้อความรีวิว
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(review.content, style: const TextStyle(fontSize: 15, height: 1.4)),
          ),

          // Images: ถ้ามีรูปภาพ ให้แสดงเป็น Horizontal List
          if (review.imageUrls != null && review.imageUrls!.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemCount: review.imageUrls!.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(review.imageUrls![i], width: 120, height: 120, fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ),

          // Footer: แสดงยอด Like
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 20),
                const SizedBox(width: 6),
                Text(
                  "${review.likeCount} Likes",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.speaker_notes_off, size: 80, color: Colors.white54),
          SizedBox(height: 16),
          Text("No reviews for your park yet.", style: TextStyle(color: Colors.white, fontSize: 18)),
        ],
      ),
    );
  }
}