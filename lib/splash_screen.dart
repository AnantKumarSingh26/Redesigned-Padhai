import 'package:flutter/material.dart';
import 'package:padhai/admin_screens/manage_course_content.dart';
import 'welcome_page.dart'; // Import the WelcomePage

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the WelcomePage after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const WelcomePage(),
        ), // Navigate to WelcomePage
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        58,
        116,
        183,
      ), // Set your desired background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your app logo or icon here
            const Icon(Icons.school, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            // Add your app name or title here
            const Text(
              'Padhai',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 238, 255, 141),
                    const Color.fromARGB(255, 255, 255, 255), 
                    const Color.fromARGB(213, 178, 248, 208)// Adjust colors to fit your theme
                  ],
                ).createShader(bounds);
              },
              child: Text(
                'Infinity Labs',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w200,
                  color:
                      Colors.white, // Temporary color, overridden by ShaderMask
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Add a loading indicator (optional)
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
