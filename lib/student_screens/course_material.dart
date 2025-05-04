import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseMaterialPage extends StatelessWidget {
  final String courseId;

  const CourseMaterialPage({Key? key, required this.courseId})
    : super(key: key);

  Future<List<String>> _fetchMaterials() async {
    try {
      final courseDoc =
          await FirebaseFirestore.instance
              .collection('courses')
              .doc(courseId)
              .get();

      if (courseDoc.exists) {
        final materials = List<String>.from(
          courseDoc.data()?['materials'] ?? [],
        );
        return materials;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching materials: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Materials')),
      body: FutureBuilder<List<String>>(
        future: _fetchMaterials(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No materials available.'));
          } else {
            final materials = snapshot.data!;
            return ListView.builder(
              itemCount: materials.length,
              itemBuilder: (context, index) {
                final materialUrl = materials[index];
                return ListTile(
                  title: Text('Material ${index + 1}'),
                  subtitle: Text(materialUrl),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () async {
                      if (await canLaunch(materialUrl)) {
                        await launch(materialUrl);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open URL.')),
                        );
                      }
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
