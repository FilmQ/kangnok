import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:kangnok/models/roles/ranger.dart';

class ParkService {
  final CollectionReference park = FirebaseFirestore.instance.collection(
    'parks',
  );

  // CREATE (prolly wont be used after all 14 parks are serialized):
  
  // This function essentially reads FROM the assets/parks to construct
  // a "parks" collection in Firestore
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

      // flora, fauna, and landmarks
      try {
        final faunaJson = await rootBundle.loadString(
          'assets/parks/fauna/${sanitizedName}_fauna.json',
        );
        parkJson['faunas'] = json.decode(faunaJson);
        print(
          'Loaded ${(parkJson['faunas'] as List).length} fauna for $parkName',
        );
      } catch (e) {
        print(
          'No fauna file for $parkName (${sanitizedName}_fauna.json): $e',
        );
        parkJson['faunas'] = [];
      }

      try {
        final floraJson = await rootBundle.loadString(
          'assets/parks/flora/${sanitizedName}_flora.json',
        );
        parkJson['floras'] = json.decode(floraJson);
        print(
          'Loaded ${(parkJson['floras'] as List).length} flora for $parkName',
        );
      } catch (e) {
        print('No flora file for $parkName (${sanitizedName}_flora.json): $e');
        parkJson['floras'] = [];
      }

      try {
        final landmarksJson = await rootBundle.loadString(
          'assets/parks/landmark/${sanitizedName}_landmark.json',
        );
        parkJson['landmarks'] = json.decode(landmarksJson);
        print(
          'Loaded ${(parkJson['landmarks'] as List).length} landmarks for $parkName',
        );
      } catch (e) {
        print(
          'No landmarks file for $parkName (${sanitizedName}_landmark.json): $e',
        );
        parkJson['landmarks'] = [];
      }

      parkJson['createdAt'] = Timestamp.now();

      final docRef = park.doc();
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

  /// Adds a ranger to a park's rangers list by park name.
  Future<void> addRangerToPark(String parkName, Ranger ranger) async {
    final query = await park.where('name', isEqualTo: parkName).limit(1).get();
    if (query.docs.isEmpty) {
      throw ArgumentError('Park "$parkName" not found.');
    }
    await query.docs.first.reference.update({
      'rangers': FieldValue.arrayUnion([ranger.toJson()]),
    });
  }

  // DELETE:
}
