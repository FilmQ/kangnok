import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class CheckInService {
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _parks =
      FirebaseFirestore.instance.collection('parks');

  // Default radius in meters for a successful check-in.
  static const double checkInRadiusMeters = 1000;

  /// Ensures location services are enabled and permissions are granted.
  /// Returns the current [Position] or throws an exception with a message.
  Future<Position> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable them.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission was denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. Please enable it in settings.',
      );
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Parses a "lat, lng" coordinate string into latitude and longitude.
  (double lat, double lng)? _parseCoordinate(String coordinate) {
    try {
      final parts = coordinate.split(',');
      if (parts.length != 2) return null;
      return (double.parse(parts[0].trim()), double.parse(parts[1].trim()));
    } catch (_) {
      return null;
    }
  }

  /// Attempts to check in the user at the given park.
  ///
  /// Returns a [CheckInResult] indicating success or the reason for failure.
Future<CheckInResult> checkIn({
    required String uid,
    required String parkId,
    required String parkCoordinate,
  }) async {
    try {
      final position = await _getCurrentPosition();
      final parsed = _parseCoordinate(parkCoordinate);
      
      if (parsed == null) return CheckInResult.failure('Invalid park coordinates.');

      final (parkLat, parkLng) = parsed;
      final distanceInMeters = Geolocator.distanceBetween(
        position.latitude, position.longitude, parkLat, parkLng,
      );

      // 1. ตรวจสอบระยะทางก่อนเข้า Transaction (เพื่อความเร็ว)
      if (distanceInMeters > checkInRadiusMeters) {
        return CheckInResult.failure('You are too far from the park.');
      }

      // 2. ใช้ Firestore Transaction เพื่อป้องกันการเช็คอินซ้ำซ้อน (กดรัวๆ)
      return await FirebaseFirestore.instance.runTransaction((transaction) async {

      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);

      // 2. Query หาว่าวันนี้ User คนนี้เคยเช็คอินที่อุทยานนี้ไปหรือยัง
      final existingCheckIn = await FirebaseFirestore.instance
          .collection('checkins')
          .where('uid', isEqualTo: uid)
          .where('parkId', isEqualTo: parkId)
          .where('checkInTime', isGreaterThanOrEqualTo: startOfToday)
          .get();

      // 3. ถ้าเจอข้อมูล แปลว่าวันนี้เช็คอินไปแล้ว ให้ส่ง Failure กลับไป
      if (existingCheckIn.docs.isNotEmpty) {
        return CheckInResult.failure('You have already checked in today. Please come back tomorrow!');
      }
      
        final userDocRef = _users.doc(uid);
        final parkDocRef = _parks.doc(parkId);
        
        final userSnapshot = await transaction.get(userDocRef);
        final parkSnapshot = await transaction.get(parkDocRef);

        if (!userSnapshot.exists || !parkSnapshot.exists) {
          throw Exception('User or Park not found.');
        }

        final userData = userSnapshot.data() as Map<String, dynamic>;
        final parkData = parkSnapshot.data() as Map<String, dynamic>;
        final parkName = parkData['name'] as String;

        // --- แก้ปัญหาที่ 1: ตรวจสอบจาก parkId แทนชื่อ (แม่นยำกว่า) ---
        final List<String> visitedIds = List<String>.from(userData['parkVisitedIds'] ?? []);
        
        if (visitedIds.contains(parkId)) {
          return CheckInResult.alreadyVisited();
        }

        // 3. บันทึกข้อมูลทั้งหมดพร้อมกัน (Atomic Update)
        // เพิ่ม ID เข้าไปในลิสต์ที่เคยไป
        transaction.update(userDocRef, {
          'parkVisitedIds': FieldValue.arrayUnion([parkId]),
          'parkVisited': FieldValue.arrayUnion([parkName]), // เก็บชื่อไว้โชว์สวยๆ ก็ได้
        });

        // เพิ่มจำนวน Visitor
        transaction.update(parkDocRef, {
          'visitorCount': FieldValue.increment(1),
        });

        // สร้างประวัติการเช็คอินใน Collection 'checkins'
        final checkInRef = FirebaseFirestore.instance.collection('checkins').doc();
        transaction.set(checkInRef, {
          'uid': uid,
          'userName': userData['name'] ?? 'Unknown Explorer',
          'parkId': parkId,
          'parkName': parkName,
          'checkInTime': FieldValue.serverTimestamp(),
          'userPhoto': userData['profileImageUrl'],
        });

        return CheckInResult.success();
      });

    } catch (e) {
      debugPrint('Check-in error: $e');
      return CheckInResult.failure(e.toString());
    }
  }
}

class CheckInResult {
  final bool isSuccess;
  final bool isAlreadyVisited;
  final String? message;

  CheckInResult._({
    required this.isSuccess,
    this.isAlreadyVisited = false,
    this.message,
  });

  factory CheckInResult.success() =>
      CheckInResult._(isSuccess: true, message: 'Check-in successful!');

  factory CheckInResult.alreadyVisited() => CheckInResult._(
    isSuccess: false,
    isAlreadyVisited: true,
    message: 'You have already checked in at this park.',
  );

  factory CheckInResult.failure(String message) =>
      CheckInResult._(isSuccess: false, message: message);
}
