import 'package:flutter/material.dart';
import 'course.dart';
import 'course_card.dart'; // Import CourseCard for use in CourseHorizontalList

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
      height: 215,
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