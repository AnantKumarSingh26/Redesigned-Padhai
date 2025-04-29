import 'package:flutter/material.dart';
import 'course.dart'; // Use the Course class from course.dart

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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 100,
              color: course.color.withOpacity(0.1),
              child: Center(
                child: Icon(course.icon, size: 40, color: course.color),
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
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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