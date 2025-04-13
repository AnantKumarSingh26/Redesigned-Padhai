import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _errorMessage = '';
  String _selectedRole = 'student'; // Default role
  String? _selectedQualification;
  bool _isLoading = false;

  // List of roles for dropdown
  final List<String> _roles = ['student', 'teacher'];
  
  // List of qualifications
  final List<String> _qualifications = [
    'High School',
    'Intermediate',
    'Undergraduate',
    'Post Graduate',
    'Other'
  ];

  Future<void> _signup() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final String name = _nameController.text.trim();
      final String email = _emailController.text.trim();
      final String? contact = _contactController.text.trim().isEmpty 
          ? null 
          : _contactController.text.trim();

      if (name.isEmpty || email.isEmpty) {
        setState(() {
          _errorMessage = 'Please fill in all required fields.';
        });
        return;
      }

      // Generate a random password (Firebase requires min 6 chars)
      final String randomPassword = _generateRandomPassword();

      // Create user with email and password in Firebase
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: randomPassword,
      );

      // Send password reset email (so user can set their own password)
      await _auth.sendPasswordResetEmail(email: email);

      // Save additional info to users_roles collection
      if (userCredential.user != null) {
        await _firestore.collection('users_roles').doc(userCredential.user!.uid).set({
          'name': name,
          'email': email,
          'role': _selectedRole,
          'qualification': _selectedQualification,
          'contact': contact,
          'createdAt': FieldValue.serverTimestamp(),
          'hasSetPassword': false, // Track if user has set their password
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Check your email to set your password.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          _errorMessage = 'An account already exists for that email.';
        } else if (e.code == 'invalid-email') {
          _errorMessage = 'The email provided is not valid.';
        } else {
          _errorMessage = 'An error occurred during signup: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _generateRandomPassword() {
    // Generates a random 12-character password
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()';
    final random = Random.secure();
    return String.fromCharCodes(Iterable.generate(
      12, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Padhai',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.keyboard_double_arrow_left_outlined,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(232, 67, 130, 238),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(isTablet ? 30.0 : 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: isTablet ? 80 : 50),
              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: isTablet ? 32 : 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Create an account so you can kickstart your goal',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person),
                  labelText: 'Full Name*',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.mail),
                  labelText: 'Email*',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20.0),
              // Role Selection Dropdown
              InputDecorator(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.school),
                  labelText: 'I am a...*',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    isDense: true,
                    isExpanded: true,
                    items: _roles.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value == 'student' ? 'Student/Learner' : 'Teacher',
                          style: TextStyle(fontSize: isTablet ? 16 : 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Qualification Dropdown
              InputDecorator(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.school),
                  labelText: 'Highest Qualification',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedQualification,
                    hint: const Text('Select your qualification'),
                    isDense: true,
                    isExpanded: true,
                    items: _qualifications.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedQualification = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.phone),
                  labelText: 'Contact Number (Optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 30),
              SizedBox(
                width: 140,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size(
                      double.infinity,
                      isTablet ? 50 : 50,
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Sign up',
                          style: TextStyle(
                            fontSize: isTablet ? 20 : 18,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                '*You will receive an email to set your password after registration',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isTablet ? 14 : 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Already have an account? Sign in',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: isTablet ? 18 : 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}