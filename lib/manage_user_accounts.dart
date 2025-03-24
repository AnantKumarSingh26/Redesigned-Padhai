import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management'), centerTitle: true),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Pending Verification'),
                Tab(text: 'Approval Requests'),
                Tab(text: 'Account Deletion'),
                Tab(text: 'Activity Logs'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPendingVerification(),
                  _buildApprovalRequests(),
                  _buildAccountDeletion(),
                  _buildActivityLogs(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingVerification() {
    final pendingUsers = [
      User(
        id: '001',
        name: 'John Doe',
        email: 'john@example.com',
        status: UserStatus.pendingVerification,
        registrationDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      User(
        id: '002',
        name: 'Jane Smith',
        email: 'jane@example.com',
        status: UserStatus.pendingVerification,
        registrationDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    return ListView.builder(
      itemCount: pendingUsers.length,
      itemBuilder: (context, index) {
        final user = pendingUsers[index];
        return _UserCard(
          user: user,
          actions: [
            _buildActionButton(
              'Verify',
              Colors.green,
              () => _showVerificationDialog(context, user),
            ),
            _buildActionButton(
              'Reject',
              Colors.red,
              () => _showRejectionDialog(context, user),
            ),
          ],
        );
      },
    );
  }

  Widget _buildApprovalRequests() {
    final approvalRequests = [
      User(
        id: '003',
        name: 'Alice Johnson',
        email: 'alice@example.com',
        status: UserStatus.pendingApproval,
        registrationDate: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    return ListView.builder(
      itemCount: approvalRequests.length,
      itemBuilder: (context, index) {
        final user = approvalRequests[index];
        return _UserCard(
          user: user,
          actions: [
            _buildActionButton(
              'Approve',
              Colors.blue,
              () => _approveUser(context, user),
            ),
            _buildActionButton(
              'Deny',
              Colors.orange,
              () => _denyApproval(context, user),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccountDeletion() {
    final deletionRequests = [
      User(
        id: '004',
        name: 'Bob Brown',
        email: 'bob@example.com',
        status: UserStatus.deletionRequested,
        registrationDate: DateTime.now().subtract(const Duration(days: 30)),
        lastActivity: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    return ListView.builder(
      itemCount: deletionRequests.length,
      itemBuilder: (context, index) {
        final user = deletionRequests[index];
        return _UserCard(
          user: user,
          actions: [
            _buildActionButton(
              'Delete',
              Colors.red,
              () => _confirmDeletion(context, user),
            ),
            _buildActionButton(
              'Keep',
              Colors.green,
              () => _keepAccount(context, user),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActivityLogs() {
    final activityLogs = [
      ActivityLog(
        userId: '001',
        userName: 'John Doe',
        action: 'Logged in',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      ActivityLog(
        userId: '002',
        userName: 'Jane Smith',
        action: 'Updated profile',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ActivityLog(
        userId: '003',
        userName: 'Alice Johnson',
        action: 'Completed course',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    return ListView.builder(
      itemCount: activityLogs.length,
      itemBuilder: (context, index) {
        final log = activityLogs[index];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(log.action),
          subtitle: Text('${log.userName} • ${_formatDate(log.timestamp)}'),
          trailing: Text(_formatTime(log.timestamp)),
        );
      },
    );
  }

  Widget _UserCard({required User user, required List<Widget> actions}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(user.name.substring(0, 1))),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(user.email),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    user.status.toString().split('.').last,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(user.status),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Registered: ${_formatDate(user.registrationDate)}'),
                Text('Last active: ${_formatDate(user.lastActivity)}'),
              ],
            ),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: actions),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.pendingVerification:
        return Colors.orange;
      case UserStatus.pendingApproval:
        return Colors.blue;
      case UserStatus.active:
        return Colors.green;
      case UserStatus.deletionRequested:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatTime(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('hh:mm a').format(date);
  }

  Future<void> _showVerificationDialog(BuildContext context, User user) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Verify Account'),
            content: Text('Verify ${user.name}\'s account?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement verification logic
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${user.name} verified successfully'),
                    ),
                  );
                },
                child: const Text('Verify'),
              ),
            ],
          ),
    );
  }

  Future<void> _showRejectionDialog(BuildContext context, User user) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reject Account'),
            content: Text('Reject ${user.name}\'s account?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement rejection logic
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${user.name} rejected successfully'),
                    ),
                  );
                },
                child: const Text('Reject'),
              ),
            ],
          ),
    );
  }

  Future<void> _approveUser(BuildContext context, User user) async {
    // Implement approval logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${user.name} approved successfully')),
    );
  }

  Future<void> _denyApproval(BuildContext context, User user) async {
    // Implement denial logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${user.name} approval denied')));
  }

  Future<void> _confirmDeletion(BuildContext context, User user) async {
    // Implement deletion logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${user.name} account deleted')));
  }

  Future<void> _keepAccount(BuildContext context, User user) async {
    // Implement keep account logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${user.name} account retained')));
  }
}

enum UserStatus {
  pendingVerification,
  pendingApproval,
  active,
  suspended,
  deletionRequested,
}

class User {
  final String id;
  final String name;
  final String email;
  final UserStatus status;
  final DateTime registrationDate;
  final DateTime? lastActivity;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.registrationDate,
    this.lastActivity,
  });
}

class ActivityLog {
  final String userId;
  final String userName;
  final String action;
  final DateTime timestamp;

  ActivityLog({
    required this.userId,
    required this.userName,
    required this.action,
    required this.timestamp,
  });
}
