import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyCourses extends StatelessWidget {
  final String studentId;

  const MyCourses({Key? key, required this.studentId}) : super(key: key);

  // Update the _fetchEnrolledCourses method in my_courses.dart
Future<List<Map<String, dynamic>>> _fetchEnrolledCourses() async {
  final enrollmentSnapshot = await FirebaseFirestore.instance
      .collection('enrollments')
      .where('studentId', isEqualTo: studentId)
      .get();

  List<Map<String, dynamic>> courses = [];

  for (var enrollmentDoc in enrollmentSnapshot.docs) {
    final enrollmentData = enrollmentDoc.data();
    final courseId = enrollmentData['courseId'];

    if (courseId != null) {
      final courseDoc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .get();

      if (courseDoc.exists) {
        final courseData = courseDoc.data()!;
        final teacherRef = courseData['instructorId'] as DocumentReference?;

        String teacherName = 'No Teacher';
        if (teacherRef != null) {
          final teacherDoc = await teacherRef.get();
          if (teacherDoc.exists) {
            teacherName = teacherDoc['name'] ?? 'No Teacher';
          }
        }

        courses.add({
          'courseName': courseData['name'] ?? 'No Name',
          'timing': courseData['startTime'] != null && courseData['endTime'] != null
              ? '${courseData['startTime']} - ${courseData['endTime']}'
              : 'No Timing',
          'teacherName': teacherName,
          'category': courseData['category'] ?? 'No Category',
          'fee': courseData['fee']?.toString() ?? 'No Fee',
          'progress': enrollmentData['progress'] ?? 0,
        });
      }
    }
  }

  return courses;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchEnrolledCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final courses = snapshot.data ?? [];

          if (courses.isEmpty) {
            return const Center(child: Text('No enrolled courses.'));
          }

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade300, Colors.purple.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      course['courseName'] ?? 'No Name',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Timing: ${course['timing']}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Teacher: ${course['teacherName']}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Category: ${course['category']}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Fee: ₹${course['fee']}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
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
