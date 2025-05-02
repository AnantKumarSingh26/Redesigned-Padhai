import 'package:flutter/material.dart';

class Course {
  final String id;
  final String name;
  final String title;
  final String code;
  final IconData icon;
  final Color color;
  final String? startTime;
  final String? endTime;

  Course(
    this.id,
    this.name,
    this.title,
    this.code,
    this.icon,
    this.color, {
    this.startTime,
    this.endTime,
  });

  String get timing =>
      startTime != null && endTime != null
          ? '$startTime - $endTime'
          : 'No Timing';
}