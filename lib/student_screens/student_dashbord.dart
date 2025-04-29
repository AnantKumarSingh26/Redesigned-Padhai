import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:padhai/student_screens/all_courses.dart';
import 'package:padhai/login.dart';
import 'package:padhai/student_screens/update_info.dart';
import 'student_profile_card.dart';
import 'course_horizontal_list.dart';
import 'dashboard_controller.dart';
import 'course.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final DashboardController _controller = DashboardController();
  String studentName = 'Loading...';
  String department = 'Loading...';
  String studentId = 'Loading...';
  String email = 'Loading...';
  List<Course> enrolledCourses = [];
  List<Course> recommendedCourses = [];
  bool isLoading = true;
  String errorMessage = '';
  int tokens = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userData = await _controller.fetchUserData();
      final coursesData = await _controller.fetchCourses(
        userData['userId'],
        userData['qualification'],
      );

      setState(() {
        studentName = userData['name'];
        department = userData['qualification'];
        studentId = userData['contact'];
        email = userData['email'];
        enrolledCourses = coursesData['enrolledCourses'];
        recommendedCourses = coursesData['recommendedCourses'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          leading: IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
          actions: [
            // Token display widget
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                StudentProfileCard(
                  name: studentName,
                  email: email,
                  qualification: department,
                  contact: studentId,
                ),
                const SizedBox(height: 32),
                Text(
                  'My Courses',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                isLoading
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Column(
                          children: List.generate(
                            3,
                            (index) => Container(
                              height: 100,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : enrolledCourses.isEmpty
                        ? const Text('No courses enrolled yet')
                        : CourseHorizontalList(
                            courses: enrolledCourses,
                            showProgress: true,
                          ),
                const SizedBox(height: 32),
                const AllCourses(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UpdateInfoPage()),
            );
          },
          child: const Icon(Icons.edit),
        ),
      ),
    );
  }
}