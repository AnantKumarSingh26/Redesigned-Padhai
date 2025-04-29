import 'package:flutter/material.dart';

class Course {
  final String title;
  final String code;
  final IconData icon;
  final int progress;
  final Color color;

  Course(this.title, this.code, this.icon, this.progress, this.color);
}