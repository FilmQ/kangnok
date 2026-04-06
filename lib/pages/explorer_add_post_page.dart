import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kangnok/models/parks/review.dart';
import 'package:kangnok/providers/explorer_profile_provider.dart';
import 'package:kangnok/services/review_service.dart';

class AddPostPage extends ConsumerStatefulWidget {
  const AddPostPage({super.key});

  @override
  ConsumerState<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends ConsumerState<AddPostPage> {
  final List<File> _images = [];
  final _captionController = TextEditingController();
  final _reviewService = ReviewService();
  bool _isLoading = false;

  late final String _parkId =
      ModalRoute.of(context)!.settings.arguments as String;

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage(
      imageQuality: 70,
    );

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles.map((f) => File(f.path)));
      });
    }
  }

  Future<List<String>> _uploadImages() async {
    final List<String> downloadUrls = [];

    for (final image in _images) {
      final fileName =
          'reviews/${DateTime.now().millisecondsSinceEpoch}_${_images.indexOf(image)}.jpg';
      final snapshot = await FirebaseStorage.instance
          .ref()
          .child(fileName)
          .putFile(image);
      final url = await snapshot.ref.getDownloadURL();
      downloadUrls.add(url);
    }

    return downloadUrls;
  }

  Future<void> _uploadPost() async {
    if (_captionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write something for your review")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final explorer = ref.read(explorerProfileProvider).value;
      if (explorer?.uid == null) {
        throw Exception("User not loaded");
      }

      List<String>? imageUrls;
      if (_images.isNotEmpty) {
        imageUrls = await _uploadImages();
      }

      final review = Review(
        authorId: explorer!.uid!,
        authorName: explorer.name,
        parkId: _parkId,
        content: _captionController.text,
        imageUrls: imageUrls,
        likeCount: 0,
        likedBy: [],
        createdAt: DateTime.now(),
      );

      await _reviewService.createReview(review);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Failed to upload post: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to upload review. Please try again.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Write a Review"),
        actions: [
          if (!_isLoading)
            IconButton(
              onPressed: _uploadPost,
              icon: const Icon(Icons.send),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _captionController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: "Share your experience at this park...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_images.isNotEmpty) ...[
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _images[index],
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  OutlinedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_a_photo),
                    label: Text(
                      _images.isEmpty ? "Add photos" : "Add more photos",
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
