import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'course.dart';

class DashboardController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> fetchUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final querySnapshot = await _firestore
          .collection('users_roles')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) throw Exception('User data not found');

      final userDoc = querySnapshot.docs.first;
      return {
        'name': userDoc['name'] ?? 'No Name',
        'qualification': userDoc['qualification'] ?? 'No Qualification',
        'contact': userDoc['contact'] ?? 'No Contact',
        'email': userDoc['email'] ?? user.email ?? 'No Email',
        'userId': userDoc.id,
      };
    } catch (e) {
      throw Exception('Error loading data: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> fetchCourses(String userId, String department) async {
    try {
      // Fetch enrolled courses
      final enrolledQuery = await _firestore
          .collection('enrollments')
          .where('studentId', isEqualTo: userId)
          .get();

      final List<String> enrolledCourseIds = [];
      final List<Course> enrolledCourses = [];

      for (final enrollmentDoc in enrolledQuery.docs) {
        final courseId = enrollmentDoc['courseId'];
        if (courseId != null) {
          enrolledCourseIds.add(courseId);
          final courseDoc = await _firestore
              .collection('courses')
              .doc(courseId)
              .get();

          if (courseDoc.exists) {
            final courseData = courseDoc.data()!;
            enrolledCourses.add(
              Course(
                courseData['name'] ?? 'No Title',
                courseData['code'] ?? 'No Code',
                _getIconForCourse(courseData['code']),
                (enrollmentDoc['progress'] ?? 0).toInt(),
                _getColorForCourse(courseData['code']),
              ),
            );
          }
        }
      }

      // Build recommended courses query
      Query recommendedQuery = _firestore
          .collection('courses')
          .where('department', isEqualTo: department);

      if (enrolledCourseIds.isNotEmpty) {
        recommendedQuery = recommendedQuery.where(
          FieldPath.documentId,
          whereNotIn: enrolledCourseIds,
        );
      }

      final recommendedSnapshot = await recommendedQuery.limit(3).get();
      final recommendedCourses = recommendedSnapshot.docs.map((doc) {
        return Course(
          doc['name'] ?? 'No Title',
          doc['code'] ?? 'No Code',
          _getIconForCourse(doc['code']),
          0,
          _getColorForCourse(doc['code']),
        );
      }).toList();

      return {
        'enrolledCourses': enrolledCourses,
        'recommendedCourses': recommendedCourses,
      };
    } catch (e) {
      throw Exception('Error loading courses: ${e.toString()}');
    }
  }

  IconData _getIconForCourse(String? code) {
    if (code == null) return Icons.school;
    if (code.contains('CS101')) return Icons.code;
    if (code.contains('CS102')) return Icons.memory;
    if (code.contains('CS103')) return Icons.model_training;
    if (code.contains('CS104')) return Icons.web;
    return Icons.school;
  }

  Color _getColorForCourse(String? code) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[code?.hashCode ?? 0 % colors.length];
  }
}