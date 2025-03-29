import 'package:flutter/material.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Course> myCourses = [
      Course('Flutter Development', 'CS101', Icons.code, 85, Colors.blue),
      Course('Data Structures', 'CS102', Icons.memory, 72, Colors.green),
      Course('Machine Learning', 'CS103', Icons.model_training, 90, Colors.orange),
      Course('Web Development', 'CS104', Icons.web, 68, Colors.purple),
    ];

    final List<Course> recommendedCourses = [
      Course('AI Fundamentals', 'CS201', Icons.psychology, 0, Colors.red),
      Course('Cloud Computing', 'CS202', Icons.cloud, 0, Colors.teal),
      Course('Cyber Security', 'CS203', Icons.security, 0, Colors.indigo),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ExpandableStudentCard(),
              const SizedBox(height: 24),
              
              _buildSectionHeader('My Courses', 'View All'),
              const SizedBox(height: 12),
              HorizontalCoursesList(courses: myCourses, showProgress: true),
              const SizedBox(height: 24),
              
              _buildSectionHeader('Recommended For You', 'See More'),
              const SizedBox(height: 12),
              HorizontalCoursesList(courses: recommendedCourses, showProgress: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Text(
              action,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandableStudentCard extends StatefulWidget {
  const ExpandableStudentCard({super.key});

  @override
  State<ExpandableStudentCard> createState() => _ExpandableStudentCardState();
}

class _ExpandableStudentCardState extends State<ExpandableStudentCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: _isExpanded ? 200 : 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'STUDENT ID',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(Icons.school, color: Colors.white, size: 24),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'John Doe',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Computer Science',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 20),
              Divider(color: Colors.white.withOpacity(0.3)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCardDetail('ID', '2023001'),
                  _buildCardDetail('Batch', '2023-2027'),
                  _buildCardDetail('Semester', 'III'),
                ],
              ),
            ],
            const Spacer(),
            Text(
              'Tap to ${_isExpanded ? 'collapse' : 'expand'}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDetail(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class HorizontalCoursesList extends StatelessWidget {
  final List<Course> courses;
  final bool showProgress;

  const HorizontalCoursesList({
    super.key,
    required this.courses,
    required this.showProgress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: CourseCard(
                course: courses[index],
                showProgress: showProgress,
              ),
            ),
          );
        },
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Course course;
  final bool showProgress;

  const CourseCard({
    super.key,
    required this.course,
    required this.showProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: course.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(course.icon, color: course.color),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              course.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              course.code,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            if (showProgress) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: course.progress / 100,
                backgroundColor: Colors.grey[200],
                color: course.color,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${course.progress}% completed',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 10,
                      color: course.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class Course {
  final String title;
  final String code;
  final IconData icon;
  final int progress;
  final Color color;

  const Course(this.title, this.code, this.icon, this.progress, this.color);
}