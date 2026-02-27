import 'dart:io'; // สำหรับจัดการไฟล์รูปภาพ
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // สำหรับอัปโหลดรูป
import 'package:image_picker/image_picker.dart'; // สำหรับเลือกรูป
import 'package:kangnok/providers/ranger_profile_provider.dart';
import 'package:kangnok/models/parks/announcement.dart';

class RangerPostAnnouncementPage extends ConsumerStatefulWidget {
  const RangerPostAnnouncementPage({super.key});

  @override
  ConsumerState<RangerPostAnnouncementPage> createState() => _RangerPostAnnouncementPageState();
}

class _RangerPostAnnouncementPageState extends ConsumerState<RangerPostAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  String _selectedType = 'General';
  bool _isLoading = false;
  
  // --- ตัวแปรสำหรับจัดการรูปภาพ ---
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // ฟังก์ชันเลือกรูปภาพจาก Gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // ฟังก์ชันอัปโหลดรูปไปยัง Firebase Storage
  Future<String?> _uploadImage(String parkId) async {
    if (_imageFile == null) return null; // ถ้าไม่มีรูป คืนค่า null

    try {
      final String fileName = 'announcement_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('parks/$parkId/announcements/$fileName');
      
      await storageRef.putFile(_imageFile!);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _submitAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final rangerAsync = ref.read(rangerProfileProvider);
      final ranger = rangerAsync.value;
      if (ranger == null) throw Exception("Ranger profile not found");

      // 1. อัปโหลดรูปก่อน (ถ้ามี)
      String? imageUrl = await _uploadImage(ranger.parkId);

      // 2. สร้างประกาศ
      final newAnnouncement = Announcement(
        rangerId: ranger.uid ?? '',
        rangerName: ranger.title,
        parkId: ranger.parkId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        type: _selectedType,
        createdAt: DateTime.now(),
        imageUrl: imageUrl, 
      );

      await FirebaseFirestore.instance
          .collection('announcements')
          .add(newAnnouncement.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement posted!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Announcement', style: TextStyle(fontWeight: .bold )), foregroundColor: Colors.white,
        flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.yellow, Colors.orange], // ธีมเดียวกับหน้า Home
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- ส่วนเลือกรูปภาพ (UI ใหม่) ---
                  const Text("Cover Image", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.file(_imageFile!, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported, size: 50, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text("No image selected", style: TextStyle(color: Colors.grey[600])),
                                const Text("(Tap to select)", style: TextStyle(fontSize: 12, color: Colors.blue)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ... (ส่วน Dropdown, Title, Content เหมือนเดิม) ...
                  _buildLabel("Announcement Type"),
                  _buildTypeDropdown(),
                  const SizedBox(height: 16),
                  _buildLabel("Title"),
                  _buildTextField(_titleController, "Enter title..."),
                  const SizedBox(height: 16),
                  _buildLabel("Details"),
                  _buildTextField(_contentController, "Enter details...", maxLines: 5),
                  
                  const SizedBox(height: 32),
                  Material(
                    borderRadius: BorderRadius.circular(15),
                    elevation: 5, 
                    child: InkWell(
                      onTap: _submitAnnouncement,
                      borderRadius: BorderRadius.circular(15), // สำคัญ: ต้องใส่เพื่อให้เอฟเฟกต์กดเป็นรูปทรงมน
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.yellow, Colors.orange],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          width: double.infinity, // ให้ยาวเต็มจอ
                          height: 55, // ความสูงปุ่ม
                          alignment: Alignment.center,
                          child: const Text("Post Announcement", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Helper Widgets เพื่อให้โค้ดสะอาดขึ้น
  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) => TextFormField(
    controller: controller,
    maxLines: maxLines,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    validator: (v) => v!.isEmpty ? 'Required field' : null,
  );

  Widget _buildTypeDropdown() => DropdownButtonFormField<String>(
    value: _selectedType,
    items: ['General', 'Event', 'Alert', 'Day Off'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
    onChanged: (v) => setState(() => _selectedType = v!),
    decoration: InputDecoration(
      filled: true, fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}