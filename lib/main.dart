import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kangnok/firebase_options.dart';
import 'package:kangnok/pages/admin/admin_create_ranger_page.dart';
import 'package:kangnok/pages/auth_gate.dart';
import 'package:kangnok/pages/auth_page.dart';
import 'package:kangnok/pages/explorer_home_page.dart';
import 'package:kangnok/pages/explorer_map_page.dart';
import 'package:kangnok/pages/explorer_park_page.dart';
import 'package:kangnok/pages/ranger/ranger_checkin_history_page.dart';
import 'package:kangnok/pages/ranger/ranger_post_announcement_page.dart';
import 'package:kangnok/pages/ranger/ranger_profile_page.dart';
import 'package:kangnok/pages/ranger/ranger_reviews_history_page.dart';
import 'package:kangnok/pages/ranger_auth_page.dart';
import 'package:kangnok/pages/explorer_profile_page.dart';
import 'package:kangnok/pages/ranger/ranger_home_page.dart';
import 'package:kangnok/pages/signup_page.dart';
import 'pages/welcome_page.dart';
import 'pages/explorer_add_post_page.dart';
import 'pages/explorer_social_page.dart';
import 'pages/explorer_achievement_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kangnok',
      home: const AuthGate(),
      routes: {
        '/welcome': (context) => WelcomePage(),
        '/authentication': (context) => AuthenticationPage(),
        '/ranger_auth': (context) => RangerAuthPage(),
        '/signup': (context) => SignupPage(),
        '/explorer_home': (context) => ExplorerHomePage(),
        '/ranger_home': (context) => RangerHomePage(),
        '/park': (context) => ExplorerParkPage(),
        '/explorer_profile': (context) => ExplorerProfilePage(),
        '/explorer_add_post': (context) => AddPostPage(),
        '/explorer_social': (context) => SocialPage(),
        '/explorer_achievement': (context) => AchievementPage(),
        '/explorer_map': (context) => ExplorerMapPage(),
        '/explorer_park': (context) => ExplorerMapPage(),
        '/admin_create_ranger': (context) => AdminCreateRangerPage(),
        '/ranger_post_announcement': (context) => RangerPostAnnouncementPage(),
        '/ranger_reviews_history': (context) => RangerReviewsHistoryPage(),
        '/ranger_profile_page': (context) => RangerProfilePage(),
        '/ranger_checkin_history': (context) => RangerCheckInHistoryPage(),
      },
    );
  }
}
