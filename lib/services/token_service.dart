import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TokenService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Award tokens to a student
  Future<void> awardTokens(String userId, int amount) async {
    try {
      await _firestore.collection('users_roles').doc(userId).update({
        'tokens': FieldValue.increment(amount),
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error awarding tokens: $e');
      throw e;
    }
  }

  // Get student's token balance
  Future<int> getTokenBalance(String userId) async {
    try {
      final doc = await _firestore.collection('users_roles').doc(userId).get();
      return doc.data()?['tokens'] ?? 0;
    } catch (e) {
      print('Error getting token balance: $e');
      return 0;
    }
  }

  // Award tokens to all existing students
  Future<void> awardTokensToAllStudents() async {
    try {
      final students = await _firestore
          .collection('users_roles')
          .where('role', isEqualTo: 'student')
          .get();

      for (var doc in students.docs) {
        final userId = doc.id;
        await awardTokens(userId, 1000);
      }
    } catch (e) {
      print('Error awarding tokens to all students: $e');
      throw e;
    }
  }

  // Award tokens to new student on registration
  Future<void> awardTokensToNewStudent(String userId) async {
    try {
      await _firestore.collection('users_roles').doc(userId).set({
        'tokens': 1000,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error awarding tokens to new student: $e');
      throw e;
    }
  }
} 