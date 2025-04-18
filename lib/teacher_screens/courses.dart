import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:padhai/teacher_screens/golive.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  String? instructorId;

  @override
  void initState() {
    super.initState();
    _fetchInstructorId();
  }

  Future<void> _fetchInstructorId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users_roles')
            .where('email', isEqualTo: user.email)
            .where('role', isEqualTo: 'teacher')
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            instructorId = querySnapshot.docs.first.id;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching instructor ID: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Courses'),
        centerTitle: true,
      ),
      body: instructorId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('courses')
                  .where('instructorId', isEqualTo: instructorId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No courses assigned.'));
                }

                final courses = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade300, Colors.blue.shade700],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                course['name'] ?? 'Unnamed Course',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Category: ${course['category'] ?? 'N/A'}',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  if (course['startTime'] != null && course['endTime'] != null)
                                    Text(
                                      'Time: ${DateFormat.jm().format((course['startTime'] as Timestamp).toDate())} - ${DateFormat.jm().format((course['endTime'] as Timestamp).toDate())}',
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                ],
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    final now = DateTime.now();
                                    final startTime = course['startTime'] as Timestamp?;
                                    final endTime = course['endTime'] as Timestamp?;

                                    if (startTime != null && endTime != null) {
                                      final start = startTime.toDate();
                                      final end = endTime.toDate();

                                      // Handle cases where the end time is on the next day
                                      if ((now.isAfter(start) && now.isBefore(end)) ||
                                          (start.isAfter(end) && (now.isAfter(start) || now.isBefore(end)))) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => GoLivePage(courseId: courses[index].id),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('You can only go live during the scheduled time.'),
                                          ),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Course timing not set.'),
                                        ),
                                      );
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      const Text('Go Live'),
                                      if (course['startTime'] != null && course['endTime'] != null)
                                        Text(
                                          'Live Period: ${DateFormat.jm().format((course['startTime'] as Timestamp).toDate())} - ${DateFormat.jm().format((course['endTime'] as Timestamp).toDate())}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}