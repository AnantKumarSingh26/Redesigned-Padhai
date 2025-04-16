import 'package:flutter/material.dart';

class GoLivePage extends StatefulWidget {
  final String courseId;

  const GoLivePage({Key? key, required this.courseId}) : super(key: key);

  @override
  State<GoLivePage> createState() => _GoLivePageState();
}

class _GoLivePageState extends State<GoLivePage> {
  @override
  void initState() {
    super.initState();
    // Removed JitsiMeet listeners
  }

  @override
  void dispose() {
    // Removed JitsiMeet cleanup
    super.dispose();
  }

  Future<void> _joinMeeting() async {
    // Placeholder for removed JitsiMeet functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Live session functionality is unavailable.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Session'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _joinMeeting,
          child: const Text('Start Live Session'),
        ),
      ),
    );
  }
}