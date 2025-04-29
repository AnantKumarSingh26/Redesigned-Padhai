import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padhai/admin_screens/admin_dashbord.dart';
import 'package:padhai/student_screens/student_dashbord.dart';
import 'package:padhai/signup.dart';
import 'package:padhai/teacher_screens/teacher_dashbord.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _obscureText = true;
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _resetTimestamp() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('loginTimestamp', DateTime.now().millisecondsSinceEpoch);
    print('Timestamp reset to: ${DateTime.now()}');
  }

  // Add additional debug logs to the `_login` method to capture more details during the login process.
  Future<void> _login() async {
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });
    try {
      final String email = _emailController.text.trim().toLowerCase();
      final String password = _passwordController.text;

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        setState(() {
          _errorMessage = 'Please enter a valid email address';
          _isLoading = false;
        });
        return;
      }

      if (email.isEmpty || password.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter both email and password.';
          _isLoading = false;
        });
        return;
      }

      print('Attempting to login with email: $email');

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        print('Authentication successful. User ID: ${userCredential.user!.uid}');
        final userDoc = await _firestore.collection('users_roles').doc(userCredential.user!.uid).get();

        if (userDoc.exists && userDoc.data()!.containsKey('role')) {
          final userRole = userDoc.data()!['role'].toString().toLowerCase();
          print('User Role found: $userRole');

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('loginTimestamp', DateTime.now().millisecondsSinceEpoch);
          await prefs.setString('userRole', userRole);

          if (!mounted) return;

          if (userRole == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboard()),
            ).then((_) => _resetTimestamp());
          } else if (userRole == 'teacher') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TeacherDashboard()),
            ).then((_) => _resetTimestamp());
          } else if (userRole == 'student') {
            print('Navigating to Student Dashboard');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const StudentDashboard()),
            ).then((_) => _resetTimestamp());
          } else {
            setState(() {
              _errorMessage = 'Invalid user role: $userRole';
              _isLoading = false;
            });
          }
        } else {
          print('User role not found in Firestore for user ID: ${userCredential.user!.uid}');
          setState(() {
            _errorMessage = 'User role not found. Please contact support.';
            _isLoading = false;
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      setState(() {
        if (e.code == 'user-not-found') {
          _errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          _errorMessage = 'Wrong password provided for that user.';
        } else if (e.code == 'invalid-email') {
          _errorMessage = 'Invalid email format.';
        } else if (e.code == 'invalid-credential') {
          _errorMessage = 'Invalid email or password.';
        } else {
          _errorMessage = 'Login error: ${e.message}';
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Unexpected error: $e');
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _sendPasswordResetEmail() async {
    final String email = _emailController.text.trim();
    
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent to $email'),
          duration: const Duration(seconds: 3),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _errorMessage = 'No user found with this email address';
        } else {
          _errorMessage = 'Error sending reset email: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Padhai',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(isTablet ? 30.0 : 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: isTablet ? 50 : 30),
              const Center(
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Color(0xFF1F41BB),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Welcome back champ, you've been missed!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(157, 92, 106, 125),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person),
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : _sendPasswordResetEmail,
                    child: const Text(
                      'Forgot your password?',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () {
                    _resetTimestamp();
                    _login();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 40 : 40,
                      vertical: 10,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
                  ),
                ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupPage()),
                    );
                  },
                  child: const Text(
                    'Create new Account',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Or continue with',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: isTablet ? 18 : 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _isLoading ? null : () {
                      bottompopup(context);
                    },
                    icon: Icon(
                      Icons.facebook,
                      color: Colors.blue[800],
                      size: isTablet ? 40 : 30,
                    ),
                  ),
                  IconButton(
                    onPressed: _isLoading ? null : () {
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
      persistentFooterButtons: [
        Center(
          child: Text(
            'Powered by @Infinity Labs',
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
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