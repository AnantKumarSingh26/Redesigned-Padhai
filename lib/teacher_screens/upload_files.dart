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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE3F2FD), // Light blue
              Color.fromARGB(255, 241, 147, 84), // Orange
              Color.fromARGB(255, 70, 128, 255), // Blue
            ],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: const Text(
                'Course Materials',
                style: TextStyle(
                  color: Color(0xFF1565C0),
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF1565C0)),
                  onPressed: _isUploading ? null : _pickAndUploadFile,
                  tooltip: 'Upload Material',
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
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
                          Icon(
                            Icons.folder_open,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No materials uploaded yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _isUploading ? null : _pickAndUploadFile,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload Material'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1565C0),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
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
                      final fileName = materialUrl.split('/').last;
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () async {
                            if (materialUrl.endsWith('.pdf')) {
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ImageViewerPage(
                                        imageUrl: materialUrl,
                                      ),
                                ),
                              );
                            } else if (materialUrl.endsWith('.mp4') ||
                                materialUrl.endsWith('.mov') ||
                                materialUrl.endsWith('.avi')) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => VideoPlayerPage(
                                        videoUrl: materialUrl,
                                      ),
                                ),
                              );
                            } else {
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
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF1565C0,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getFileIcon(fileName),
                                    color: const Color(0xFF1565C0),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fileName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1565C0),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Material ${index + 1}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteFile(materialUrl),
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          _isUploading
              ? const CircularProgressIndicator()
              : FloatingActionButton(
                onPressed: _pickAndUploadFile,
                backgroundColor: const Color(0xFF1565C0),
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
