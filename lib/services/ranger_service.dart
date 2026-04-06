import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:kangnok/models/roles/ranger.dart';

/// PS: please use [UserService] for the creation of user of both roles
class RangerService {
  final _rangers = FirebaseFirestore.instance.collection("users");
  Query<Map<String, dynamic>> get rangersQuery =>
      _rangers.where("type", isEqualTo: "ranger");

  // CREATE:

  // READ:
  Stream<QuerySnapshot> getRangers() {
    return rangersQuery.snapshots();
  }

  Stream<QuerySnapshot> getRangersFromPark(String parkId) {
    return rangersQuery.where('parkId', isEqualTo: parkId).snapshots();
  }

  // UPDATE:
  Future<void> updateRanger(String rangerId, Ranger ranger) async {
    try {
      await _rangers.doc(rangerId).update(ranger.toJson());
    } on FirebaseException catch (e) {
      debugPrint("Cannot update ranger because of: $e");
    }
  }

  // DELETE (quite dangerous!):
  Future<void> deleteRanger(String rangerId) async {
    try {
      await _rangers.doc(rangerId).delete();
      await FirebaseFunctions.instance
          .httpsCallable('deleteUserAuth')
          .call({'userId': rangerId});
    } on FirebaseException catch (e) {
      debugPrint("Cannot delete ranger because of: $e");
    }
  }
}
