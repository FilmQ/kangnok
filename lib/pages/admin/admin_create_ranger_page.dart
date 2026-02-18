import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kangnok/firebase_options.dart';
import 'package:kangnok/models/parks/park.dart';
import 'package:kangnok/models/roles/ranger.dart';
import 'package:kangnok/services/park_service.dart';
import 'package:kangnok/services/user_service.dart';
import 'package:kangnok/services/validator.dart';

class AdminCreateRangerPage extends StatefulWidget {
  const AdminCreateRangerPage({super.key});

  @override
  State<AdminCreateRangerPage> createState() => _AdminCreateRangerPageState();
}

class _AdminCreateRangerPageState extends State<AdminCreateRangerPage> {
  final TextEditingController _rangerEmailTextbox = TextEditingController();
  final TextEditingController _rangerPasswordTextbox = TextEditingController();
  String? _selectedParkName;

  @override
  void dispose() {
    _rangerEmailTextbox.dispose();
    _rangerPasswordTextbox.dispose();
    super.dispose();
  }

  Future<void> onFinishButtonClick() async {
    final email = _rangerEmailTextbox.text.trim();
    final password = _rangerPasswordTextbox.text.trim();

    if (!Validator.isValidEmail(email) ||
        email.isEmpty ||
        password.isEmpty ||
        _selectedParkName == null) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Please fill out the fields"),
          content: Text(
            "One or more of the fields are empty or invalid. Please fill them up.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Ok"),
            ),
          ],
        ),
      );
      return;
    }

    try {
      final secondaryApp = await Firebase.initializeApp(
        name: 'rangerCreation',
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      // Sign out and clean up the secondary app
      await secondaryAuth.signOut();
      await secondaryApp.delete();

      final ranger = Ranger(
        email: email,
        parkStation: _selectedParkName!,
        title: 'Ranger',
      );

      await UserService().createRanger(
        uid,
        email,
        _selectedParkName!,
        'Ranger',
      );
      await ParkService().addRangerToPark(_selectedParkName!, ranger);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Success"),
            content: Text(
              "Ranger account created for $email at $_selectedParkName.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text("Ok"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Clean up secondary app if it exists
      try {
        await Firebase.app('rangerCreation').delete();
      } catch (e) {
        debugPrint("Something happened regarding Firebase: $e");
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Error"),
            content: Text("Failed to create ranger: $e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Ok"),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget parkSelectorDropDown() {
    return StreamBuilder<QuerySnapshot>(
      stream: ParkService().getParkStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No parks available.');
        }

        final parks = snapshot.data!.docs.map((doc) {
          return Park.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();

        return DropdownButton<String>(
          value: _selectedParkName,
          hint: const Text('Select a park'),
          isExpanded: true,
          items: parks.map((park) {
            return DropdownMenuItem<String>(
              value: park.name,
              child: Text(park.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedParkName = value);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create a ranger account")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _rangerEmailTextbox,
              decoration: const InputDecoration(labelText: 'Ranger Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _rangerPasswordTextbox,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            parkSelectorDropDown(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onFinishButtonClick,
              child: Text("Finish"),
            ),
          ],
        ),
      ),
    );
  }
}
