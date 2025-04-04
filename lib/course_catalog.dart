import 'package:flutter/material.dart';

class CourseManagementScreen extends StatelessWidget {
  const CourseManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Catalog'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateCourseDialog(context),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'All Courses'),
                Tab(text: 'Course Modules'),
                Tab(text: 'Instructors'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCoursesList(),
                  _buildModulesList(),
                  _buildInstructorsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesList() {
    final courses = [
      Course(
        id: 'C101',
        title: 'Flutter Development',
        description: 'Complete guide to Flutter app development',
        instructor: 'Dr. Smith',
        status: CourseStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Course(
        id: 'C102',
        title: 'Advanced Dart',
        description: 'Master Dart programming language',
        instructor: 'Prof. Johnson',
        status: CourseStatus.draft,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];

    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: const Icon(Icons.library_books, size: 36),
            title: Text(course.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.description),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Chip(
                      label: Text(course.status.toString().split('.').last),
                      backgroundColor: _getStatusColor(course.status),
                    ),
                    const Spacer(),
                    Text('Instructor: ${course.instructor}'),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit Course'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Course'),
                    ),
                    const PopupMenuItem(
                      value: 'modules',
                      child: Text('Manage Modules'),
                    ),
                  ],
              onSelected:
                  (value) => _handleCourseAction(context, value, course),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModulesList() {
    final modules = [
      CourseModule(
        id: 'M101',
        courseId: 'C101',
        title: 'Flutter Basics',
        lessons: [
          Lesson(id: 'L101', title: 'Widgets Introduction', duration: '30 min'),
          Lesson(id: 'L102', title: 'State Management', duration: '45 min'),
        ],
      ),
      CourseModule(
        id: 'M102',
        courseId: 'C101',
        title: 'Advanced Flutter',
        lessons: [Lesson(id: 'L201', title: 'Animations', duration: '40 min')],
      ),
    ];

    return ListView.builder(
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return ExpansionTile(
          title: Text(module.title),
          subtitle: Text('${module.lessons.length} lessons'),
          leading: const Icon(Icons.collections_bookmark),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditModuleDialog(context, module),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteModuleDialog(context, module),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                children: [
                  ...module.lessons.map(
                    (lesson) => ListTile(
                      leading: const Icon(Icons.play_lesson),
                      title: Text(lesson.title),
                      subtitle: Text(lesson.duration),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed:
                                () => _showEditLessonDialog(context, lesson),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed:
                                () => _showDeleteLessonDialog(context, lesson),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Add New Lesson'),
                    onTap: () => _showCreateLessonDialog(context, module.id),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInstructorsList() {
    final instructors = [
      Instructor(
        id: 'I101',
        name: 'Dr. Smith',
        email: 'smith@university.edu',
        assignedCourses: ['Flutter Development', 'Dart Fundamentals'],
      ),
      Instructor(
        id: 'I102',
        name: 'Prof. Johnson',
        email: 'johnson@university.edu',
        assignedCourses: ['Advanced Dart'],
      ),
    ];

    return ListView.builder(
      itemCount: instructors.length,
      itemBuilder: (context, index) {
        final instructor = instructors[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(instructor.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(instructor.email),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children:
                      instructor.assignedCourses
                          .map(
                            (course) => Chip(
                              label: Text(course),
                              backgroundColor: Colors.blue[50],
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'assign',
                      child: Text('Assign Course'),
                    ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Text('Remove Assignment'),
                    ),
                  ],
              onSelected:
                  (value) =>
                      _handleInstructorAction(context, value, instructor),
            ),
          ),
        );
      },
    );
  }

  // Helper Methods
  Color _getStatusColor(CourseStatus status) {
    switch (status) {
      case CourseStatus.active:
        return Colors.green[100]!;
      case CourseStatus.draft:
        return Colors.orange[100]!;
      case CourseStatus.archived:
        return Colors.grey[300]!;
    }
  }

  // Dialog Methods
  Future<void> _showCreateCourseDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String description = '';

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create New Course'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Course Title',
                    ),
                    validator:
                        (value) =>
                            value?.isEmpty ?? true ? 'Required field' : null,
                    onSaved: (value) => title = value ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator:
                        (value) =>
                            value?.isEmpty ?? true ? 'Required field' : null,
                    onSaved: (value) => description = value ?? '',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    formKey.currentState?.save();
                    // Save course logic
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Course "$title" created')),
                    );
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  Future<void> _showEditModuleDialog(
    BuildContext context,
    CourseModule module,
  ) async {
    // Similar to create course dialog but with existing data
  }

  Future<void> _showEditLessonDialog(
    BuildContext context,
    Lesson lesson,
  ) async {
    final formKey = GlobalKey<FormState>();
    String title = lesson.title;
    String duration = lesson.duration;

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Lesson'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: title,
                    decoration: const InputDecoration(
                      labelText: 'Lesson Title',
                    ),
                    validator:
                        (value) =>
                            value?.isEmpty ?? true ? 'Required field' : null,
                    onSaved: (value) => title = value ?? '',
                  ),
                  TextFormField(
                    initialValue: duration,
                    decoration: const InputDecoration(labelText: 'Duration'),
                    validator:
                        (value) =>
                            value?.isEmpty ?? true ? 'Required field' : null,
                    onSaved: (value) => duration = value ?? '',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    formKey.currentState?.save();
                    // Save lesson logic
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lesson "$title" updated')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<void> _showDeleteModuleDialog(
    BuildContext context,
    CourseModule module,
  ) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Module'),
            content: Text('Delete "${module.title}" and all its lessons?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Delete logic
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Module "${module.title}" deleted')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Future<void> _showDeleteCourseDialog(
    BuildContext context,
    Course course,
  ) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Course'),
            content: Text('Are you sure you want to delete "${course.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Delete course logic
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Course "${course.title}" deleted')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Future<void> _showAssignCourseDialog(
    BuildContext context,
    Instructor instructor,
  ) async {
    // Logic to assign a course to the instructor
  }

  Future<void> _showRemoveAssignmentDialog(
    BuildContext context,
    Instructor instructor,
  ) async {
    // Logic to remove a course assignment from the instructor
  }

  Future<void> _showCreateLessonDialog(
    BuildContext context,
    String moduleId,
  ) async {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String duration = '';

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add new Lesson'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Lesson Title',
                    ),
                    validator:
                        (value) =>
                            value?.isEmpty ?? true ? 'Required field' : null,
                    onSaved: (value) => title = value ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Duration'),
                    validator:
                        (value) =>
                            value?.isEmpty ?? true ? 'Required field' : null,
                    onSaved: (value) => duration = value ?? '',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    formKey.currentState?.save();
                    // Save lesson logic
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lesson "$title" created')),
                    );
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  Future<void> _showDeleteLessonDialog(
    BuildContext context,
    Lesson lesson,
  ) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Lesson'),
            content: Text('Are you sure you want to delete "${lesson.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Delete lesson logic
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lesson "${lesson.title}" deleted')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _handleCourseAction(BuildContext context, String action, Course course) {
    switch (action) {
      case 'edit':
        // Implement edit
        break;
      case 'delete':
        _showDeleteCourseDialog(context, course);
        break;
      case 'modules':
        // Navigate to modules
        break;
    }
  }

  void _handleInstructorAction(
    BuildContext context,
    String action,
    Instructor instructor,
  ) {
    switch (action) {
      case 'assign':
        _showAssignCourseDialog(context, instructor);
        break;
      case 'remove':
        _showRemoveAssignmentDialog(context, instructor);
        break;
    }
  }
}

// Data Models
enum CourseStatus { draft, active, archived }

class Course {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final CourseStatus status;
  final DateTime createdAt;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.status,
    required this.createdAt,
  });
}

class CourseModule {
  final String id;
  final String courseId;
  final String title;
  final List<Lesson> lessons;

  CourseModule({
    required this.id,
    required this.courseId,
    required this.title,
    required this.lessons,
  });
}

class Lesson {
  final String id;
  final String title;
  final String duration;

  Lesson({required this.id, required this.title, required this.duration});
}

class Instructor {
  final String id;
  final String name;
  final String email;
  final List<String> assignedCourses;

  Instructor({
    required this.id,
    required this.name,
    required this.email,
    required this.assignedCourses,
  });
}
