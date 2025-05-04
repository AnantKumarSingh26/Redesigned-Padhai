import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherMockScreen extends StatefulWidget {
  const TeacherMockScreen({Key? key}) : super(key: key);

  @override
  State<TeacherMockScreen> createState() => _TeacherMockScreenState();
}

class _TeacherMockScreenState extends State<TeacherMockScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Center(child: Text('Not logged in'));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('My Mock Tests')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('mock')
            .where('teacherId', isEqualTo: user.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No mocks found. Tap + to add.'));
          }
          final mocks = snapshot.data!.docs;
          return ListView.builder(
            itemCount: mocks.length,
            itemBuilder: (context, index) {
              final mock = mocks[index];
              return ListTile(
                title: Text(mock['subject'] ?? 'No Subject'),
                subtitle: Text(
                  'Created: ' + (mock['createdAt']?.toDate().toString() ?? ''),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MockQuestionsScreen(
                      mockId: mock.id,
                      subject: mock['subject'] ?? '',
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMockDialog(context, user.email!),
        child: const Icon(Icons.add),
        tooltip: 'Add Mock',
      ),
    );
  }

  void _showAddMockDialog(BuildContext context, String teacherEmail) {
    final _subjectController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Mock'),
        content: TextField(
          controller: _subjectController,
          decoration: const InputDecoration(labelText: 'Subject'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final subject = _subjectController.text.trim();
              if (subject.isNotEmpty) {
                await _firestore.collection('mock').add({
                  'subject': subject,
                  'teacherId': teacherEmail, // Use teacher's email as teacherId
                  'createdAt': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
                setState(() {}); // Trigger UI refresh
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class MockQuestionsScreen extends StatelessWidget {
  final String mockId;
  final String subject;
  const MockQuestionsScreen({
    Key? key,
    required this.mockId,
    required this.subject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _firestore = FirebaseFirestore.instance;
    return Scaffold(
      appBar: AppBar(title: Text('Questions: $subject')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('mock')
            .doc(mockId)
            .collection('questions')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No questions yet.'));
          }
          final questions = snapshot.data!.docs;
          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final q = questions[index];
              return ListTile(
                title: Text(q['question'] ?? ''),
                subtitle: Text('Answer: ${q['rightOption'] ?? ''}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddQuestionDialog(context, mockId),
        child: const Icon(Icons.add),
        tooltip: 'Add Question',
      ),
    );
  }

  void _showAddQuestionDialog(BuildContext context, String mockId) {
    final _questionController = TextEditingController();
    final _optionAController = TextEditingController();
    final _optionBController = TextEditingController();
    final _optionCController = TextEditingController();
    final _optionDController = TextEditingController();
    final _rightOptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Question'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(labelText: 'Question'),
            ),
            TextField(
              controller: _optionAController,
              decoration: const InputDecoration(labelText: 'Option A'),
            ),
            TextField(
              controller: _optionBController,
              decoration: const InputDecoration(labelText: 'Option B'),
            ),
            TextField(
              controller: _optionCController,
              decoration: const InputDecoration(labelText: 'Option C'),
            ),
            TextField(
              controller: _optionDController,
              decoration: const InputDecoration(labelText: 'Option D'),
            ),
            TextField(
              controller: _rightOptionController,
              decoration: const InputDecoration(
                labelText: 'Right Option (A/B/C/D)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final question = _questionController.text.trim();
              final optionA = _optionAController.text.trim();
              final optionB = _optionBController.text.trim();
              final optionC = _optionCController.text.trim();
              final optionD = _optionDController.text.trim();
              final rightOption = _rightOptionController.text.trim();
              if (question.isNotEmpty &&
                  optionA.isNotEmpty &&
                  optionB.isNotEmpty &&
                  optionC.isNotEmpty &&
                  optionD.isNotEmpty &&
                  rightOption.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('mock')
                    .doc(mockId)
                    .collection('questions')
                    .add({
                  'question': question,
                  'optionA': optionA,
                  'optionB': optionB,
                  'optionC': optionC,
                  'optionD': optionD,
                  'rightOption': rightOption,
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
