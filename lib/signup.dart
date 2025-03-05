import 'package:flutter/material.dart';
import 'package:padhai/login.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600; // Adjust breakpoint for tablets

    return Scaffold(
      
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(isTablet ? 30.0 : 20.0), // Responsive padding
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: isTablet ? 80 : 50), // Responsive spacing
              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: isTablet ? 32 : 26, // Responsive font size
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Create an account so you can kickstart your goal',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14, // Responsive font size
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _EmailTextField(), // Separate widget for email field
              const SizedBox(height: 20),
              _PasswordTextField( // Separate widget for password field
                obscureText: _obscurePassword,
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              const SizedBox(height: 20),
              _ConfirmPasswordTextField( // Separate widget for confirm password field
                obscureText: _obscureConfirmPassword,
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 140,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size(double.infinity, isTablet ? 50 : 50), // Responsive button size
                  ),
                  child: Text(
                    'Sign up',
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 18, // Responsive font size
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                   Navigator.pop(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupPage(),
                      ),
                    );
                },
                child: Text(
                  'Already have an account',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: isTablet ? 18 : 16, // Responsive font size
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Or continue with',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: isTablet ? 16 : 14, // Responsive font size
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
                      size: isTablet ? 40 : 30, // Responsive icon size
                    ),
                    onPressed: () {},
                  ),
                   IconButton(
                    onPressed: () {},
                    icon: Image.asset(
                    'assets/images/google.png',
                      width: isTablet ? 40 : 30, // Responsive icon size
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

// Separate widget for email text field
class _EmailTextField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.mail),
        labelText: 'Enter your E-mail',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

// Separate widget for password text field
class _PasswordTextField extends StatelessWidget {
  final bool obscureText;
  final VoidCallback onPressed;

  const _PasswordTextField({
    required this.obscureText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock),
        labelText: 'Please enter password',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

// Separate widget for confirm password text field
class _ConfirmPasswordTextField extends StatelessWidget {
  final bool obscureText;
  final VoidCallback onPressed;

  const _ConfirmPasswordTextField({
    required this.obscureText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.calendar_today),
        labelText: 'Please confirm password',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: onPressed,
        ),
      ),
    );
  }
}