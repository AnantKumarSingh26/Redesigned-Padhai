import 'package:flutter/material.dart';

class GoLivePage extends StatelessWidget {
  final String courseId;

  const GoLivePage({Key? key, required this.courseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Session'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Live session for course ID: $courseId',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}