import 'package:kangnok/models/parks/park.dart';
import 'package:kangnok/services/park_service.dart';
import 'package:riverpod/riverpod.dart';

final parkServiceProvider = Provider<ParkService>((ref) => ParkService());

/// Streams all parks from Firestore as typed [Park] objects.
final parksStreamProvider = StreamProvider<List<Park>>((ref) {
  final parkService = ref.read(parkServiceProvider);
  return parkService.getParkStream().map((snapshot) {
    return snapshot.docs.map((doc) {
      return Park.fromJson(doc.data() as Map<String, dynamic>, id: doc.id);
    }).toList();
  });
});
