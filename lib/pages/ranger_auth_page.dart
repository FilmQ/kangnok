import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

/// This page is literally just a sign-in form, the actual routing logic
/// is done in [AuthGate]
class RangerAuthPage extends StatelessWidget {
  RangerAuthPage({super.key});

  String _errorMessage(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'user-disabled':
        return 'This account has been disabled. Contact your administrator.';
      default:
        return 'Invalid email or password.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in to continue')),
      body: SignInScreen(
        providers: [EmailAuthProvider()],
        showAuthActionSwitch: false,
        actions: [
          AuthStateChangeAction<SignedIn>((context, state) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }),
          AuthStateChangeAction<AuthFailed>((context, state) {
            final exception = state.exception;
            if (exception is FirebaseAuthException) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(_errorMessage(exception))));
            }
          }),
        ],
      ),
    );
  }
}
