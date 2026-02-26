import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kangnok/pages/explorer_achievement_page.dart';
import 'package:kangnok/pages/explorer_map_page.dart';
import '../services/weather_service.dart';
import 'package:kangnok/providers/explorer_profile_provider.dart';
import 'package:kangnok/providers/theme_provider.dart';
import 'package:kangnok/widgets/promote_park_box.dart';

enum WidgetType { pollution, weather }

class ExplorerHomePage extends ConsumerStatefulWidget {
  const ExplorerHomePage({super.key});

  @override
  ConsumerState<ExplorerHomePage> createState() => _ExplorerHomePageState();
}

class _ExplorerHomePageState extends ConsumerState<ExplorerHomePage> {
  // --- State Variables ---
  WidgetType _currentWidget = WidgetType.pollution;
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? "";
  int _selectedIndex = 0;

  final WeatherService _weatherService = WeatherService();

  // cache the info to reduce the amount of repeated API call
  Map<String, dynamic>? _cachedWeatherData;
  Map<String, dynamic>? _cachedPollutionData;

  // ปรับปรุงฟังก์ชันดึงข้อมูล
  Future<Map<String, dynamic>> _fetchRealData({
    bool forceRefresh = false,
  }) async {
    try {
      if (_currentWidget == WidgetType.weather) {
        // Check cache first unless force refresh
        if (!forceRefresh && _cachedWeatherData != null) {
          return _cachedWeatherData!;
        }

        // ดึงอากาศเชียงใหม่
        final data = await _weatherService.fetchWeather();

        _cachedWeatherData = {
          'value': '${data['main']['temp'].round()}°C',
          'status': data['weather'][0]['main'],
          'detail': 'Chiang Mai • ${data['weather'][0]['description']}',
        };
        return _cachedWeatherData!;
      } else {
        // Check cache first unless force refresh
        if (!forceRefresh && _cachedPollutionData != null) {
          return _cachedPollutionData!;
        }

        // ดึงค่าฝุ่นเชียงใหม่
        final data = await _weatherService.fetchPollution();
        int aqi = data['list'][0]['main']['aqi']; // ค่า 1-5 (5 คือแย่มาก)
        List<String> statusLabels = [
          'Unknown',
          'Good',
          'Fair',
          'Moderate',
          'Poor',
          'Very Poor',
        ];

        _cachedPollutionData = {
          'value': 'Level ${aqi}',
          'status': statusLabels[aqi],
          'detail': 'Chiang Mai Air Quality Index',
        };
        return _cachedPollutionData!;
      }
    } catch (e) {
      rethrow;
    }
  }

  // Refresh data from API
  void _refreshData() {
    setState(() {
      if (_currentWidget == WidgetType.weather) {
        _cachedWeatherData = null;
      } else {
        _cachedPollutionData = null;
      }
    });
  }

  // --- สลับ Widget ในหน้า Home ---
  void _toggleQuickInfo() {
    setState(() {
      _currentWidget = _currentWidget == WidgetType.pollution
          ? WidgetType.weather
          : WidgetType.pollution;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. กำหนดหน้าที่จะแสดงในแต่ละ Tab ให้ตรงกับ Label ด้านล่าง 
    final List<Widget> pages = [
      _buildHomeContent(ref),                      // Index 0: Home
      const AchievementPage(),        // Index 1: Achievement
      const ExplorerMapPage(),        // Index 2: Map
      const Center(child: Text("Cosmetics Page")),  // Index 3: Cosmetics
      const Center(child: Text("Profile Settings")), 
    ];

    final themeData = ref.watch(explorerThemeDataProvider);

    return Scaffold(
      backgroundColor: themeData.backgroundColor,
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 4) {
            Navigator.pushNamed(context, '/explorer_profile');
            return;
          }
          // หากกด Tab อื่นๆ ให้สลับหน้าใน IndexedStack
          setState(() => _selectedIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: themeData.appBarColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Achievement"), 
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: "Cosmetics",
          ), // เปลี่ยน icon ให้ดูเป็นสายบิวตี้
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // --- หน้าเนื้อหาหลัก (Home Content) ---
  Widget _buildHomeContent(WidgetRef ref) { // เพิ่ม WidgetRef เข้ามา
    final profileAsyncValue = ref.watch(explorerProfileProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profileAsyncValue.when(
              loading: () => const SizedBox(
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => _buildGuestHeader(), // ถ้า error ให้โชว์แบบ Guest
              data: (explorer) {
                if (explorer == null) return _buildGuestHeader();

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blueAccent,
                      backgroundImage: explorer.profileImageUrl != null
                          ? NetworkImage(explorer.profileImageUrl!)
                          : null,
                      child: explorer.profileImageUrl == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome back",
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          explorer.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),

            // 2. Quick Info Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Quick Info", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      onPressed: _refreshData,
                      icon: const Icon(Icons.refresh),
                      tooltip: "Refresh data",
                      color: Colors.blueAccent,
                    ),
                    TextButton.icon(
                      onPressed: _toggleQuickInfo,
                      icon: const Icon(Icons.swap_horiz),
                      label: Text(
                        _currentWidget == WidgetType.pollution
                            ? "See Weather"
                            : "See Pollution",
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // 3. Dynamic Widget Box
            FutureBuilder<Map<String, dynamic>>(
              future: _fetchRealData(), // ใช้ฟังก์ชันใหม่
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _infoContainer(
                    title: "Loading...",
                    value: "---",
                    icon: Icons.refresh,
                    color: Colors.grey,
                    detail: "Fetching live data...",
                  );
                }

                if (snapshot.hasError) {
                  return _infoContainer(
                    title: "Error",
                    value: "!",
                    icon: Icons.error_outline,
                    color: Colors.red,
                    detail: "Could not load data",
                  );
                }

                final data = snapshot.data!;
                bool isWeather = _currentWidget == WidgetType.weather;

                return _infoContainer(
                  title: isWeather ? "Current Weather" : "Air Quality",
                  value: data['value'],
                  // ถ้าเป็นสภาพอากาศ อาจจะใช้ไอคอนแบบ Dynamic ตามสภาพฟ้าฝนได้
                  icon: isWeather ? _getWeatherIcon(data['status']) : Icons.air,
                  color: isWeather ? Colors.orange : Colors.teal,
                  detail: "${data['status']} • ${data['detail']}",
                );
              },
            ),

            const SizedBox(height: 30),
            // PROMOTE BOX
            const Text(
              "Recommended Parks",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const PromoteParkBox(), // เรียกใช้ Widget ที่เราเพิ่งสร้าง
            const SizedBox(height: 30),

            const Text(
              "Your Journey",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Placeholder สำหรับข้อมูลอื่นๆ ในหน้า Home
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(Icons.map_outlined, size: 50, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันเสริมสำหรับเลือกไอคอนตามสภาพอากาศ
  IconData _getWeatherIcon(String status) {
    switch (status.toLowerCase()) {
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.umbrella;
      case 'clear':
        return Icons.wb_sunny;
      default:
        return Icons.wb_cloudy;
    }
  }

  // --- Template สำหรับกล่องข้อมูล ---
  Widget _infoContainer({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String detail,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  detail,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildGuestHeader() {
  return Row(
    children: [
      const CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, color: Colors.white),
      ),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Welcome,", style: TextStyle(color: Colors.grey)),
          const Text("Explorer", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    ],
  );
}