import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:padhai/student_screens/all_courses.dart';
import 'package:padhai/login.dart';
import 'package:padhai/student_screens/update_info.dart';
import 'student_profile_card.dart';
import 'course_horizontal_list.dart';
import 'dashboard_controller.dart';
import 'course.dart';
import 'enrolled_courses.dart';

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
  List<Map<String, dynamic>> courseEnrollments = []; // Store enrollments for each course

  @override
  void initState() {
    super.initState();
    _loadData();
    _fetchTokens(); // Fetch tokens dynamically
  }

  Future<void> _loadData() async {
    try {
      final userData = await _controller.fetchUserData();
      final coursesData = await _controller.fetchCourses(
        userData['userId'],
        userData['qualification'],
      );

      // Fetch enrollments for each enrolled course
      List<Map<String, dynamic>> enrollments = [];
      for (var course in coursesData['enrolledCourses']) {
        final courseDoc = await FirebaseFirestore.instance
            .collection('courses')
            .doc(course.id)
            .collection('enrollments')
            .get();

        enrollments.add({
          'courseName': course.name,
          'enrollments': courseDoc.docs.map((doc) {
            final data = doc.data();
            return {
              'name': data['name'], // Only fetch 'name'
              // Ensure 'progress' or any non-existent field is not accessed
            };
          }).toList(),
        });
      }

      setState(() {
        studentName = userData['name'] ?? 'No Name'; // Ensure fallback values
        department = userData['qualification'] ?? 'No Qualification';
        studentId = userData['contact'] ?? 'No Contact';
        email = userData['email'] ?? 'No Email';
        enrolledCourses = coursesData['enrolledCourses'] ?? [];
        recommendedCourses = coursesData['recommendedCourses'] ?? [];
        courseEnrollments = enrollments; // Store fetched enrollments
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading courses: $e'; // Update error message
        isLoading = false;
      });
    }
  }

  Future<void> _fetchTokens() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users_roles')
                .doc(user.uid)
                .get();
        setState(() {
          tokens = userDoc.data()?['tokens'] ?? 0;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to fetch tokens: $e';
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
          leadingWidth: 100, // Set a fixed width for the leading area
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: GestureDetector(
              onTap: () {
                // Navigate to payment.dart in the future
                print('Navigate to payment screen for adding tokens');
              },
              child: StreamBuilder<int>(
                stream: _controller.tokenStream,
                initialData: tokens,
                builder: (context, snapshot) {
                  final currentTokens = snapshot.data ?? 0;
                  return Container(
                    width: 90,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.orange, Colors.pink],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                      border: Border.all(
                        color: const Color.fromARGB(255, 64, 77, 255).withOpacity(0.8),
                        width: 2,
                      ),
                      color: Colors.transparent,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$currentTokens',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          actions: [
            IconButton(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Courses',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            final userDoc = await FirebaseFirestore.instance
                                .collection('users_roles')
                                .doc(user.uid)
                                .get();
                            
                            if (!context.mounted) return;
                            
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EnrolledCoursesPage(
                                  studentId: user.uid,
                                ),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View All',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Colors.blue[700],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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
                            height: 140,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    )
                    : enrolledCourses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school_outlined, 
                              size: 64, 
                              color: Colors.grey[400]
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No enrolled courses yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: enrolledCourses.length,
                        itemBuilder: (context, index) {
                          final course = enrolledCourses[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  // Navigate to course details
                                  print('Navigate to details of ${course.name}');
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: index % 4 == 0
                                          ? [const Color(0xFF6448FE), const Color(0xFF5FC6FF)]
                                          : index % 4 == 1
                                              ? [const Color(0xFFFF9966), const Color(0xFFFF5E62)]
                                              : index % 4 == 2
                                                  ? [const Color(0xFF00B09B), const Color(0xFF96C93D)]
                                                  : [const Color(0xFFE44D26), const Color(0xFFF16529)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              course.icon,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  course.name,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Code: ${course.code}',
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.8),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                // Navigate to course content
                                                print('Starting course: ${course.name}');
                                                // TODO: Add navigation to course content
                                              },
                                              borderRadius: BorderRadius.circular(20),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: Colors.white.withOpacity(0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.play_circle_outline,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Continue Learning',
                                                      style: TextStyle(
                                                        color: Colors.white.withOpacity(0.9),
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
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
