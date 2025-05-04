import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpdateTeacherInfoPage extends StatefulWidget {
  const UpdateTeacherInfoPage({super.key});

  @override
  State<UpdateTeacherInfoPage> createState() => _UpdateTeacherInfoPageState();
}

class _UpdateTeacherInfoPageState extends State<UpdateTeacherInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _qualificationController =
      TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  Future<void> _updateTeacherInfo() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      await FirebaseFirestore.instance
          .collection('users_roles')
          .doc(user.uid)
          .update({
            'name': _usernameController.text.trim(),
            'qualification': _qualificationController.text.trim(),
            'contact': _contactController.text.trim(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Information updated successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Information'),
        backgroundColor: const Color.fromARGB(200, 3, 41, 255),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter a username'
                            : null,
              ),
              TextFormField(
                controller: _qualificationController,
                decoration: const InputDecoration(labelText: 'Qualification'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter qualification'
                            : null,
              ),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.phone,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter contact number'
                            : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateTeacherInfo,
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
