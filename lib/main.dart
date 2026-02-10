import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kangnok/firebase_options.dart';
import 'package:kangnok/pages/auth_gate.dart';
import 'package:kangnok/pages/auth_page.dart';
import 'package:kangnok/pages/explorer_home_page.dart';
import 'package:kangnok/pages/park_page.dart';
import 'package:kangnok/pages/ranger_auth_page.dart';
import 'package:kangnok/pages/explorer_profile_page.dart';
import 'package:kangnok/pages/ranger_home_page.dart';
import 'package:kangnok/pages/signup_page.dart';
import 'pages/welcome_page.dart';

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
        '/park': (context) => ParkPage(),
        '/explorer_profile': (context) => ExplorerProfilePage(),
      },
    );
  }
}
