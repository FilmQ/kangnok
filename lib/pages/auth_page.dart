import 'package:firebase_auth/firebase_auth.dart' show AuthCredential;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';

class AuthenticationPage extends StatelessWidget {
  AuthenticationPage({super.key});

  final List<AuthProvider<AuthListener, AuthCredential>> providers = [
    GoogleProvider(
      clientId:
          "100421617321-b4bdb6opjkipqlk254baausjpdj4gcs9.apps.googleusercontent.com",
    ),
    EmailAuthProvider()
  ];

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      providers: providers,
      
    );
  }
}
