import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'admin_dashbord.dart';
import 'teacher_dashbord.dart';
import 'student_dashbord.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Check session validity
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final int? loginTimestamp = prefs.getInt('loginTimestamp');
  final String? userRole = prefs.getString('userRole');

  Widget initialScreen;

  if (loginTimestamp != null && userRole != null) {
    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    final int thirtyMinutes = 30 * 60 * 1000;

    if (currentTime - loginTimestamp < thirtyMinutes) {
      // Session is valid, navigate to respective dashboard
      if (userRole == 'admin') {
        initialScreen = const AdminDashboard();
      } else if (userRole == 'teacher') {
        initialScreen = const TeacherDashboard();
      } else {
        initialScreen = const StudentDashboard();
      }
    } else {
      // Session expired, clear session
      prefs.clear();
      initialScreen = const LoginPage();
    }
  } else {
    // No session, navigate to login
    initialScreen = const LoginPage();
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      home: initialScreen,
    );
  }
}