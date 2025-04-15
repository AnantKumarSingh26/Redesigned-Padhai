import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecommendedCoursesPage extends StatelessWidget {
  const RecommendedCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended Courses'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent
        ,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No recommended courses available.'));
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
                child: ListTile(
                  title: Text(course['name'] ?? 'Unnamed Course'),
                  subtitle: Text(course['code'] ?? 'No Code'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}