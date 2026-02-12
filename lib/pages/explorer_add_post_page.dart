import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  File? _image;
  final _captionController = TextEditingController();
  bool _isLoading = false;

  // --- ฟังก์ชันเลือกรูปจากมือถือ ---
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // ลดขนาดรูปเพื่อความประหยัด Storage
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // --- ฟังก์ชันอัปโหลดข้อมูลทั้งหมดไป Firebase ---
  Future<void> _uploadPost() async {
    if (_image == null || _captionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image and write a caption")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      
      // 1. อัปโหลดรูปลง Firebase Storage
      String fileName = 'posts/${DateTime.now().millisecondsSinceEpoch}.jpg';
      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref()
          .child(fileName)
          .putFile(_image!);
      
      // 2. รับลิงก์รูปภาพ (Download URL)
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // 3. บันทึกข้อมูลลง Firestore
      await FirebaseFirestore.instance.collection('posts').add({
        'userId': user.uid,
        'userName': user.displayName ?? "Anonymous", // อย่าลืมเซ็ตชื่อตอนสมัคร
        'imageUrl': downloadUrl,
        'caption': _captionController.text,
        'likesCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pop(context); // กลับหน้า Feed
    } catch (e) {
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Post"),
        actions: [
          if (!_isLoading)
            IconButton(onPressed: _uploadPost, icon: const Icon(Icons.send, color: Colors.blue))
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ส่วนแสดงรูปที่เลือก
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: _image == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Icon(Icons.add_a_photo, size: 50), Text("Tap to select photo")],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(_image!, fit: BoxFit.cover),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                // ช่องกรอกแคปชั่น
                TextField(
                  controller: _captionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Write a caption about your journey...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}