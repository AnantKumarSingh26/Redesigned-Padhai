import 'package:flutter/material.dart';

class UploadFilesPage extends StatelessWidget {
  final String courseId;

  const UploadFilesPage({Key? key, required this.courseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Materials'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Upload materials for course ID: $courseId'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add file upload logic here
              },
              child: const Text('Upload File'),
            ),
          ],
        ),
      ),
    );
  }
}