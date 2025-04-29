import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AllCourses extends StatelessWidget {
  const AllCourses({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QuerySnapshot>>(
      future: Future.wait([
        FirebaseFirestore.instance.collection('courses').get(),
        FirebaseFirestore.instance
            .collection('users_roles')
            .where('role', isEqualTo: 'teacher')
            .get(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // Create map of teacher IDs to names
        final teacherMap = <String, String>{};
        for (final doc in snapshot.data![1].docs) {
          teacherMap[doc.id] = doc['name'] ?? 'Unknown Teacher';
        }

        final courses = snapshot.data![0].docs;

        if (courses.isEmpty) {
          return const Text('No courses available.');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All Courses',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
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
                final timing =
                    course['startTime'] != null && course['endTime'] != null
                        ? '${course['startTime']} - ${course['endTime']}'
                        : 'No Timing';
                final category = course['category'] ?? 'No Category';
                final fee = course['fee']?.toString() ?? 'No Fee';

                // Handle teacher reference - supports both DocumentReference and String ID
                String? teacherName;
                final instructorField =
                    course['instructorId'] ?? course['teacher'];

                if (instructorField is DocumentReference) {
                  teacherName = teacherMap[instructorField.id];
                } else if (instructorField is String) {
                  teacherName = teacherMap[instructorField];
                }

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade300,
                          Colors.blue.shade700,
                          const Color.fromARGB(255, 71, 27, 248),
                        ],
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
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Teacher: ${teacherName ?? 'Not assigned'}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            'Timing: $timing',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            'Category: $category',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            'Fee: ₹$fee',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: // Update the ElevatedButton in all_courses.dart
                                ElevatedButton(
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
                                    const SnackBar(
                                      content: Text(
                                        'Please login to join courses',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                // Check if already enrolled
                                final enrollmentCheck =
                                    await FirebaseFirestore.instance
                                        .collection('courses')
                                        .doc(courseDoc.id)
                                        .collection('enrollments')
                                        .doc(user.uid)
                                        .get();

                                if (enrollmentCheck.exists) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'You are already enrolled in this course',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                // Get user tokens
                                final userDoc =
                                    await FirebaseFirestore.instance
                                        .collection('users_roles')
                                        .doc(user.uid)
                                        .get();
                                final int tokens =
                                    userDoc.data()?['tokens'] ?? 0;
                                final int courseFee =
                                    int.tryParse(course['fee'] ?? '0') ?? 0;

                                if (tokens < courseFee) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Insufficient tokens to join this course',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                // Deduct tokens and enroll
                                try {
                                  final batch =
                                      FirebaseFirestore.instance.batch();

                                  // Deduct tokens
                                  batch.update(
                                    FirebaseFirestore.instance
                                        .collection('users_roles')
                                        .doc(user.uid),
                                    {
                                      'tokens': FieldValue.increment(
                                        -courseFee,
                                      ),
                                    },
                                  );

                                  // Add to course enrollments
                                  batch.set(
                                    FirebaseFirestore.instance
                                        .collection('courses')
                                        .doc(courseDoc.id)
                                        .collection('enrollments')
                                        .doc(user.uid),
                                    {
                                      'enrolledAt':
                                          FieldValue.serverTimestamp(),
                                      'progress': 0,
                                    },
                                  );

                                  // Add to global enrollments
                                  batch.set(
                                    FirebaseFirestore.instance
                                        .collection('enrollments')
                                        .doc(),
                                    {
                                      'studentId': user.uid,
                                      'courseId': courseDoc.id,
                                      'courseName': name,
                                      'enrolledAt':
                                          FieldValue.serverTimestamp(),
                                      'fee': courseFee,
                                    },
                                  );

                                  await batch.commit();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Successfully joined $name',
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error joining course: $e'),
                                    ),
                                  );
                                }
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
