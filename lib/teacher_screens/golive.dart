import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';

class GoLivePage extends StatefulWidget {
  final String courseId;

  const GoLivePage({Key? key, required this.courseId}) : super(key: key);

  @override
  State<GoLivePage> createState() => _GoLivePageState();
}

class _GoLivePageState extends State<GoLivePage> {
  String? courseName;
  String? teacherName;
  bool isLoading = false;
  bool isLive = false;

  @override
  void initState() {
    super.initState();
    _fetchCourseDetails();
  }

  Future<void> _fetchCourseDetails() async {
    try {
      final courseDoc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .get();

      if (courseDoc.exists) {
        setState(() {
          courseName = courseDoc.data()?['name'] ?? 'Unnamed Course';
        });

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final teacherDoc = await FirebaseFirestore.instance
              .collection('users_roles')
              .where('email', isEqualTo: user.email)
              .where('role', isEqualTo: 'teacher')
              .limit(1)
              .get();

          if (teacherDoc.docs.isNotEmpty) {
            setState(() {
              teacherName = teacherDoc.docs.first.data()['name'] ?? 'Teacher';
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching course details: $e');
    }
  }

  Future<bool> _requestPermissions() async {
    try {
      var cameraStatus = await Permission.camera.request();
      if (cameraStatus.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required for live streaming')),
        );
        return false;
      }

      var microphoneStatus = await Permission.microphone.request();
      if (microphoneStatus.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required for live streaming')),
        );
        return false;
      }

      return true;
    } catch (e) {
      debugPrint("Error requesting permissions: $e");
      return false;
    }
  }

  Future<void> _startLive() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      bool permissionsGranted = await _requestPermissions();
      if (!permissionsGranted) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // TODO: Implement your preferred video streaming solution here
      setState(() {
        isLive = true;
      });
    } catch (error) {
      debugPrint("Error starting live: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting live: $error')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _stopLive() async {
    try {
      // TODO: Implement stop functionality for your video streaming solution
      setState(() {
        isLive = false;
      });
      Navigator.pop(context);
    } catch (error) {
      debugPrint("Error stopping live: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error stopping live: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Class: ${courseName ?? 'Loading...'}'),
        centerTitle: true,
        actions: [
          if (isLive)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _stopLive,
            ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Start Live Class',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              if (isLive)
                const Text(
                  'Live streaming in progress...\nImplement your video solution here',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                )
              else
                SizedBox(
                  height: 64.0,
                  width: double.maxFinite,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _startLive,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            "Go Live",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}