import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kangnok/models/parks/park.dart';
import 'package:kangnok/providers/park_provider.dart';
import 'package:kangnok/providers/theme_provider.dart';
import 'package:latlong2/latlong.dart';

// TODO: Refine this god damn map
// TASK:
//  make the card actually a content that displays at the center
//  add the bottom nav bar to navigate back to user's page
//  that should be it i think :broken-heart:

/// Displays an OpenStreetMap centered on Chiang Mai with a pin for each park.
class ExplorerMapPage extends ConsumerStatefulWidget {
  const ExplorerMapPage({super.key});

  @override
  ConsumerState<ExplorerMapPage> createState() => _ExplorerMapPageState();
}

class _ExplorerMapPageState extends ConsumerState<ExplorerMapPage> {
  Park? _selectedPark;
  final MapController _mapController = MapController();

  static const _defaultCenter = LatLng(18.7883, 98.9853); // chiang mai
  static const _defaultZoom = 8.1;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.mapEventStream.listen((event) {
        if (mounted) {
          setState(() {});
        }
      });
    });
  }

  LatLng? _parseCoordinate(String coordinate) {
    try {
      final parts = coordinate.split(',');
      if (parts.length != 2) return null;
      final lat = double.parse(parts[0].trim());
      final lng = double.parse(parts[1].trim());
      return LatLng(lat, lng);
    } catch (_) {
      debugPrint("Unable to parse the park's coordinate.");
      return null;
    }
  }

  Widget _universityButton(List<Park> parks) {
    return FloatingActionButton.small(
      onPressed: () {
        Navigator.pushNamed(
          context,
          '/park',
          arguments: parks.firstWhere((p) => p.name == "Kasetsart University"),
        );
      },
      child: Text("KU"),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parksAsync = ref.watch(parksStreamProvider);

    return Scaffold(
      //appBar: AppBar(title: const Text(""), centerTitle: true, backgroundColor: Color(0x44000000)),
      body: parksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading parks: $e')),
        data: (parks) => _buildMap(parks),
      ),
    );
  }

  Widget _buildMap(List<Park> parks) {
    final markers = <Marker>[];

    for (final park in parks) {
      final latLng = _parseCoordinate(park.coordinate);
      if (latLng == null) continue;

      double width = 40;
      double height = 40;

      markers.add(
        Marker(
          point: latLng,
          width: width,
          height: height,
          child: GestureDetector(
            onTap: () => setState(() {
              _selectedPark = park;
            }),
            child: Icon(
              Icons.location_on,
              color: _selectedPark?.name == park.name
                  ? Colors.red
                  : Colors.blue.shade900,
              size: _selectedPark?.name == park.name ? 40 : 36,
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _defaultCenter,
            initialZoom: _defaultZoom,
            onTap: (_, _) => setState(() => _selectedPark = null),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.kangnok.app',
            ),
            MarkerLayer(
              markers: parks.map((park) {
                final latLng = _parseCoordinate(park.coordinate);
                if (latLng == null)
                  return Marker(point: LatLng(0, 0), child: Container());

                double currentZoom = 0.0;
                try {
                  currentZoom = _mapController.camera.zoom;
                } catch (_) {}

                final bool showCard = currentZoom > 10.0;

                return Marker(
                  point: latLng,
                  width: showCard ? 350 : 40,
                  height: showCard ? 100 : 40,
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPark = park;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (currentZoom > 10.0)
                          AnimatedOpacity(
                            opacity: currentZoom > 10.0 ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeInOut,
                            child: _buildAlwaysShowCard(park.name),
                          )
                        else
                          const SizedBox(height: 0),
                        Icon(
                          Icons.location_on,
                          color: _selectedPark?.name == park.name
                              ? Colors.red
                              : Colors.blue.shade900,
                          size: _selectedPark?.name == park.name ? 40 : 30,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        Positioned(
          top: 50,
          right: 12,
          child: FloatingActionButton.small(
            heroTag: 'recenter',
            onPressed: () {
              _mapController.move(_defaultCenter, _defaultZoom);
            },
            child: const Icon(Icons.my_location),
          ),
        ),
        Positioned(top: 100, right: 12, child: _universityButton(parks)),
        if (_selectedPark != null) _buildParkCard(_selectedPark!),
      ],
    );
  }

  Widget _buildParkCard(Park park) {
    final themeData = ref.watch(explorerThemeDataProvider);
    final hasImage = park.imageUrl.isNotEmpty && park.imageUrl.first.isNotEmpty;

    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Park image or placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: hasImage
                      ? Image.network(park.imageUrl.first, fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey.shade300,
                          child: Icon(
                            Icons.park,
                            size: 40,
                            color: Colors.grey.shade600,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Park info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            park.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(() => _selectedPark = null),
                          child: const Icon(Icons.close, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      park.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeData.appBarColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/park',
                            arguments: park,
                          );
                        },
                        child: const Text('View Park'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlwaysShowCard(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.green.shade200, width: 1),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min, // ทำให้ Container กว้างเท่ากับเนื้อหาข้างใน
        children: [
          const Icon(Icons.park, size: 14, color: Colors.green),
          const SizedBox(width: 6),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
