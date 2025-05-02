import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'course.dart';

class DashboardController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add stream for real-time token updates
  Stream<int> get tokenStream {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    return _firestore
        .collection('users_roles')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.data()?['tokens'] ?? 0);
  }

  // Method to update tokens after course enrollment
  Future<void> updateTokensAfterEnrollment(int courseFee) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final userDoc = _firestore.collection('users_roles').doc(user.uid);
      
      // Get current tokens
      final userData = await userDoc.get();
      final currentTokens = userData.data()?['tokens'] ?? 0;
      
      // Update tokens
      await userDoc.update({
        'tokens': currentTokens - courseFee,
      });
    } catch (e) {
      throw Exception('Error updating tokens: ${e.toString()}');
    }
  }

  // Method to check if user has enough tokens
  Future<bool> hasEnoughTokens(int requiredTokens) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore
          .collection('users_roles')
          .doc(user.uid)
          .get();

      final currentTokens = userDoc.data()?['tokens'] ?? 0;
      return currentTokens >= requiredTokens;
    } catch (e) {
      return false;
    }
  }

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
                courseDoc.id, // Assign the course ID
                courseData['name'] ?? 'No Name',
                courseData['name'] ?? 'No Title', // Corrected parameter
                courseData['code'] ?? 'No Code',
                _getIconForCourse(courseData['code']),
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
          doc.id, // Assign the course ID
          doc['name'] ?? 'No Name',
          doc['name'] ?? 'No Title', // Corrected parameter
          doc['code'] ?? 'No Code',
          _getIconForCourse(doc['code']),
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

  Future<List<Course>> fetchEnrolledCourses(String userId) async {
    try {
      // Get all enrollments for the student
      final enrolledQuery = await _firestore
          .collection('enrollments')
          .where('studentId', isEqualTo: userId)
          .get();

      final List<Course> enrolledCourses = [];
      final List<Future<void>> courseFetches = [];

      // Create a list of futures for parallel processing
      for (final enrollmentDoc in enrolledQuery.docs) {
        final courseId = enrollmentDoc.data()['courseId'];
        if (courseId != null) {
          courseFetches.add(
            _firestore
                .collection('courses')
                .doc(courseId)
                .get()
                .then((courseDoc) {
              if (courseDoc.exists) {
                final courseData = courseDoc.data()!;
                enrolledCourses.add(
                  Course(
                    courseDoc.id,
                    courseData['name'] ?? 'No Name',
                    courseData['name'] ?? 'No Title',
                    courseData['code'] ?? 'No Code',
                    _getIconForCourse(courseData['code']),
                    _getColorForCourse(courseData['code']),
                  ),
                );
              }
            }),
          );
        }
      }

      // Wait for all course fetches to complete
      await Future.wait(courseFetches);

      // Sort courses by name for consistent display
      enrolledCourses.sort((a, b) => a.name.compareTo(b.name));

      return enrolledCourses;
    } catch (e) {
      throw Exception('Error fetching enrolled courses: ${e.toString()}');
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
    // Ensure the index is within bounds
    final index = (code?.hashCode ?? 0) % colors.length;
    return colors[index.abs()];
  }
}