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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const StudentProfileCard(),
              const SizedBox(height: 32),
              
              _buildSectionHeader('My Courses', 'View All', context),
              const SizedBox(height: 16),
              CourseHorizontalList(courses: myCourses, showProgress: true),
              const SizedBox(height: 32),
              
              _buildSectionHeader('Recommended Courses', 'See All', context),
              const SizedBox(height: 16),
              CourseHorizontalList(courses: recommendedCourses, showProgress: false),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              action,
              style: const TextStyle(
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

class StudentProfileCard extends StatelessWidget {
  const StudentProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.shade50,
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 30,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'John Doe',
                      style: Theme.of(context).textTheme.headline6?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Computer Science',
                      style: Theme.of(context).textTheme.subtitle2?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('ID', '2023001'),
              _buildInfoItem('Batch', '2023-2027'),
              _buildInfoItem('Semester', 'III'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class CourseHorizontalList extends StatelessWidget {
  final List<Course> courses;
  final bool showProgress;

  const CourseHorizontalList({
    super.key,
    required this.courses,
    required this.showProgress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index == courses.length - 1 ? 0 : 16,
            ),
            child: CourseCard(
              course: courses[index],
              showProgress: showProgress,
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
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16)),
            child: Container(
              height: 100,
              color: course.color.withOpacity(0.1),
              child: Center(
                child: Icon(
                  course.icon,
                  size: 40,
                  color: course.color,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  course.code,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                if (showProgress) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: course.progress / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: course.color,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${course.progress}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 12,
                          color: course.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
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