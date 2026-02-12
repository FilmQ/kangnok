import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'explorer_add_post_page.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Explorer Community",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      
      // ปุ่มลอย (Floating Action Button) สำหรับกดโพสต์รูปได้ง่ายขึ้น
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddPost(),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),

      body: StreamBuilder<QuerySnapshot>(
        // ดึงข้อมูลจาก Firestore collection 'posts'
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true) // เรียงลำดับจากใหม่ไปเก่า
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs;

          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text("No posts yet. Be the first explorer!",
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var postData = posts[index].data() as Map<String, dynamic>;
              return _buildPostCard(postData);
            },
          );
        },
      ),
    );
  }

  // ฟังก์ชันนำทางไปหน้า Add Post
  void _navigateToAddPost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPostPage()), // ชื่อ Class หน้า Add Post ของคุณ
    );
  }

  // ส่วนประกอบของการ์ดโพสต์แต่ละอัน
  Widget _buildPostCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. User Info Header
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent.withOpacity(0.1),
              child: const Icon(Icons.person, color: Colors.blueAccent),
            ),
            title: Text(
              data['userName'] ?? "Explorer",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              data['createdAt'] != null
                  ? _formatTimestamp(data['createdAt'] as Timestamp)
                  : "Just now",
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.more_horiz),
          ),

          // 2. Post Image
          GestureDetector(
            onDoubleTap: () {
              // เพิ่มฟีเจอร์ Like เมื่อดับเบิลคลิกที่รูปได้ในอนาคต
            },
            child: Image.network(
              data['imageUrl'],
              width: double.infinity,
              height: 350,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 350,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                height: 350,
                alignment: Alignment.center,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 50),
              
              ),
            ),
          ),

          // 3. Actions & Caption
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite_border, color: Colors.red, size: 28),
                    const SizedBox(width: 15),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "${data['likesCount'] ?? 0} likes",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    children: [
                      TextSpan(
                        text: "${data['userName']} ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: data['caption'] ?? ""),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันแปลงเวลา
  String _formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }
}