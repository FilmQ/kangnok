import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kangnok/providers/user_provider.dart';
import 'package:kangnok/services/validator.dart';

/// Collects additional profile info (name) after Firebase Auth registration,
/// then creates the Explorer document in Firestore.
class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createExplorer() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Please enter your name.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return;

      final email = firebaseUser.email ?? '';

      if (Validator.isExplorerBlacklistedEmail(email)) {
        await firebaseUser.delete();

        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorText = 'The @dnp.th domain is reserved for park rangers. Please use a different email address.';
          });

          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Invalid Email Domain'),
              content: const Text(
                'The @dnp.th domain is reserved for park rangers only. '
                'Please sign up with a different email address.'
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );

          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
        return;
      }

      final userService = ref.read(userServiceProvider);
      await userService.createExplorer(
        firebaseUser.uid,
        email,
        name,
      );

      // Invalidate the cached user so AuthGate re-fetches from Firestore
      ref.invalidate(currentUserProvider);

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete your profile')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Display Name',
                errorText: _errorText,
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _createExplorer(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createExplorer,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Get Started'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
