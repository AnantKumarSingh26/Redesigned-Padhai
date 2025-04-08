import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController(); // New controller for name
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Get Firebase Auth instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Initialize Firestore
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _errorMessage = '';

  Future<void> _signup() async {
    try {
      final String name = _nameController.text.trim(); // Get name
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      final String confirmPassword = _confirmPasswordController.text.trim();

      if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        setState(() {
          _errorMessage = 'Please fill in all the fields.';
        });
        return;
      }

      if (password != confirmPassword) {
        setState(() {
          _errorMessage = 'Passwords do not match.';
        });
        return;
      }

      // Create user with email and password in Firebase
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If signup in Firebase is successful, save additional info to Firestore with default role
      if (userCredential.user != null) {
        await _firestore.collection('users_roles').doc(userCredential.user!.uid).set({
          'name': name, // Save the name
          'email': email, // Save the email (optional, might be redundant with Auth)
          'role': 'student', // Set the default role to 'student'
        });

        // Optionally, send email verification
        // await userCredential.user!.sendEmailVerification();
        Navigator.pop(context); // Go back to the login page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! You are now a student.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'weak-password') {
          _errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          _errorMessage = 'The account already exists for that email.';
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
    }
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
          onPressed: () {
            Navigator.pop(context); // Simple pop to go back
          },
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
                controller: _nameController, // Use the name controller
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person),
                  labelText: 'Enter your Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController, // Use the email controller
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.mail),
                  labelText: 'Enter your E-mail',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController, // Use the password controller
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  labelText: 'Please enter password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _confirmPasswordController, // Use the confirm password controller
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.calendar_today),
                  labelText: 'Please confirm password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 140,
                child: ElevatedButton(
                  onPressed: _signup, // Call the _signup function
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
                  child: Text(
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
                Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Go back to the login page
                },
                child: Text(
                  'Already have an account',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: isTablet ? 18 : 16,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Or continue with',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.facebook,
                      color: Colors.blue,
                      size: isTablet ? 40 : 30,
                    ),
                    onPressed: () {
                      bottompopup(context);
                    },
                  ),
                  IconButton(
                    onPressed: () {
                      bottompopup(context);
                    },
                    icon: Image.asset(
                      'assets/images/google.png',
                      width: isTablet ? 40 : 30,
                      height: isTablet ? 40 : 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bottompopup(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        "Your region doesn't support this feature. Sorry for inconvenience.",
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          color: Colors.redAccent,
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      duration: Duration(seconds: 3),
    ),
  );
}