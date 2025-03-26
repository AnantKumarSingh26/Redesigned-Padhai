import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        padding: EdgeInsets.all(
          isTablet ? 24 : 16,
        ), // Adjust padding for responsiveness
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(context),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount:
                  isTablet ? 2 : 1, // Adjust grid columns for responsiveness
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isTablet ? 2.5 : 3, // Adjust aspect ratio
              children: [
                _DashboardCard(
                  icon: Icons.library_books,
                  title: 'Course Content',
                  description: 'Manage and update course materials.',
                  color: Colors.blue,
                  gradientColors: [Colors.blue.shade300, Colors.blue.shade700],
                  onTap: () => _navigateToCourseContent(context),
                ),
                _DashboardCard(
                  icon: Icons.assignment,
                  title: 'Mock Tests',
                  description: 'Create and evaluate mock tests.',
                  color: Colors.green,
                  gradientColors: [
                    Colors.green.shade300,
                    Colors.green.shade700,
                  ],
                  onTap: () => _navigateToMockTests(context),
                ),
                _DashboardCard(
                  icon: Icons.assessment,
                  title: 'Student Reports',
                  description: 'View and analyze student performance.',
                  color: Colors.orange,
                  gradientColors: [
                    Colors.orange.shade300,
                    Colors.orange.shade700,
                  ],
                  onTap: () => _navigateToStudentReports(context),
                ),
                _DashboardCard(
                  icon: Icons.announcement,
                  title: 'Announcements',
                  description: 'Post and manage announcements.',
                  color: Colors.purple,
                  gradientColors: [
                    Colors.purple.shade300,
                    Colors.purple.shade700,
                  ],
                  onTap: () => _navigateToAnnouncements(context),
                ),
                _DashboardCard(
                  icon: Icons.question_answer,
                  title: 'Student Queries',
                  description: 'Respond to student questions.',
                  color: Colors.teal,
                  gradientColors: [Colors.teal.shade300, Colors.teal.shade700],
                  onTap: () => _navigateToStudentQueries(context),
                ),
                _DashboardCard(
                  icon: Icons.settings,
                  title: 'Settings',
                  description: 'Adjust application preferences.',
                  color: Colors.grey,
                  gradientColors: [Colors.grey.shade400, Colors.grey.shade600],
                  onTap: () => _navigateToSettings(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    'https://randomuser.me/api/portraits/women/65.jpg',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Dr. Sarah Johnson',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Computer Science Dept.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
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
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/decide');
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Today: ${DateFormat('EEEE, MMMM d').format(DateTime.now())}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '3 classes scheduled today',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.blue.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToCourseContent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CourseContentScreen()),
    );
  }

  void _navigateToMockTests(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MockTestsScreen()),
    );
  }

  void _navigateToStudentReports(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StudentReportsScreen()),
    );
  }

  void _navigateToAnnouncements(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AnnouncementsScreen()),
    );
  }

  void _navigateToStudentQueries(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StudentQueriesScreen()),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  // Other navigation methods...
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description; // Added description
  final Color color;
  final List<Color> gradientColors; // Added gradient colors
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.description, // Added description
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
              colors: gradientColors, // Use gradient colors
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
                description, // Display description
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

// Course Content Screen
class CourseContentScreen extends StatelessWidget {
  const CourseContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Content')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddContentDialog(context),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Flutter Development'),
          _buildFileItem(
            'Introduction to Flutter',
            'PDF',
            Icons.picture_as_pdf,
          ),
          _buildFileItem('Widgets Basics', 'Video', Icons.video_library),
          _buildFileItem('State Management', 'PDF', Icons.picture_as_pdf),

          _buildSectionHeader('Advanced Dart'),
          _buildFileItem('Dart OOP Concepts', 'PDF', Icons.picture_as_pdf),
          _buildFileItem('Async Programming', 'Slides', Icons.slideshow),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildFileItem(String title, String type, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(type),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddContentDialog(BuildContext context) async {
    // Implementation for adding new content
  }
}

// Mock Tests Screen
class MockTestsScreen extends StatelessWidget {
  const MockTestsScreen({super.key});

  Future<void> _showAddTestDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Mock Test'),
          content: const TextField(
            decoration: InputDecoration(hintText: 'Enter test details'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Add logic to save the test
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mock Tests')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddTestDialog(context),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTestCard(
            'Flutter Midterm',
            '45 questions',
            'Due: May 15, 2023',
            Colors.blue,
          ),
          _buildTestCard(
            'Dart Fundamentals',
            '30 questions',
            'Due: June 1, 2023',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard(
    String title,
    String details,
    String date,
    Color color,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.assignment, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit Test'),
                        ),
                        const PopupMenuItem(
                          value: 'results',
                          child: Text('View Results'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete Test'),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(details),
            const SizedBox(height: 4),
            Text(date, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: 0.65,
              backgroundColor: Colors.grey.shade300,
              color: color,
            ),
            const SizedBox(height: 8),
            const Text('65% students completed'),
          ],
        ),
      ),
    );
  }
}

// Student Reports Screen
class StudentReportsScreen extends StatelessWidget {
  const StudentReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Reports')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Search Students',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            DataTable(
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Attendance')),
                DataColumn(label: Text('Marks')),
                DataColumn(label: Text('Status')),
              ],
              rows: [
                _buildStudentRow('John Doe', '85%', '92/100', 'Excellent'),
                _buildStudentRow('Jane Smith', '78%', '85/100', 'Good'),
                _buildStudentRow('Alex Johnson', '92%', '88/100', 'Very Good'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildStudentRow(
    String name,
    String attendance,
    String marks,
    String status,
  ) {
    Color statusColor = Colors.green;
    if (status == 'Good') statusColor = Colors.blue;
    if (status == 'Average') statusColor = Colors.orange;

    return DataRow(
      cells: [
        DataCell(Text(name)),
        DataCell(Text(attendance)),
        DataCell(Text(marks)),
        DataCell(
          Chip(
            label: Text(status),
            backgroundColor: statusColor.withOpacity(0.2),
            labelStyle: TextStyle(color: statusColor),
          ),
        ),
      ],
    );
  }
}

// Announcements Screen
class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  Future<void> _showAddAnnouncementDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Announcement'),
          content: const TextField(
            decoration: InputDecoration(hintText: 'Enter announcement details'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Add logic to save the announcement
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddAnnouncementDialog(context),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          AnnouncementCard(
            title: 'Midterm Exam Schedule',
            content:
                'The midterm exam will be held on May 15th at 10 AM in Room 205.',
            date: 'May 1, 2023',
            isImportant: true,
          ),
          AnnouncementCard(
            title: 'Assignment Submission',
            content:
                'Last date for Flutter project submission extended to May 20th.',
            date: 'April 28, 2023',
          ),
        ],
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String content;
  final String date;
  final bool isImportant;

  const AnnouncementCard({
    super.key,
    required this.title,
    required this.content,
    required this.date,
    this.isImportant = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: isImportant ? Colors.orange.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isImportant)
                  const Icon(Icons.error, color: Colors.orange)
                else
                  const Icon(Icons.announcement),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isImportant ? Colors.orange : null,
                  ),
                ),
                const Spacer(),
                Text(date, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 8),
            Text(content),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(child: const Text('Edit'), onPressed: () {}),
                TextButton(child: const Text('Delete'), onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Student Queries Screen
class StudentQueriesScreen extends StatelessWidget {
  const StudentQueriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Queries')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          QueryCard(
            studentName: 'John Doe',
            question: 'Can you explain the Provider pattern again?',
            date: '2 hours ago',
            isResolved: false,
          ),
          QueryCard(
            studentName: 'Jane Smith',
            question: 'When will the next assignment be posted?',
            date: '1 day ago',
            isResolved: true,
          ),
        ],
      ),
    );
  }
}

class QueryCard extends StatelessWidget {
  final String studentName;
  final String question;
  final String date;
  final bool isResolved;

  const QueryCard({
    super.key,
    required this.studentName,
    required this.question,
    required this.date,
    required this.isResolved,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    'https://randomuser.me/api/portraits/men/41.jpg',
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  studentName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Chip(
                  label: Text(isResolved ? 'Resolved' : 'Pending'),
                  backgroundColor:
                      isResolved
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                  labelStyle: TextStyle(
                    color: isResolved ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(question),
            const SizedBox(height: 8),
            Text(date, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            if (!isResolved)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type your reply...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send), onPressed: () {}),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// Settings Screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Account Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(Icons.person, 'Profile Information'),
          _buildSettingsItem(Icons.email, 'Email Preferences'),
          _buildSettingsItem(Icons.notifications, 'Notification Settings'),
          const Divider(height: 32),
          const Text(
            'App Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(Icons.color_lens, 'Theme'),
          _buildSettingsItem(Icons.language, 'Language'),
          const Divider(height: 32),
          _buildSettingsItem(Icons.help, 'Help & Support'),
          _buildSettingsItem(Icons.logout, 'Logout', isLogout: true),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : null),
      title: Text(title, style: TextStyle(color: isLogout ? Colors.red : null)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
