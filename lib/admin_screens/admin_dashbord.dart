import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../welcome_page.dart';
import 'manage_user_accounts.dart';
import 'manage_course_content.dart';
import 'performace.dart';
import 'performance1.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // Enable back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Ensure back navigation
        ),
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Add logic to refresh the admin dashboard data here
          print('Admin Dashboard refreshed');
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Admin Tools', Icons.admin_panel_settings),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? 2 : 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isTablet ? 2.5 : 2.5,
                ),
                itemCount: _adminOptions.length,
                itemBuilder: (context, index) {
                  return _AdminOptionCard(option: _adminOptions[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Logout'),
              ),
            ],
          ),
    );

    if (shouldLogout ?? false) {
      // Clear session data (optional)
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Navigate to the WelcomePage and remove all other routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
        (route) => false, // Remove all routes from the stack
      );
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 28, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _AdminOptionCard extends StatelessWidget {
  final AdminOption option;

  const _AdminOptionCard({required this.option});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (option.title == 'Manage User Accounts') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserManagementScreen(),
              ),
            );
          } else if (option.title == 'Manage Course Catalog') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CourseManagementScreen()),
            );
          } else if (option.title == 'Manage System Performance') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PerformanceScreen(),
              ),
            );
          } else if (option.title == 'Generate Reports') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReportsScreen()),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                option.color.withOpacity(0.1),
                option.color.withOpacity(0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Icon(option.icon, size: 40, color: option.color),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      option.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      option.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// Admin Options Data
final List<AdminOption> _adminOptions = [
  AdminOption(
    title: 'Manage User Accounts',
    description: 'Add, edit, or remove user accounts and permissions.',
    icon: Icons.people,
    color: Colors.blue,
  ),
  AdminOption(
    title: 'Manage Course Catalog',
    description: 'Add, update, or remove courses from the catalog.',
    icon: Icons.library_books,
    color: Colors.green,
  ),
  AdminOption(
    title: 'Manage System Performance',
    description: 'Monitor and optimize system performance metrics.',
    icon: Icons.analytics,
    color: Colors.orange,
  ),
  AdminOption(
    title: 'Generate Reports',
    description:
        'Generate detailed reports on users, courses, and system usage.',
    icon: Icons.bar_chart,
    color: Colors.purple,
  ),
];

class AdminOption {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  AdminOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
