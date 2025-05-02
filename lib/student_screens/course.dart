import 'package:flutter/material.dart';

class Course {
  final String id; // Add id property
  final String name; // Add name property
  final String title;
  final String code;
  final IconData icon;
  final Color color;

  // Removed progress property as it is not part of the database schema
  Course(this.id, this.name, this.title, this.code, this.icon, this.color);
}