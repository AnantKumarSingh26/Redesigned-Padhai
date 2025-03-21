import 'package:flutter/material.dart';

class TeacherDashboard extends StatelessWidget {
   TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Teacher Dashboard',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 10,
        shadowColor: Colors.blue.withOpacity(0.5),
        centerTitle: true,
      ),
      drawer: _buildDrawerMenu(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.2,
          ),
          itemCount: _dashboardItems.length,
          itemBuilder: (context, index) {
            return _buildDashboardCard(
              _dashboardItems[index].icon,
              _dashboardItems[index].title,
              _dashboardItems[index].gradient,
            );
          },
        ),
      ),
    );
  }

  Widget _buildDrawerMenu(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.lightBlue.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: const Text(
              'John Doe',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text('john.doe@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.blue,
              ),
            ),
          ),
          _buildDrawerItem(Icons.person, 'Profile Update', () {
            // Navigate to profile update
          }),
          _buildDrawerItem(Icons.settings, 'Settings', () {
            // Navigate to settings
          }),
          _buildDrawerItem(Icons.logout, 'Logout', () {
            // Handle logout
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDashboardCard(IconData icon, String title, Gradient gradient) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.3),
      child: InkWell(
        onTap: () {
          // Handle card tap
        },
        borderRadius: BorderRadius.circular(15),
        splashColor: Colors.white.withOpacity(0.2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: gradient,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final List<DashboardItem> _dashboardItems = [
    DashboardItem(
      Icons.book,
      'Manage Course Content',
      LinearGradient(
        colors: [Colors.orange, Colors.deepOrange],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    DashboardItem(
      Icons.assignment,
      'Mock Assignments',
      LinearGradient(
        colors: [Colors.green, Colors.lightGreen],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    DashboardItem(
      Icons.bar_chart,
      'Student Progress Tracking',
      LinearGradient(
        colors: [Colors.blue, Colors.lightBlue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    DashboardItem(
      Icons.notifications,
      'Announcements',
      LinearGradient(
        colors: [Colors.red, Colors.pink],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    DashboardItem(
      Icons.chat,
      'Student Queries',
      LinearGradient(
        colors: [Colors.purple, Colors.deepPurple],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    DashboardItem(
      Icons.settings,
      'Settings',
      LinearGradient(
        colors: [Colors.grey, Colors.blueGrey],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];
}

class DashboardItem {
  final IconData icon;
  final String title;
  final Gradient gradient;

  DashboardItem(this.icon, this.title, this.gradient);
}