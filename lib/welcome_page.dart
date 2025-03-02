import 'package:flutter/material.dart';
import 'package:padhai/button.dart';
import 'package:padhai/login.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // State variable to control the animation
  bool isButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to make the layout responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600; // Adjust breakpoint for tablets

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                SizedBox(
                  height: 375,
                  // width: MediaQuery.of(context).size.width,
                  child: Image.asset('assets/images/image.png'),
                ),
                Text(
                  'Discover Your Dream Here',
                  style: TextStyle(
                    fontSize: isTablet ? 40 : 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Description
                Text(
                  'Explore a world of career possibilities with our\ncomprehensive guide.',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Call to Action
                Text(
                  'Start your journey towards a fulfilling career today!',
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Animated Forward Button Box
                CircularAnimatedButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  isPressed: isButtonPressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
