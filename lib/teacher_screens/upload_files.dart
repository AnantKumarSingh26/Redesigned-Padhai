import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../services/supabase_storage_service.dart';

class UploadFilesPage extends StatelessWidget {
  final String courseId;

  const UploadFilesPage({Key? key, required this.courseId}) : super(key: key);

  Future<void> _pickAndUploadFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;

        final storageService = SupabaseStorageService();
        final url = await storageService.uploadMaterial(file, fileName);

        if (url != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File uploaded successfully: $url')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File upload failed.')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

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
              onPressed: () => _pickAndUploadFile(context),
              child: const Text('Upload File'),
            ),
          ],
        ),
      ),
    );
  }
}