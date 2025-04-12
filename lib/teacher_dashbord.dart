import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padhai/login.dart'; // Import your login page

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(context),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isTablet ? 2 : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isTablet ? 2.5 : 2.5,
              children: [
                _DashboardCard(
                  icon: Icons.library_books,
                  title: 'Course Content',
                  description: 'Manage and update course materials.',
                  color: Colors.blue,
                  gradientColors: [Colors.blue.shade300, Colors.blue.shade700],
                  onTap: () => _showSnackbar(context, 'Course Content tapped'),
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

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users_roles') // Replace with your Firestore collection name
                .doc('teacherId') // Replace with the teacher's document ID
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                return const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Center(
                    child: Text(
                      'Error loading data',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unknown Teacher';
              final profileImage = data['profileImage'] ?? '';

              return DrawerHeader(
                decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 45, // Increased size
                      backgroundImage: profileImage.isNotEmpty
                          ? NetworkImage(profileImage)
                          : null,
                      child: profileImage.isEmpty
                          ? const Icon(Icons.person, size: 45, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 20), // Increased spacing
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20, // Increased font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Computer Science Dept.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Schedule'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()), // Replace with your LoginPage widget
                (route) => false, // This removes all previous routes
              );
    },
        ),
        ],
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
          const CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(
              'https://randomuser.me/api/portraits/women/65.jpg',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Dr. Sarah!',
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
                  '3 classes scheduled today',
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