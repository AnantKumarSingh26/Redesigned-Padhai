import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentMockListScreen extends StatelessWidget {
  const StudentMockListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 98, 151, 241),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Available Mock Tests',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(162, 45, 48, 53),
              Color.fromARGB(255, 96, 96, 100),
              Color.fromARGB(104, 248, 120, 0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('mock')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No mock tests available.'));
            }
            final mocks = snapshot.data!.docs;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mocks.length,
              itemBuilder: (context, index) {
                final mock = mocks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade300,
                          Colors.purple.shade300,
                          Colors.teal.shade200,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      title: Text(
                        mock['subject'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Created by: ${mock['teacherId'] ?? ''}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Start Test'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => StudentMockTestScreen(
                                    mockId: mock.id,
                                    subject: mock['subject'] ?? '',
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class StudentMockTestScreen extends StatefulWidget {
  final String mockId;
  final String subject;
  const StudentMockTestScreen({
    Key? key,
    required this.mockId,
    required this.subject,
  }) : super(key: key);

  @override
  State<StudentMockTestScreen> createState() => _StudentMockTestScreenState();
}

class _StudentMockTestScreenState extends State<StudentMockTestScreen> {
  int currentIndex = 0;
  List<DocumentSnapshot> questions = [];
  bool isLoading = true;
  String? selectedOption;
  String? feedback;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    final query =
        await FirebaseFirestore.instance
            .collection('mock')
            .doc(widget.mockId)
            .collection('questions')
            .get();
    setState(() {
      questions = query.docs;
      isLoading = false;
    });
  }

  void _checkAnswer() {
    if (questions.isEmpty) return;
    final rightOption =
        questions[currentIndex]['rightOption']?.toString().toUpperCase();
    if (selectedOption == null) {
      setState(() {
        feedback = 'Please select an option.';
      });
      return;
    }
    if (selectedOption == rightOption) {
      setState(() {
        feedback = 'Correct!';
      });
    } else {
      setState(() {
        feedback = 'Incorrect. Correct answer: $rightOption';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 98, 151, 241),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            widget.subject,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 22,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 133, 167, 231),
                Color.fromARGB(255, 236, 117, 167),
                Color.fromARGB(255, 214, 197, 100),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(child: Text('No questions in this test.')),
        ),
      );
    }
    final q = questions[currentIndex];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 98, 151, 241),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.subject,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 133, 167, 231),
              Color.fromARGB(255, 236, 117, 167),
              Color.fromARGB(255, 214, 197, 100),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question ${currentIndex + 1} of ${questions.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              Text(q['question'] ?? '', style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 24),
              ...['A', 'B', 'C', 'D'].map((opt) {
                final optionText = q['option$opt'] ?? '';
                return RadioListTile<String>(
                  value: opt,
                  groupValue: selectedOption,
                  onChanged: (val) {
                    setState(() {
                      selectedOption = val;
                      feedback = null;
                    });
                  },
                  title: Text('$opt. $optionText'),
                );
              }).toList(),
              if (feedback != null) ...[
                const SizedBox(height: 12),
                Text(
                  feedback!,
                  style: TextStyle(
                    color: feedback == 'Correct!' ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed:
                        currentIndex > 0
                            ? () {
                              setState(() {
                                currentIndex--;
                                selectedOption = null;
                                feedback = null;
                              });
                            }
                            : null,
                    child: const Text('Previous'),
                  ),
                  ElevatedButton(
                    onPressed: _checkAnswer,
                    child: const Text('Check'),
                  ),
                  ElevatedButton(
                    onPressed:
                        currentIndex < questions.length - 1
                            ? () {
                              setState(() {
                                currentIndex++;
                                selectedOption = null;
                                feedback = null;
                              });
                            }
                            : null,
                    child: const Text('Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
