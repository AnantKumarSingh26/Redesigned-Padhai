import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TeacherAnnouncementScreen extends StatefulWidget {
  const TeacherAnnouncementScreen({Key? key}) : super(key: key);

  @override
  State<TeacherAnnouncementScreen> createState() =>
      _TeacherAnnouncementScreenState();
}

class _TeacherAnnouncementScreenState extends State<TeacherAnnouncementScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? teacherName;
  String? teacherEmail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeacherInfo();
  }

  Future<void> _fetchTeacherInfo() async {
    final user = _auth.currentUser;
    if (user == null) return;
    teacherEmail = user.email;
    final query =
        await _firestore
            .collection('users_roles')
            .where('email', isEqualTo: user.email)
            .where('role', isEqualTo: 'teacher')
            .limit(1)
            .get();
    if (query.docs.isNotEmpty) {
      setState(() {
        teacherName = query.docs.first['name'] ?? 'Teacher';
        isLoading = false;
      });
    } else {
      setState(() {
        teacherName = 'Teacher';
        isLoading = false;
      });
    }
  }

  void _showAnnouncementDialog({DocumentSnapshot? doc}) {
    final TextEditingController _messageController = TextEditingController(
      text: doc?['message'] ?? '',
    );
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(doc == null ? 'Add Announcement' : 'Edit Announcement'),
            content: TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final message = _messageController.text.trim();
                  if (message.isEmpty) return;
                  if (doc == null) {
                    // Add new
                    await _firestore.collection('announcement').add({
                      'teacherName': teacherName,
                      'teacherEmail': teacherEmail,
                      'message': message,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                  } else {
                    // Edit
                    await _firestore
                        .collection('announcement')
                        .doc(doc.id)
                        .update({'message': message});
                  }
                  Navigator.pop(context);
                },
                child: Text(doc == null ? 'Add' : 'Update'),
              ),
            ],
          ),
    );
  }

  void _deleteAnnouncement(String docId) async {
    await _firestore.collection('announcement').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Announcement',
            onPressed: isLoading ? null : () => _showAnnouncementDialog(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore
                .collection('announcement')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No announcements yet.'));
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final isMine = doc['teacherEmail'] == teacherEmail;
              final date = (doc['createdAt'] as Timestamp?)?.toDate();
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
                        Colors.purple.shade300,
                        Colors.blue.shade300,
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
                      doc['message'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          '- ${doc['teacherName'] ?? 'Teacher'}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                        if (date != null)
                          Text(
                            DateFormat('MMM d, yyyy • h:mm a').format(date),
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                    trailing:
                        isMine
                            ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                  onPressed:
                                      () => _showAnnouncementDialog(doc: doc),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => _deleteAnnouncement(doc.id),
                                  tooltip: 'Delete',
                                ),
                              ],
                            )
                            : null,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
