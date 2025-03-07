import 'package:flutter/material.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Teacher Dashboard',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      drawer: _buildDrawerMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _buildDashboardCard(
              Icons.book,
              'Manage Course Content',
              Colors.orange,
            ),
            _buildDashboardCard(
              Icons.assignment,
              'Mock Assignments',
              Colors.green,
            ),
            _buildDashboardCard(
              Icons.bar_chart,
              'Student Progress Tracking',
              Colors.blue,
            ),
            _buildDashboardCard(
              Icons.notifications,
              'Announcements',
              Colors.red,
            ),
            _buildDashboardCard(Icons.chat, 'Student Queries', Colors.purple),
            _buildDashboardCard(Icons.settings, 'Settings', Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerMenu() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.4)),
            child: const Center(
              child: Text(
                'Menu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          _buildDrawerItem(Icons.person, 'Profile Update'),
          _buildDrawerItem(Icons.settings, 'Settings'),
          _buildDrawerItem(Icons.logout, 'Logout'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontSize: 18)),
      onTap: () {
       
        
      },
    );
  }

  Widget _buildDashboardCard(IconData icon, String title, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: color.withOpacity(0.1),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
