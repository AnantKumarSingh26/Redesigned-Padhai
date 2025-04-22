import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padhai/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:padhai/teacher_screens/courses.dart';
import 'package:shimmer/shimmer.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  // Teacher data 
  String teacherName = 'Loading...';
  String department = 'Loading...';
  String email = 'Loading...';
  String profileImageUrl = '';
  int classesToday = 0;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _resetTimestamp(); 
    _fetchTeacherData();
    _fetchTodaysClasses();
  }

  Future<void> _resetTimestamp() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('loginTimestamp', DateTime.now().millisecondsSinceEpoch);
    print('Timestamp reset to: ${DateTime.now()}');
  }

  Future<void> _fetchTeacherData() async {
    try {
      // who  is the current user 
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = 'User not logged in';
          isLoading = false;
        });
        return;
      }

      // get data of current teacher
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users_roles')
          .where('email', isEqualTo: user.email)
          .where('role', isEqualTo: 'teacher')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          errorMessage = 'Teacher data not found';
          isLoading = false;
        });
        return;
      }

      // Get the teacher document
      final teacherDoc = querySnapshot.docs.first;
      final teacherData = teacherDoc.data();

      // Format the name properly (capitalize first letters)
      String formattedName = teacherData['name'] ?? 'Teacher';
      if (formattedName.isNotEmpty) {
        formattedName = formattedName.split(' ')
            .map((word) => word.isNotEmpty 
                ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                : '')
            .join(' ')
            .trim();
      }

      setState(() {
        teacherName = formattedName;
        department = teacherData['department'] ?? 'Department';
        email = teacherData['email'] ?? user.email ?? '';
        profileImageUrl = teacherData['profileImage'] ?? '';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading teacher data: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchTodaysClasses() async {
    try {
      // Frmat today's date to match the format in Firestore
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // Query schedule collection for today's classes
      final classesQuery = await FirebaseFirestore.instance
          .collection('schedule')
          .where('date', isEqualTo: today)
          .where('teacherEmail', isEqualTo: FirebaseAuth.instance.currentUser?.email)
          .get();

      setState(() {
        classesToday = classesQuery.size;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        classesToday = 0;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout,color: Colors.white,),
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
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            isLoading = true;
          });
          await _fetchTeacherData();
          await _fetchTodaysClasses();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              _buildWelcomeHeader(context),
              const SizedBox(height: 20),
              isLoading
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: isTablet ? 2 : 1,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: isTablet ? 2.5 : 2.5,
                        children: List.generate(6, (index) => Container(
                          color: Colors.white,
                          margin: const EdgeInsets.all(8),
                        )),
                      ),
                    )
                  : GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isTablet ? 2 : 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isTablet ? 2.5 : 2.5,
                      children: [
                        _DashboardCard(
                          icon: Icons.library_books,
                          title: 'Courses',
                          description: 'Manage and update course materials.',
                          color: Colors.blue,
                          gradientColors: [Colors.blue.shade300, Colors.blue.shade700],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CoursesPage()),
                          ),
                        ),
                        _DashboardCard(
                          icon: Icons.assignment,
                          title: 'Mock Tests',
                          description: 'Create and evaluate mock tests.',
                          color: Colors.green,
                          gradientColors: [Colors.green.shade300, Colors.green.shade700],
                          onTap: () => _showSnackbar(context, 'Mock Tests tapped'),
                        ),
                        _DashboardCard(
                          icon: Icons.assessment,
                          title: 'Student Reports',
                          description: 'View and analyze student performance.',
                          color: Colors.orange,
                          gradientColors: [Colors.orange.shade300, Colors.orange.shade700],
                          onTap: () => _showSnackbar(context, 'Student Reports tapped'),
                        ),
                        _DashboardCard(
                          icon: Icons.announcement,
                          title: 'Announcements',
                          description: 'Post and manage announcements.',
                          color: Colors.purple,
                          gradientColors: [Colors.purple.shade300, Colors.purple.shade700],
                          onTap: () => _showSnackbar(context, 'Announcements tapped'),
                        ),
                        _DashboardCard(
                          icon: Icons.question_answer,
                          title: 'Student Queries',
                          description: 'Respond to student questions.',
                          color: Colors.teal,
                          gradientColors: [Colors.teal.shade300, Colors.teal.shade700],
                          onTap: () => _showSnackbar(context, 'Student Queries tapped'),
                        ),
                        _DashboardCard(
                          icon: Icons.settings,
                          title: 'Settings',
                          description: 'Adjust application preferences.',
                          color: Colors.grey,
                          gradientColors: [Colors.grey.shade400, Colors.grey.shade600],
                          onTap: () => _showSnackbar(context, 'Settings tapped'),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: profileImageUrl.isNotEmpty
                ? NetworkImage(profileImageUrl)
                : null,
            child: profileImageUrl.isEmpty
                ? const Icon(Icons.person, size: 30, color: Colors.blue)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $teacherName!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Today: ${DateFormat('EEEE, MMMM d').format(DateTime.now())}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '$classesToday ${classesToday == 1 ? 'class' : 'classes'} scheduled today',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}