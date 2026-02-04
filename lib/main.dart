import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kangnok/firebase_options.dart';
import 'package:kangnok/pages/auth_page.dart';
import 'package:kangnok/pages/park_page.dart';
import 'package:kangnok/pages/signup_page.dart';
import 'pages/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kangnok',
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomePage(),
        '/authentication': (context) => AuthenticationPage(),
        '/signup': (context) => SignupPage(),
        '/park': (context) => ParkPage(),
      },
    );
  }
}
