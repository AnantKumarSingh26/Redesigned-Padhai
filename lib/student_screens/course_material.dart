import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/pdf_viewer_service.dart';
import '../services/image_viewer_service.dart';
import '../services/video_player_service.dart';

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

  void _openMaterial(BuildContext context, String materialUrl) async {
    if (materialUrl.endsWith('.pdf')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerPage(pdfUrl: materialUrl),
        ),
      );
    } else if (materialUrl.endsWith('.jpg') ||
        materialUrl.endsWith('.jpeg') ||
        materialUrl.endsWith('.png')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewerPage(imageUrl: materialUrl),
        ),
      );
    } else if (materialUrl.endsWith('.mp4') ||
        materialUrl.endsWith('.mov') ||
        materialUrl.endsWith('.avi')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerPage(videoUrl: materialUrl),
        ),
      );
    } else {
      if (await canLaunch(materialUrl)) {
        await launch(materialUrl);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open URL.')));
      }
    }
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
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.video_library;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Course Materials',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 76, 44, 255),
              Color.fromARGB(255, 241, 84, 84),
              Color.fromARGB(255, 107, 255, 70),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<String>>(
            future: _fetchMaterials(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No materials available.',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                );
              } else {
                final materials = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  itemCount: materials.length,
                  itemBuilder: (context, index) {
                    final materialUrl = materials[index];
                    final fileName = materialUrl.split('/').last;
                    return Card(
                      elevation: 6,
                      margin: const EdgeInsets.only(bottom: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => _openMaterial(context, materialUrl),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 18,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF1565C0,
                                  ).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getFileIcon(fileName),
                                  color: const Color(0xFF1565C0),
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fileName,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1565C0),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      materialUrl,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.open_in_new,
                                  color: Color(0xFF1565C0),
                                ),
                                onPressed:
                                    () => _openMaterial(context, materialUrl),
                                tooltip: 'Open',
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
