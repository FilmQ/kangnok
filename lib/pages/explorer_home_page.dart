import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kangnok/pages/explorer_achievement_page.dart';
import 'package:kangnok/pages/explorer_map_page.dart';
import 'package:kangnok/providers/achievement_provider.dart';
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
          'value': 'Level ${aqi} (${statusLabels[aqi]})',
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

  void _showBadgeDetail(BuildContext context, {
    required dynamic badge,
    required dynamic achievement,
    required bool isOwned,
    required String effectiveUrl,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(achievement.title, textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 100,
              child: effectiveUrl.startsWith('http')
                  ? Image.network(effectiveUrl)
                  : Image.asset(effectiveUrl),
            ),
            const SizedBox(height: 16),
            Text(achievement.description ?? "You've earned this badge!",
                textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. กำหนดหน้าที่จะแสดงในแต่ละ Tab ให้ตรงกับ Label ด้านล่าง
    final List<Widget> pages = [
      _buildHomeContent(ref), // Index 0: Home
      const AchievementPage(), // Index 1: Achievement
      const ExplorerMapPage(), // Index 2: Map
      const Center(child: Text("Profile Settings")),
    ];

    final themeData = ref.watch(explorerThemeDataProvider);

    return Scaffold(
      backgroundColor: themeData.backgroundColor,
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 3) {
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
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Achievement",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // --- หน้าเนื้อหาหลัก (Home Content) ---
  Widget _buildHomeContent(WidgetRef ref) {
    // เพิ่ม WidgetRef เข้ามา
    final profileAsyncValue = ref.watch(explorerProfileProvider);
    final themeData = ref.watch(explorerThemeDataProvider);

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
              error: (err, stack) =>
                  _buildGuestHeader(themeData), // ถ้า error ให้โชว์แบบ Guest
              data: (explorer) {
                if (explorer == null) return _buildGuestHeader(themeData);

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
                        Text(
                          "Welcome back",
                          style: TextStyle(
                            color: themeData.textColor.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          explorer.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: themeData.textColor,
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
                Text(
                  "Quick Info",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeData.textColor,
                  ),
                ),
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
            Text(
              "Recommended Parks",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeData.textColor,
              ),
            ),
            const SizedBox(height: 12),
            const PromoteParkBox(), // เรียกใช้ Widget ที่เราเพิ่งสร้าง
            const SizedBox(height: 30),

            Text(
              "Your Journey",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeData.textColor,
              ),
            ),
            const SizedBox(height: 12),
            // Placeholder สำหรับข้อมูลอื่นๆ ในหน้า Home
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: profileAsyncValue.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => const Text("Could not load journey data."),
                  data: (explorer) {
                    if (explorer == null) return const Text("Please login to see your journey.");

                    // ดึง Achievement มาแสดง (ตัวอย่างการกรองเฉพาะที่ได้แล้ว)
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Collected Badges",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        // ส่วนแสดง Badges ที่ได้แล้ว
                        _buildOwnedBadgesGrid(ref, explorer),
                      ],
                    );
                  },
                ),
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
    final themeData = ref.watch(explorerThemeDataProvider);

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
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: themeData.textColor,
                  ),
                ),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 13,
                    color: themeData.textColor.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnedBadgesGrid(WidgetRef ref, dynamic explorer) {
    // 1. เปลี่ยนมา watch 'achievementsStreamProvider' เพื่อดึงข้อมูล List<Achievement>
    final achievementsAsync = ref.watch(achievementsStreamProvider); 

    return achievementsAsync.when(
      loading: () => const Center(child: LinearProgressIndicator()),
      error: (e, _) => const Text("Badges unavailable."),
      data: (achievements) {
        // 2. ดึงค่า badges ที่ user ครอบครองแล้ว (เป็น Set เพื่อความเร็วในการเช็ค)
        final ownedValues = explorer.badges.map((b) => b.value).toSet();
        
        // 3. กรองเฉพาะ Achievement ที่เป็นประเภท badge และ user มีแล้ว
        final ownedBadgeAchievements = achievements.where((ach) {
          // ใช้ dynamic เพื่อป้องกัน Error: undefined value/type
          final dynamic reward = ach.reward;
          
          // เช็คว่า reward ไม่เป็น null และมี type เป็น badge
          if (reward == null || reward.type != 'badge') return false;
          
          // เช็คว่าค่า value ของ reward ตรงกับที่ user มีหรือไม่
          return ownedValues.contains(reward.value);
        }).toList();

        if (ownedBadgeAchievements.isEmpty) {
          return const Text(
            "No badges yet. Start exploring!",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ownedBadgeAchievements.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final ach = ownedBadgeAchievements[index];
            
            // ใช้ dynamic เพื่อป้องกัน Error: undefined imageUrl
            final dynamic reward = ach.reward; 

            final String? imgUrl = reward.imageUrl; 
            final effectiveUrl = (imgUrl == null || imgUrl.isEmpty)
                ? 'assets/achievements/badges/badge.png'
                : imgUrl;

            return GestureDetector(
              onTap: () => _showBadgeDetail(
                context,
                badge: reward,
                achievement: ach,
                isOwned: true,
                effectiveUrl: effectiveUrl,
              ),
              child: effectiveUrl.startsWith('http')
                  ? Image.network(effectiveUrl, fit: BoxFit.contain)
                  : Image.asset(effectiveUrl, fit: BoxFit.contain),
            );
          },
        );
      },
    );
  }
}

Widget _buildGuestHeader(ExplorerThemeData themeData) {
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
          Text(
            "Welcome,",
            style: TextStyle(color: themeData.textColor.withOpacity(0.6)),
          ),
          Text(
            "Explorer",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeData.textColor,
            ),
          ),
        ],
      ),
    ],
  );
}