import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/token_service.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final TokenService _tokenService = TokenService();
  int _tokenBalance = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTokenBalance();
  }

  Future<void> _loadTokenBalance() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('Loading token balance for user: ${user.uid}');
        
        // First check if the document exists
        final doc = await FirebaseFirestore.instance
            .collection('students')
            .doc(user.uid)
            .get();
            
        print('Document exists: ${doc.exists}');
        print('Document data: ${doc.data()}');
        
        final balance = await _tokenService.getTokenBalance(user.uid);
        print('Retrieved token balance: $balance');
        
        if (mounted) {
          setState(() {
            _tokenBalance = balance;
            _isLoading = false;
          });
        }
      } else {
        print('No user logged in');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading token balance: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber),
                const SizedBox(width: 4),
                if (_isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    '$_tokenBalance',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Student Dashboard'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadTokenBalance,
              child: const Text('Refresh Token Balance'),
            ),
          ],
        ),
      ),
    );
  }
} 