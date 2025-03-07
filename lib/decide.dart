import 'package:flutter/material.dart';
import 'package:padhai/adminDashbord.dart';
import 'package:padhai/student_dashbord.dart';
import 'package:padhai/teacher_dashbord.dart';

class DashboardSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  MaterialPageRoute(builder: (context) => StudentDashbord()),
                );
                // Navigate to Student Dashboard
              },
              child: Text('Student Dashboard'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TeacherDashboard(),
                  ),
                );
                // Navigate to Teacher Dashboard
              },
              child: Text('Teacher Dashboard'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminDashboard(),
                  ),
                );
                // Navigate to Admin Dashboard
              },
              child: Text('Admin Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
