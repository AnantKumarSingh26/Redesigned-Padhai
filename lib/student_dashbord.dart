import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:padhai/student_screens/recommended_courses.dart';
import 'package:padhai/login.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  // Student data variables
  String studentName = 'Loading...';
  String department = 'Loading...';
  String studentId = 'Loading...';
  String batch = 'Loading...';
  String semester = 'Loading...';
  String email = 'Loading...';
  
  // Courses data
  List<Course> enrolledCourses = [];
  List<Course> recommendedCourses = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      // Get current authenticated user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = 'User not logged in';
          isLoading = false;
        });
        return;
      }

      // Query users_roles collection for the current user's data
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users_roles')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          errorMessage = 'User data not found';
          isLoading = false;
        });
        return;
      }

      // Get the first document (should be only one for each email)
      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data();

      setState(() {
        studentName = userData['name'] ?? 'No Name';
        department = userData['department'] ?? 'No Department';
        studentId = userData['studentId'] ?? 'No ID';
        batch = userData['batch'] ?? 'No Batch';
        semester = userData['semester'] ?? 'No Semester';
        email = userData['email'] ?? user.email ?? 'No Email';
      });

      // Now fetch the courses
      await _fetchCourses(userDoc.id);
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading data: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchCourses(String userId) async {
    try {
      // Fetch enrolled courses
      final enrolledQuery = await FirebaseFirestore.instance
          .collection('enrollments')
          .where('userId', isEqualTo: userId)
          .get();

      final List<Course> tempEnrolled = [];
      
      for (final enrollmentDoc in enrolledQuery.docs) {
        final enrollmentData = enrollmentDoc.data();
        final courseRef = enrollmentData['courseId'] as DocumentReference?;
        
        if (courseRef != null) {
          final courseDoc = await courseRef.get();
          
          if (courseDoc.exists) {
            tempEnrolled.add(
              Course(
                courseDoc['title'] ?? 'No Title',
                courseDoc['code'] ?? 'No Code',
                _getIconForCourse(courseDoc['code']),
                (enrollmentData['progress'] ?? 0).toInt(),
                _getColorForCourse(courseDoc['code']),
              ),
            );
          }
        }
      }

      // Fetch recommended courses (based on department)
      final recommendedQuery = await FirebaseFirestore.instance
          .collection('courses')
          .where('department', isEqualTo: department)
          .where('code', whereNotIn: tempEnrolled.map((c) => c.code).toList().isEmpty ? null : tempEnrolled.map((c) => c.code).toList())
          .limit(3)
          .get();

      final List<Course> tempRecommended = recommendedQuery.docs.map((doc) {
        return Course(
          doc['title'] ?? 'No Title',
          doc['code'] ?? 'No Code',
          _getIconForCourse(doc['code']),
          0, // Recommended courses have 0 progress
          _getColorForCourse(doc['code']),
        );
      }).toList();

      setState(() {
        enrolledCourses = tempEnrolled;
        recommendedCourses = tempRecommended;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading courses: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  IconData _getIconForCourse(String? code) {
    if (code == null) return Icons.school;
    if (code.contains('CS101')) return Icons.code;
    if (code.contains('CS102')) return Icons.memory;
    if (code.contains('CS103')) return Icons.model_training;
    if (code.contains('CS104')) return Icons.web;
    return Icons.school;
  }

  Color _getColorForCourse(String? code) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[code?.hashCode ?? 0 % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dashboard'),
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
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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
                department: department,
                studentId: studentId,
                batch: batch,
                semester: semester,
                email: email,
              ),
              const SizedBox(height: 32),
              
              _buildSectionHeader('My Courses', 'View All', () {
                // Navigation to all courses
              }),
              const SizedBox(height: 16),
              
              isLoading
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Column(
                        children: List.generate(3, (index) => Container(
                          height: 100,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          color: Colors.white,
                        )),
                      ),
                    )
                  : enrolledCourses.isEmpty
                      ? const Text('No courses enrolled yet')
                      : CourseHorizontalList(
                          courses: enrolledCourses,
                          showProgress: true,
                        ),
              
              const SizedBox(height: 32),
              
              _buildSectionHeader('Recommended Courses', 'See All', () {
                // Navigation to recommended courses
              }),
              const SizedBox(height: 16),
              
              isLoading
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Column(
                        children: List.generate(3, (index) => Container(
                          height: 100,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          color: Colors.white,
                        )),
                      ),
                    )
                  : recommendedCourses.isEmpty
                      ? const Text('No recommendations available')
                      : RecommendedCoursesSection(
                          courses: recommendedCourses,
                          onViewAll: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RecommendedCoursesPage()),
                            );
                          },
                        ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          TextButton(
            onPressed: onPressed,
            child: Text(
              action,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StudentProfileCard extends StatelessWidget {
  final String name;
  final String department;
  final String studentId;
  final String batch;
  final String semester;
  final String email;

  const StudentProfileCard({
    super.key,
    required this.name,
    required this.department,
    required this.studentId,
    required this.batch,
    required this.semester,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.shade50,
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 30,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      department,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('ID', studentId),
              _buildInfoItem('Batch', batch),
              _buildInfoItem('Semester', semester),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class CourseHorizontalList extends StatelessWidget {
  final List<Course> courses;
  final bool showProgress;

  const CourseHorizontalList({
    super.key,
    required this.courses,
    required this.showProgress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 215,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index == courses.length - 1 ? 0 : 16,
            ),
            child: CourseCard(
              course: courses[index],
              showProgress: showProgress,
            ),
          );
        },
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Course course;
  final bool showProgress;

  const CourseCard({
    super.key,
    required this.course,
    required this.showProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16)),
            child: Container(
              height: 100,
              color: course.color.withOpacity(0.1),
              child: Center(
                child: Icon(
                  course.icon,
                  size: 40,
                  color: course.color,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  course.code,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                if (showProgress) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: course.progress / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: course.color,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${course.progress}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 12,
                          color: course.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Course {
  final String title;
  final String code;
  final IconData icon;
  final int progress;
  final Color color;

  const Course(this.title, this.code, this.icon, this.progress, this.color);
}

class RecommendedCoursesSection extends StatelessWidget {
  final List<Course> courses;
  final VoidCallback onViewAll;

  const RecommendedCoursesSection({
    super.key,
    required this.courses,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recommended Courses',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: const Text(
                'View All',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 215,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index == courses.length - 1 ? 0 : 16,
                ),
                child: CourseCard(
                  course: courses[index],
                  showProgress: false,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}