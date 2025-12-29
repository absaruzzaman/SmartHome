import 'package:flutter/material.dart';

class SceneItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isActive;

  const SceneItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isActive = false,
  });
}
