import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart' show AuthCredential;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';

class AuthenticationPage extends StatelessWidget {
  AuthenticationPage({super.key});

  static const String _iosClientId =
      "100421617321-3giqlnh4linad8utja6lcme2qkqe7imr.apps.googleusercontent.com";
  static const String _androidClientId =
      "100421617321-b4bdb6opjkipqlk254baausjpdj4gcs9.apps.googleusercontent.com";

  static String get _clientId =>
      Platform.isIOS ? _iosClientId : _androidClientId;

  List<AuthProvider<AuthListener, AuthCredential>> get providers => [
    GoogleProvider(clientId: _clientId),
    EmailAuthProvider(),
  ];

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      providers: providers,
      
    );
  }
}
