import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:kangnok/models/roles/ranger.dart';
import 'package:kangnok/services/string_utils.dart';

class ParkService {
  final CollectionReference park = FirebaseFirestore.instance.collection(
    'parks',
  );
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Lists all files in a Storage folder and returns a map of
  /// { normalized filename without extension -> download URL }.
  Future<Map<String, String>> _buildImageLookup(String folderPath) async {
    final lookup = <String, String>{};
    try {
      print('[Storage] Looking up images at: $folderPath');
      final result = await _storage.ref(folderPath).listAll();
      print('[Storage] Found ${result.items.length} files, '
          '${result.prefixes.length} subfolders at $folderPath');
      for (var item in result.items) {
        final url = await item.getDownloadURL();
        final fullName = item.name;
        final baseName = fullName.contains('.')
            ? fullName.substring(0, fullName.lastIndexOf('.'))
            : fullName;
        final normalizedKey = StringUtils.normalizeForLookup(baseName);
        print('[Storage] Mapped: "$normalizedKey" -> ${item.name}');
        lookup[normalizedKey] = url;
      }
    } catch (e) {
      print('Could not list images at $folderPath: $e');
    }
    return lookup;
  }

  /// Lists all files in a Storage folder and returns all download URLs.
  Future<List<String>> _listAllImageUrls(String folderPath) async {
    final urls = <String>[];
    try {
      final result = await _storage.ref(folderPath).listAll();
      for (var item in result.items) {
        urls.add(await item.getDownloadURL());
      }
    } catch (e) {
      print('Could not list images at $folderPath: $e');
    }
    return urls;
  }

  // CREATE (prolly wont be used after all 14 parks are serialized):

  // This function reads FROM the assets/parks JSON to construct a "parks"
  // collection in Firestore, and resolves image URLs from Firebase Storage
  // using the folder convention:
  //   /parks/{stripped_park_name}/{faunas,floras,front_page_images,landmarks}/*
  Future<void> seedParks() async {
    final jsonString = await rootBundle.loadString(
      'assets/parks/parks_data.json',
    );
    final List<dynamic> parksList = json.decode(jsonString);

    final batch = FirebaseFirestore.instance.batch();

    for (var parkJson in parksList) {
      final parkName = parkJson['name'] as String;
      final sanitizedName = parkName
          .toLowerCase()
          .replaceAll(' ', '_')
          .replaceAll('-', '_');
      final storageName = StringUtils.storageFolderName(parkName);

      // -- Resolve front page images from Storage --
      final frontPageUrls = await _listAllImageUrls(
        'parks/$storageName/front_page_images',
      );
      if (frontPageUrls.isNotEmpty) {
        parkJson['imageUrl'] = frontPageUrls;
        print('Loaded ${frontPageUrls.length} front page images for $parkName');
      }

      // -- Fauna: load JSON then resolve image URLs from Storage --
      try {
        final faunaJson = await rootBundle.loadString(
          'assets/parks/fauna/${sanitizedName}_fauna.json',
        );
        final faunaList = json.decode(faunaJson) as List;

        final faunaLookup = await _buildImageLookup(
          'parks/$storageName/faunas',
        );
        for (var fauna in faunaList) {
          final name = fauna['name'] as String;
          final normalized = StringUtils.normalizeForLookup(name);
          final url = faunaLookup[normalized] ?? '';
          fauna['imageUrl'] = url;
          print('[Fauna] "$name" -> normalized: "$normalized" -> '
              'found: ${url.isNotEmpty ? "YES" : "NO"}');
        }

        parkJson['faunas'] = faunaList;
        print('Loaded ${faunaList.length} fauna for $parkName '
            '(${faunaLookup.length} images matched)');
      } catch (e) {
        print(
          'No fauna file for $parkName (${sanitizedName}_fauna.json): $e',
        );
        parkJson['faunas'] = [];
      }

      // -- Flora: load JSON then resolve image URLs from Storage --
      try {
        final floraJson = await rootBundle.loadString(
          'assets/parks/flora/${sanitizedName}_flora.json',
        );
        final floraList = json.decode(floraJson) as List;

        final floraLookup = await _buildImageLookup(
          'parks/$storageName/floras',
        );
        for (var flora in floraList) {
          final name = flora['name'] as String;
          flora['imageUrl'] = floraLookup[StringUtils.normalizeForLookup(name)] ?? '';
        }

        parkJson['floras'] = floraList;
        print('Loaded ${floraList.length} flora for $parkName '
            '(${floraLookup.length} images matched)');
      } catch (e) {
        print('No flora file for $parkName (${sanitizedName}_flora.json): $e');
        parkJson['floras'] = [];
      }

      // -- Landmarks: load JSON then resolve image URLs from Storage --
      try {
        final landmarksJson = await rootBundle.loadString(
          'assets/parks/landmark/${sanitizedName}_landmark.json',
        );
        final landmarkList = json.decode(landmarksJson) as List;

        final landmarkLookup = await _buildImageLookup(
          'parks/$storageName/landmarks',
        );
        for (var landmark in landmarkList) {
          final name = landmark['name'] as String;
          landmark['imageUrl'] = landmarkLookup[StringUtils.normalizeForLookup(name)] ?? '';
        }

        parkJson['landmarks'] = landmarkList;
        print('Loaded ${landmarkList.length} landmarks for $parkName '
            '(${landmarkLookup.length} images matched)');
      } catch (e) {
        print(
          'No landmarks file for $parkName (${sanitizedName}_landmark.json): $e',
        );
        parkJson['landmarks'] = [];
      }

      parkJson['createdAt'] = Timestamp.now();

      // Use a deterministic ID so reseeding overwrites the same documents
      // instead of creating new ones with random IDs.
      final docRef = park.doc(sanitizedName);
      batch.set(docRef, parkJson);
    }

    // Commit all writes at once
    await batch.commit();
    print('Successfully seeded ${parksList.length} parks to Firestore!');
  }

  // READ:
  Stream<QuerySnapshot> getParkStream() {
    return park.orderBy('name', descending: false).snapshots();
  }

  // UPDATE:

  /// Adds a ranger to a park's rangers list by park document ID.
  Future<void> addRangerToPark(String parkId, Ranger ranger) async {
    final docRef = park.doc(parkId);
    final doc = await docRef.get();
    if (!doc.exists) {
      throw ArgumentError('Park with ID "$parkId" not found.');
    }
    await docRef.update({
      'rangers': FieldValue.arrayUnion([ranger.toJson()]),
    });
  }

  // DELETE:
}
