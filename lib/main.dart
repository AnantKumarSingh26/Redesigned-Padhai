import 'package:flutter/material.dart';
// import 'package:padhai/student_dashbord.dart';
import 'splash_screen.dart'; // Import the SplashScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      home: const SplashScreen(),
      // home: const StudentDashbord() 
    );
  }
}

