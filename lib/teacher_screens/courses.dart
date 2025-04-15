import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
                        child: ListTile(
                          title: Text(
                            course['name'] ?? 'Unnamed Course',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            course['code'] ?? 'No Code',
                            style: const TextStyle(color: Colors.white70),
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