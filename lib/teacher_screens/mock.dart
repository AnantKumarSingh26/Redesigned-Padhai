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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE3F2FD), // Light blue
              Color.fromARGB(255, 241, 147, 84), // Lighter blue
              Color.fromARGB(255, 70, 128, 255), // Medium blue
            ],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: const Text(
                'My Mock Tests',
                style: TextStyle(
                  color: Color(0xFF1565C0),
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('mock')
                        .where('teacherId', isEqualTo: user.email)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No mocks found. Tap + to add.',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final mocks = snapshot.data!.docs;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: mocks.length,
                    itemBuilder: (context, index) {
                      final mock = mocks[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => MockQuestionsScreen(
                                        mockId: mock.id,
                                        subject: mock['subject'] ?? '',
                                      ),
                                ),
                              ),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF1565C0,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.assignment,
                                        color: Color(0xFF1565C0),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            mock['subject'] ?? 'No Subject',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1565C0),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Created: ${mock['createdAt']?.toDate().toString().split('.')[0] ?? ''}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Color(0xFF1565C0),
                                      size: 16,
                                    ),
                                  ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMockDialog(context, user.email!),
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.add),
        tooltip: 'Add Mock',
      ),
    );
  }

  void _showAddMockDialog(BuildContext context, String teacherEmail) {
    final _subjectController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                      'teacherId':
                          teacherEmail, // Use teacher's email as teacherId
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
        stream:
            _firestore
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
      builder:
          (context) => AlertDialog(
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
