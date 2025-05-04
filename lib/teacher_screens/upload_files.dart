import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../services/supabase_storage_service.dart';
import '../services/pdf_viewer_service.dart';
import '../services/image_viewer_service.dart';
import '../services/video_player_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class UploadFilesPage extends StatefulWidget {
  final String courseId;

  const UploadFilesPage({Key? key, required this.courseId}) : super(key: key);

  @override
  State<UploadFilesPage> createState() => _UploadFilesPageState();
}

class _UploadFilesPageState extends State<UploadFilesPage> {
  final storageService = SupabaseStorageService();
  bool _isUploading = false;

  Future<void> _pickAndUploadFile() async {
    try {
      setState(() => _isUploading = true);
      final result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;

        // Upload file to Supabase
        final publicUrl = await storageService.uploadFile(
          file,
          'materials', // Supabase bucket name
          fileName,
        );

        if (publicUrl != null) {
          // Add the public URL to the 'materials' array in Firestore
          await FirebaseFirestore.instance
              .collection('courses')
              .doc(widget.courseId)
              .update({
                'materials': FieldValue.arrayUnion([publicUrl]),
              });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File uploaded successfully: $publicUrl')),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('File upload failed.')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteFile(String materialUrl) async {
    try {
      final success = await storageService.deleteFile('materials', materialUrl);

      if (success) {
        await FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .update({
              'materials': FieldValue.arrayRemove([materialUrl]),
            });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File deleted successfully.')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File deletion failed.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Materials'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _isUploading ? null : _pickAndUploadFile,
            tooltip: 'Upload Material',
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('courses')
                .doc(widget.courseId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final materials = List<String>.from(
            snapshot.data?['materials'] ?? [],
          );

          if (materials.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No materials uploaded yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _isUploading ? null : _pickAndUploadFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Material'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: materials.length,
            itemBuilder: (context, index) {
              final materialUrl = materials[index];
              return ListTile(
                title: Text('Material ${index + 1}'),
                subtitle: Text(materialUrl),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () async {
                        if (materialUrl.endsWith('.pdf')) {
                          // Open PDF in the app
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      PDFViewerPage(pdfUrl: materialUrl),
                            ),
                          );
                        } else if (materialUrl.endsWith('.jpg') ||
                            materialUrl.endsWith('.jpeg') ||
                            materialUrl.endsWith('.png')) {
                          // Open image in the app
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      ImageViewerPage(imageUrl: materialUrl),
                            ),
                          );
                        } else if (materialUrl.endsWith('.mp4') ||
                            materialUrl.endsWith('.mov') ||
                            materialUrl.endsWith('.avi')) {
                          // Open video in the app
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      VideoPlayerPage(videoUrl: materialUrl),
                            ),
                          );
                        } else {
                          // Open other links in the browser
                          if (await canLaunch(materialUrl)) {
                            await launch(materialUrl);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not open URL.'),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteFile(materialUrl),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton:
          _isUploading
              ? const CircularProgressIndicator()
              : FloatingActionButton(
                onPressed: _pickAndUploadFile,
                child: const Icon(Icons.add),
              ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }
}
