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
      if (parsed == null) {
        return CheckInResult.failure('Unable to read park coordinates.');
      }

      final (parkLat, parkLng) = parsed;
      debugPrint(
        'Check-in debug: user=(${position.latitude}, ${position.longitude}), '
        'park=($parkLat, $parkLng), raw="$parkCoordinate"',
      );
      final distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        parkLat,
        parkLng,
      );

      if (distanceInMeters > checkInRadiusMeters) {
        return CheckInResult.failure(
          'You are ${(distanceInMeters / 1000).toStringAsFixed(1)} km away. '
          'You need to be within ${(checkInRadiusMeters / 1000).toStringAsFixed(1)} km of the park to check in.',
        );
      }

      // Fetch the park document to get its name
      final parkDoc = await _parks.doc(parkId).get();
      final parkData = parkDoc.data() as Map<String, dynamic>?;
      if (parkData == null) {
        return CheckInResult.failure('Park not found.');
      }
      final parkName = parkData['name'] as String;

      // Check if already visited (by park name)
      final userDoc = await _users.doc(uid).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      final parkVisited = List<String>.from(userData?['parkVisited'] ?? []);

      if (parkVisited.contains(parkName)) {
        return CheckInResult.alreadyVisited();
      }

      // Add park name to visited list and increment park's visitor count
      await _users.doc(uid).update({
        'parkVisited': FieldValue.arrayUnion([parkName]),
      });
      await _parks.doc(parkId).update({
        'visitorCount': FieldValue.increment(1),
      });

      return CheckInResult.success();
    } on Exception catch (e) {
      debugPrint('Check-in failed: $e');
      return CheckInResult.failure(
        e.toString().replaceFirst('Exception: ', ''),
      );
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
