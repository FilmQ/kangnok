import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kangnok/models/explorer.dart';
import 'package:kangnok/models/ranger.dart';
import 'package:kangnok/pages/explorer_home_page.dart';
import 'package:kangnok/pages/ranger_home_page.dart';
import 'package:kangnok/pages/welcome_page.dart';
import 'package:kangnok/providers/user_provider.dart';

/// Routes users to the appropriate home page based on auth state and role.
///
/// - Not signed in -> WelcomePage
/// - Signed in as Explorer -> ExplorerHomePage
/// - Signed in as Ranger -> RangerHomePage
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // Use synchronous check as fallback while stream is loading
    final firebaseUser = authState.whenOrNull(data: (user) => user) ??
        auth.FirebaseAuth.instance.currentUser;

    // Still loading and no sync user available
    if (authState.isLoading && firebaseUser == null) {
      return WelcomePage();
    }

    // Not signed in
    if (firebaseUser == null) {
      return WelcomePage();
    }

    // Signed in - fetch user role from Firestore
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return WelcomePage();
        }

        if (user is Explorer) {
          return ExplorerHomePage();
        } else if (user is Ranger) {
          return RangerHomePage();
        }

        return WelcomePage();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}
