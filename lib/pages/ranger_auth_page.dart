import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class RangerAuthPage extends StatelessWidget {
  RangerAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in to continue'),
      ),
      body: SignInScreen(
        providers: [EmailAuthProvider()],
        showAuthActionSwitch: false,
      )
    );
  }
}
