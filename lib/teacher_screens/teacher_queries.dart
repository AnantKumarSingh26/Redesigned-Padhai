import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TeacherQueriesPage extends StatelessWidget {
  const TeacherQueriesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Not logged in'));
    }
    final teacherId = user.uid;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Student Queries',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(200, 3, 41, 255),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
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
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('queries')
                  .where('teacherId', isEqualTo: teacherId)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No queries yet.', style: TextStyle(fontSize: 18)),
              );
            }
            final queries = snapshot.data!.docs;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: queries.length,
              itemBuilder: (context, index) {
                final query = queries[index];
                final data = query.data() as Map<String, dynamic>;
                final message = data['message'] ?? '';
                final contact = data['contact'] ?? '';
                final studentEmail = data['studentEmail'] ?? '';
                final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
                final status = data['status'] ?? 'pending';
                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(20),
                    leading: CircleAvatar(
                      backgroundColor:
                          status == 'pending'
                              ? Colors.orange[200]
                              : Colors.green[200],
                      child: Icon(
                        status == 'pending'
                            ? Icons.mark_email_unread
                            : Icons.mark_email_read,
                        color:
                            status == 'pending'
                                ? Colors.orange[800]
                                : Colors.green[800],
                      ),
                    ),
                    title: Text(
                      message,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.email,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                studentEmail,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                contact,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (createdAt != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat(
                                  'MMM d, yyyy h:mm a',
                                ).format(createdAt),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    trailing:
                        status == 'pending'
                            ? IconButton(
                              icon: const Icon(
                                Icons.mark_email_read,
                                color: Color(0xFF1565C0),
                              ),
                              tooltip: 'Mark as read',
                              onPressed: () async {
                                await query.reference.update({
                                  'status': 'read',
                                });
                              },
                            )
                            : const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 28,
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
