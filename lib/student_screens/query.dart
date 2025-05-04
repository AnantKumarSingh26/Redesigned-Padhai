import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentQueryPage extends StatefulWidget {
  const StudentQueryPage({Key? key}) : super(key: key);

  @override
  State<StudentQueryPage> createState() => _StudentQueryPageState();
}

class _StudentQueryPageState extends State<StudentQueryPage> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _contactController = TextEditingController();
  String? _selectedTeacherId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchTeachers() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users_roles')
            .where('role', isEqualTo: 'teacher')
            .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? 'Unknown',
        'email': data['email'] ?? '',
      };
    }).toList();
  }

  Future<void> _submitQuery() async {
    if (!_formKey.currentState!.validate() || _selectedTeacherId == null)
      return;
    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;
    final studentEmail = user?.email ?? '';
    final studentId = user?.uid ?? '';
    try {
      await FirebaseFirestore.instance.collection('queries').add({
        'studentId': studentId,
        'studentEmail': studentEmail,
        'contact': _contactController.text.trim(),
        'message': _messageController.text.trim(),
        'teacherId': _selectedTeacherId,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Query sent successfully!')),
        );
        _formKey.currentState!.reset();
        _messageController.clear();
        _contactController.clear();
        setState(() => _selectedTeacherId = null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send query: $e')));
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3F2FD),
              Color.fromARGB(255, 241, 147, 84),
              Color.fromARGB(255, 70, 128, 255),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Ask a Query',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _messageController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Your Message',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.message),
                        ),
                        validator:
                            (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Please enter your message'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contactController,
                        decoration: const InputDecoration(
                          labelText: 'Your Contact Details',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        validator:
                            (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Please enter your contact details'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _fetchTeachers(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final teachers = snapshot.data!;
                          return DropdownButtonFormField<String>(
                            value: _selectedTeacherId,
                            decoration: const InputDecoration(
                              labelText: 'Select Teacher',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            items:
                                teachers.map((teacher) {
                                  return DropdownMenuItem<String>(
                                    value: teacher['id'],
                                    child: Text(teacher['name']),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedTeacherId = value;
                              });
                            },
                            validator:
                                (value) =>
                                    value == null
                                        ? 'Please select a teacher'
                                        : null,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitQuery,
                        icon: const Icon(Icons.send),
                        label:
                            _isSubmitting
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text('Send Query',style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
