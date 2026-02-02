import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSignup() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showMessage('Please fill all fields');
      return;
    }

    if (password != confirm) {
      _showMessage('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. สร้างบัญชีใน Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2. บันทึกข้อมูล Username ลง Firestore โดยใช้ UID เดียวกับ Auth
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showMessage('Account created successfully!', isError: false);
      if (mounted) Navigator.pop(context); // กลับไปหน้า Login

    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'An error occurred');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center( 
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
              const Icon(Icons.person_add_outlined, size: 80, color: Colors.blue),
              const SizedBox(height: 32),
              
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 32),
              
              _isLoading 
                ? const CircularProgressIndicator() 
                : SizedBox(
                    width: double.infinity, 
                    height: 50, 
                    child: ElevatedButton(
                      onPressed: _handleSignup, 
                      child: const Text('Sign up'),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}