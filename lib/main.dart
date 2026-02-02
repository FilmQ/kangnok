import 'package:flutter/material.dart';
import 'package:kangnok/pages/park_page.dart';
import 'package:kangnok/pages/signup_page.dart';
import 'pages/welcome_page.dart';
import 'pages/login_page.dart';

void main() {
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
        '/': (context) => const WelcomePage(),
        '/authentication': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/park': (context) => const ParkPage(),
      },
    );
  }
}
