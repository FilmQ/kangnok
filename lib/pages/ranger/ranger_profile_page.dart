import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kangnok/providers/ranger_profile_provider.dart';

class RangerProfilePage extends ConsumerStatefulWidget {
  const RangerProfilePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RangerProfilePageState();
}

class _RangerProfilePageState extends ConsumerState<RangerProfilePage> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _firebaseStorage = FirebaseStorage.instance.ref();

  Future<void> _updateProfileData(String field, String value) async {
    if (uid == null) return;
    try {
      await _db.collection('users').doc(uid).update({field: value});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null || uid == null) return;

    setState(() => _profileImage = File(picked.path));

    // save to firestore and save the url to firestore
    try {
      final storageRef = _firebaseStorage.child('profile_pics/$uid.jpg');
      await storageRef.putFile(_profileImage!);
      final downloadUrl = await storageRef.getDownloadURL();
      await _db.collection('users').doc(uid).update({
        'profileImageUrl': downloadUrl,
      });
      if (!mounted) return;
      ref.invalidate(rangerProfileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!')),
        );
      }
    } on FirebaseException catch (e) {
      debugPrint("Cannot store profile picture: $e");
    }
  }

  void _showEditTitleDialog(String currentTitle) {
    final controller = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Title"),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: "Enter new title"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final newTitle = controller.text.trim();
                if (newTitle.isNotEmpty && newTitle != currentTitle) {
                  if (newTitle.length > 24) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("OK"),
                            ),
                          ],
                          title: Text("Character limit"),
                          content: Text(
                            "Your input exceeded 24 characters, please try again",
                          ),
                        );
                      },
                    );
                    return;
                  }
                  _updateProfileData('title', newTitle);
                }
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final rangerAsync = ref.watch(rangerProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Your Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: rangerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (ranger) {
          final profileImageUrl = ranger?.profileImageUrl;

          return ListView(
            children: [
              SizedBox(height: 40),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : (profileImageUrl != null
                                  ? NetworkImage(profileImageUrl)
                                        as ImageProvider
                                  : null),
                        child:
                            (_profileImage == null && profileImageUrl == null)
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(child: Text("Your title", style: TextStyle(fontSize: 15))),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      ranger!.title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _showEditTitleDialog(ranger.title),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
