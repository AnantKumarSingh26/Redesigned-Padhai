import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:padhai/student_screens/student_dashbord.dart';

class AllCourses extends StatelessWidget {
  const AllCourses({super.key});

  Future<String> _fetchTeacherName(DocumentReference? teacherRef) async {
    if (teacherRef == null) return 'No Teacher';
    try {
      final teacherDoc = await teacherRef.get();
      if (teacherDoc.exists) {
        return teacherDoc.data()?['name'] ?? 'No Name';
      } else {
        return 'No Teacher';
      }
    } catch (e) {
      return 'Error Fetching Name';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('courses').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final courses = snapshot.data?.docs ?? [];

        if (courses.isEmpty) {
          return const Text('No courses available.');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All Courses',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final courseDoc = courses[index];
                final course = courseDoc.data() as Map<String, dynamic>;
                final name = course['name'] ?? 'No Name';
                final timing = course['timing'] ?? 'No Timing';
                final teacherRef = course['teacher'] as DocumentReference?;
                final category = course['category'] ?? 'No Category';

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade300, Colors.blue.shade700, const Color.fromARGB(255, 71, 27, 248)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Timing: $timing',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          FutureBuilder<String>(
                            future: _fetchTeacherName(teacherRef),
                            builder: (context, teacherSnapshot) {
                              if (teacherSnapshot.connectionState == ConnectionState.waiting) {
                                return const Text(
                                  'Fetching Teacher...',
                                  style: TextStyle(color: Colors.white70),
                                );
                              }
                              if (teacherSnapshot.hasError) {
                                return const Text(
                                  'Error Fetching Teacher',
                                  style: TextStyle(color: Colors.white70),
                                );
                              }
                              if (!teacherSnapshot.hasData || teacherSnapshot.data == null) {
                                return const Text(
                                  'No Teacher',
                                  style: TextStyle(color: Colors.white70),
                                );
                              }
                              return Text(
                                'Teacher: ${teacherSnapshot.data}',
                                style: const TextStyle(color: Colors.white70),
                              );
                            },
                          ),
                          Text(
                            'Category: $category',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            'Fee: ₹${course['fee'] ?? 'No Fee'}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blue.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('User not logged in.')),
                                  );
                                  return;
                                }

                                final studentId = user.uid; // Use the logged-in user's UID
                                final courseId = courseDoc.id;
                                final courseName = course['name'] ?? 'No Name';
                                final fee = course['fee'] ?? 0;

                                // Fetch user tokens
                                final userDoc = await FirebaseFirestore.instance
                                    .collection('users_roles')
                                    .doc(studentId)
                                    .get();

                                int tokens = 0;
                                if (userDoc.exists && userDoc.data() != null) {
                                  tokens = userDoc.data()!['tokens'] ?? 0;
                                }

                                if (tokens < fee) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Insufficient tokens.')),
                                  );
                                  return;
                                }

                                // Deduct fee from tokens
                                tokens = (tokens - fee.toInt()).toInt();
                                await FirebaseFirestore.instance
                                    .collection('users_roles')
                                    .doc(studentId)
                                    .update({'tokens': tokens});

                                // Add to enrollments collection under course
                                await FirebaseFirestore.instance
                                    .collection('courses')
                                    .doc(courseId)
                                    .collection('enrollments')
                                    .doc(studentId)
                                    .set({
                                  'enrolledAt': FieldValue.serverTimestamp(),
                                  'accessGranted': true, // Grant access to course material and mock tests
                                  'progress': 0, // Initial progress
                                });

                                // Add to top-level enrollments collection for My Courses
                                await FirebaseFirestore.instance
                                    .collection('enrollments')
                                    .add({
                                  'studentId': studentId,
                                  'courseId': courseId,
                                  'courseName': courseName,
                                  'fee': fee,
                                  'enrolledAt': FieldValue.serverTimestamp(),
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Enrolled in $courseName')),
                                );

                                // Refresh the page
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const StudentDashboard(),
                                  ),
                                );
                              },
                              child: const Text('Join Now'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
