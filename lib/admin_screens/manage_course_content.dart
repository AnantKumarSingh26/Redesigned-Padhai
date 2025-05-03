import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Define a common gradient color variable
const List<Color> gradientColors = [
  Color.fromARGB(255, 243, 46, 24),
  Color.fromARGB(172, 17, 0, 255),
  Color.fromARGB(255, 0, 135, 245),
  Color.fromARGB(255, 253, 106, 228),
];

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  final CollectionReference _coursesCollection = 
      FirebaseFirestore.instance.collection('courses');
  final CollectionReference _usersCollection = 
      FirebaseFirestore.instance.collection('users_roles');

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Course Management'),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'All Courses'),
              Tab(text: 'Add New Course'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCoursesList(isTablet),
            _buildAddCourseForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesList(bool isTablet) {
    return StreamBuilder<QuerySnapshot>(
      stream: _coursesCollection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final courses = snapshot.data!.docs;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 2 : 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isTablet ? 1.5 : 1.8,
          ),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            final data = course.data() as Map<String, dynamic>;

            // Handle instructorId type
            final instructorId = data['instructorId'] is DocumentReference
                ? (data['instructorId'] as DocumentReference).id
                : data['instructorId'] as String?;

            // Fix type casting for startTime and endTime
            final startTime = data['startTime'] is Timestamp
                ? (data['startTime'] as Timestamp).toDate()
                : null;
            final endTime = data['endTime'] is Timestamp
                ? (data['endTime'] as Timestamp).toDate()
                : null;

            return _CourseCard(
              courseId: course.id,
              name: data['name'] ?? 'No Name',
              courseCode: data['code'] ?? 'N/A',
              category: data['category'] ?? 'General',
              instructorId: instructorId,
              startTime: startTime,
              endTime: endTime,
              onEdit: () => _showEditCourseDialog(context, course.id, data),
              onDelete: () => _deleteCourse(course.id),
              onViewMaterials: () => _viewCourseMaterials(context, course.id),
            );
          },
        );
      },
    );
  }

  Widget _buildAddCourseForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton(
  onPressed: () => _showAddCourseDialog(context),
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.all(16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Rounded corners for the button
    ),
    backgroundColor: Colors.transparent, // Make button background transparent
    shadowColor: Colors.transparent, // Remove button shadow
  ),
  child: Ink(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12), 
    ),
    child: Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(minWidth: 88, minHeight: 36),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(
            Icons.add,
            size: 40,
            color: Colors.white, 
          ),
          const SizedBox(height: 10),
          const Text(
            'Add New Course',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  ),
),

          const SizedBox(height: 20),
        ],
      ),
    );
  }


  Future<void> _showAddCourseDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String code = '';
    String category = 'General';
    String? instructorId;
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    String fee = '';
    List<Map<String, dynamic>> teachers = [];

    // Fetch teachers from Firestore
    final teachersSnapshot = await _usersCollection.where('role', isEqualTo: 'teacher').get();
    teachers = teachersSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      return {
        'id': doc.id,
        'name': data != null ? data['name'] ?? 'Unknown Teacher' : 'Unknown Teacher',
      };
    }).toList();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add New Course'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Course Name'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                      onSaved: (value) => name = value ?? '',
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Course Code (e.g., C1, C2)'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                      onSaved: (value) => code = value ?? '',
                    ),
                    DropdownButtonFormField<String>(
                      value: category,
                      items: ['General', 'Science', 'Math', 'Language', 'Arts']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) => category = value ?? 'General',
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: instructorId,
                      hint: const Text('Select Instructor'),
                      items: teachers.map((teacher) {
                        return DropdownMenuItem<String>(
                          value: teacher['id'],
                          child: Text(teacher['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          instructorId = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select an instructor' : null,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (selectedTime != null) {
                          setState(() {
                            startTime = selectedTime;
                          });
                        }
                      },
                      child: Text(startTime != null
                          ? 'Start Time: ${startTime!.format(context)}'
                          : 'Set Start Time'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (selectedTime != null) {
                          setState(() {
                            endTime = selectedTime;
                          });
                        }
                      },
                      child: Text(endTime != null
                          ? 'End Time: ${endTime!.format(context)}'
                          : 'Set End Time'),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Course Fee (₹)'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                      onSaved: (value) => fee = value ?? '',
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    formKey.currentState?.save();
                    if (instructorId == null || startTime == null || endTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please complete all fields')),
                      );
                      return;
                    }
                    await _addCourse(context, name, code, category, instructorId!, startTime!, endTime!, fee);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Course added successfully')),
                      );
                    }
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showEditCourseDialog(BuildContext context, String courseId, Map<String, dynamic> data) async {
    final formKey = GlobalKey<FormState>();
    String name = data['name'] ?? '';
    String code = data['code'] ?? '';
    String category = data['category'] ?? 'General';
    String? instructorId = data['instructorId'];
    TimeOfDay? startTime = data['startTime'] is Timestamp
        ? TimeOfDay.fromDateTime((data['startTime'] as Timestamp).toDate())
        : null;
    TimeOfDay? endTime = data['endTime'] is Timestamp
        ? TimeOfDay.fromDateTime((data['endTime'] as Timestamp).toDate())
        : null;
    String fee = data['fee'] ?? '';
    List<Map<String, dynamic>> teachers = [];

    // Fetch teachers from Firestore
    final teachersSnapshot = await _usersCollection.where('role', isEqualTo: 'teacher').get();
    teachers = teachersSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      return {
        'id': doc.id,
        'name': data != null ? data['name'] ?? 'Unknown Teacher' : 'Unknown Teacher',
      };
    }).toList();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Course'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: name,
                      decoration: const InputDecoration(labelText: 'Course Name'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                      onSaved: (value) => name = value ?? '',
                    ),
                    TextFormField(
                      initialValue: code,
                      decoration: const InputDecoration(labelText: 'Course Code'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                      onSaved: (value) => code = value ?? '',
                    ),
                    DropdownButtonFormField<String>(
                      value: category,
                      items: ['General', 'Science', 'Math', 'Language', 'Arts']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) => category = value ?? 'General',
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: instructorId,
                      hint: const Text('Select Instructor'),
                      items: teachers.map((teacher) {
                        return DropdownMenuItem<String>(
                          value: teacher['id'],
                          child: Text(teacher['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          instructorId = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select an instructor' : null,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime: startTime ?? TimeOfDay.now(),
                        );
                        if (selectedTime != null) {
                          setState(() {
                            startTime = selectedTime;
                          });
                        }
                      },
                      child: Text(startTime != null
                          ? 'Start Time: ${startTime!.format(context)}'
                          : 'Set Start Time'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime: endTime ?? TimeOfDay.now(),
                        );
                        if (selectedTime != null) {
                          setState(() {
                            endTime = selectedTime;
                          });
                        }
                      },
                      child: Text(endTime != null
                          ? 'End Time: ${endTime!.format(context)}'
                          : 'Set End Time'),
                    ),
                    TextFormField(
                      initialValue: fee,
                      decoration: const InputDecoration(labelText: 'Course Fee (₹)'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                      onSaved: (value) => fee = value ?? '',
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    formKey.currentState?.save();
                    await _updateCourse(courseId, name, code, category, instructorId, startTime, endTime, fee);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _viewCourseMaterials(BuildContext context, String courseId) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseMaterialsScreen(courseId: courseId),
      ),
    );
  }

  Future<void> _addCourse(BuildContext context, String name, String code, String category, String instructorId, TimeOfDay startTime, TimeOfDay endTime, String fee) async {
    try {
      final startTimeString = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
      final endTimeString = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

      final instructorRef = _usersCollection.doc(instructorId); // Convert instructorId to DocumentReference

      final newCourseRef = await _coursesCollection.add({
        'name': name,
        'code': code,
        'category': category,
        'instructorId': instructorRef, // Store as DocumentReference
        'startTime': startTimeString,
        'endTime': endTimeString,
        'fee': fee,
        'createdAt': FieldValue.serverTimestamp(),
        'materials': [],
        'mockTests': [],
      });

      await newCourseRef.collection('enrollments').doc('_init').set({
        'initializedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course added successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add course: $e')),
        );
      }
    }
  }

  Future<void> _updateCourse(String courseId, String name, String code, String category, String? instructorId, TimeOfDay? startTime, TimeOfDay? endTime, String fee) async {
    try {
      final startTimeString = startTime != null
          ? '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}'
          : null;
      final endTimeString = endTime != null
          ? '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}'
          : null;

      await _coursesCollection.doc(courseId).update({
        'name': name,
        'code': code,
        'category': category,
        'instructorId': instructorId,
        'startTime': startTimeString,
        'endTime': endTimeString,
        'fee': fee,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update course: $e')),
      );
    }
  }

  Future<void> _deleteCourse(String courseId) async {
    try {
      await _coursesCollection.doc(courseId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete course: $e')),
      );
    }
  }
}

class _CourseCard extends StatelessWidget {
  final String courseId;
  final String name;
  final String courseCode;
  final String category;
  final String? instructorId;
  final DateTime? startTime;
  final DateTime? endTime;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewMaterials;

  const _CourseCard({
    required this.courseId,
    required this.name,
    required this.courseCode,
    required this.category,
    required this.instructorId,
    required this.startTime,
    required this.endTime,
    required this.onEdit,
    required this.onDelete,
    required this.onViewMaterials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.code, size: 16),
                  const SizedBox(width: 4),
                  Text(courseCode),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.category, size: 16),
                  const SizedBox(width: 4),
                  Text(category),
                ],
              ),
              const SizedBox(height: 4),
              if (startTime != null && endTime != null)
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Live: ${DateFormat.jm().format(startTime!)} - ${DateFormat.jm().format(endTime!)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.black),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
                  MaterialButton(
                    onPressed: onViewMaterials,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: const Text(
                          'Materials',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
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

class CourseMaterialsScreen extends StatelessWidget {
  final String courseId;

  const CourseMaterialsScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Materials for Course $courseId'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Videos'),
              Tab(text: 'PDFs'),
              Tab(text: 'Mock Tests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMaterialsList('video'),
            _buildMaterialsList('pdf'),
            _buildMockTestsList(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddMaterialDialog(context, courseId),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildMaterialsList(String type) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final materials = snapshot.data!['materials'] as List<dynamic>? ?? [];
        final filteredMaterials = materials.where((material) => 
            material['type'] == type).toList();

        if (filteredMaterials.isEmpty) {
          return const Center(
            child: Text('No materials found'),
          );
        }

        return ListView.builder(
          itemCount: filteredMaterials.length,
          itemBuilder: (context, index) {
            final material = filteredMaterials[index];
            return ListTile(
              leading: Icon(type == 'video' ? Icons.video_library : Icons.picture_as_pdf),
              title: Text(material['title'] ?? 'Untitled'),
              subtitle: Text(material['url'] ?? 'No URL'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteMaterial(context, courseId, material['id']),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMockTestsList() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final mockTests = snapshot.data!['mockTests'] as List<dynamic>? ?? [];

        if (mockTests.isEmpty) {
          return const Center(
            child: Text('No mock tests found'),
          );
        }

        return ListView.builder(
          itemCount: mockTests.length,
          itemBuilder: (context, index) {
            final testId = mockTests[index];
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('mock_tests')
                  .doc(testId)
                  .get(),
              builder: (context, testSnapshot) {
                if (!testSnapshot.hasData) {
                  return const ListTile(
                    title: Text('Loading...'),
                  );
                }
                final testData = testSnapshot.data!.data() as Map<String, dynamic>? ?? {};
                return ListTile(
                  leading: const Icon(Icons.quiz),
                  title: Text(testData['title'] ?? 'Untitled Test'),
                  subtitle: Text('Questions: ${testData['questions']?.length ?? 0}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeMockTest(context, courseId, testId),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _showAddMaterialDialog(BuildContext context, String courseId) async {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String url = '';
    String type = 'video';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Material'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required field' : null,
                onSaved: (value) => title = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'URL'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required field' : null,
                onSaved: (value) => url = value ?? '',
              ),
              DropdownButtonFormField<String>(
                value: type,
                items: ['video', 'pdf']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) => type = value ?? 'video',
                decoration: const InputDecoration(labelText: 'Type'),
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
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                await _addMaterial(context, courseId, title, url, type);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addMaterial(
      BuildContext context, String courseId, String title, String url, String type) async {
    try {
      final newMaterial = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title,
        'url': url,
        'type': type,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .update({
            'materials': FieldValue.arrayUnion([newMaterial]),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Material added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add material: $e')),
      );
    }
  }

  Future<void> _deleteMaterial(BuildContext context, String courseId, String materialId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .get();

      final materials = doc.data()?['materials'] as List<dynamic>? ?? [];
      final materialToRemove = materials.firstWhere(
        (material) => material['id'] == materialId,
        orElse: () => null, // Ensure null is returned if no match is found
      );

      if (materialToRemove != null) {
        await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .update({
              'materials': FieldValue.arrayRemove([materialToRemove]),
            });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Material removed successfully')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Material not found')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove material: $e')),
        );
      }
    }
  }

  Future<void> _removeMockTest(BuildContext context, String courseId, String testId) async {
    try {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .update({
            'mockTests': FieldValue.arrayRemove([testId]),
          });
 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mock test removed from course')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove mock test: $e')),
      );
    }
  }
}