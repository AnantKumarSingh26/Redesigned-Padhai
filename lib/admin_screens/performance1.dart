import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  // Simulated performance metrics
  late Map<String, double> _metrics;
  late Timer _timer;
  final Random _random = Random();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _totalUsers = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserCount();
    _initializeMetrics();
    // Update metrics every 5 minutes
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _updateMetrics();
      _fetchUserCount();
    });
  }

  Future<void> _fetchUserCount() async {
    try {
      final usersSnapshot = await _firestore.collection('users_roles').get();
      setState(() {
        _totalUsers = usersSnapshot.docs.length;
        _metrics['active_users'] = _totalUsers.toDouble();
      });
    } catch (e) {
      print('Error fetching user count: $e');
    }
  }

  void _initializeMetrics() {
    _metrics = {
      'database_latency': _random.nextDouble() * 100,
      'auth_success_rate': 80 + _random.nextDouble() * 10, // Between 80-90%
      'storage_usage': 13 + _random.nextDouble() * 2, // Between 13-15%
      'api_response_time': _random.nextDouble() * 100,
      'active_users': _totalUsers.toDouble(),
      'error_rate': _random.nextDouble() * 5,
    };
  }

  void _updateMetrics() {
    setState(() {
      _metrics = {
        'database_latency': _random.nextDouble() * 100,
        'auth_success_rate': 80 + _random.nextDouble() * 10, // Between 80-90%
        'storage_usage': 13 + _random.nextDouble() * 2, // Between 13-15%
        'api_response_time': _random.nextDouble() * 100,
        'active_users': _totalUsers.toDouble(), // Use the real user count
        'error_rate': _random.nextDouble() * 5,
      };
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Metrics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Ensure back navigation
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildPerformanceOverview(),
                const SizedBox(height: 24),
                _buildDetailedMetrics(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Performance',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Last updated: ${DateTime.now().toString().substring(0, 16)}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _updateMetrics,
          tooltip: 'Refresh metrics',
        ),
      ],
    );
  }

  Widget _buildPerformanceOverview() {
    return Container(
      height: 200, // Fixed height for the container
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildMetricCard(
              'Database Performance',
              _metrics['database_latency']!,
              Icons.storage,
              'ms',
              Colors.blue,
            ),
            const SizedBox(width: 16),
            _buildMetricCard(
              'Authentication',
              _metrics['auth_success_rate']!,
              Icons.security,
              '%',
              Colors.green,
            ),
            const SizedBox(width: 16),
            _buildMetricCard(
              'Storage Usage',
              _metrics['storage_usage']!,
              Icons.cloud,
              '%',
              Colors.orange,
            ),
            const SizedBox(width: 16),
            _buildMetricCard(
              'API Response',
              _metrics['api_response_time']!,
              Icons.speed,
              'ms',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detailed Metrics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildMetricRow(
                  'Active Users',
                  _metrics['active_users']!.toStringAsFixed(0),
                  Icons.people,
                  Colors.blue,
                ),
                const Divider(),
                _buildMetricRow(
                  'Error Rate',
                  '${_metrics['error_rate']!.toStringAsFixed(2)}%',
                  Icons.error_outline,
                  Colors.red,
                ),
                const Divider(),
                _buildMetricRow(
                  'Database Latency',
                  '${_metrics['database_latency']!.toStringAsFixed(2)}ms',
                  Icons.timer,
                  Colors.orange,
                ),
                const Divider(),
                _buildMetricRow(
                  'Storage Usage',
                  '${_metrics['storage_usage']!.toStringAsFixed(2)}%',
                  Icons.cloud_done,
                  Colors.green,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    double value,
    IconData icon,
    String unit,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 200, // Fixed width for cards
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              '${value.toStringAsFixed(2)}$unit',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
