import 'package:flutter/material.dart';
import 'package:kangnok/pages/park_page.dart';
import 'pages/welcome_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Welcome App',
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomePage(),
        '/park': (context) => ParkPage(),
      },
    );
  }
}
