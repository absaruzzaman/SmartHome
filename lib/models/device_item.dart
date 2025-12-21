import 'package:flutter/material.dart';

/// Model for a smart home device
class DeviceItem {
  final String name;
  final String type;
  final DeviceStatus status;
  final String value;
  final IconData icon;
  final bool isOn;

  const DeviceItem({
    required this.name,
    required this.type,
    required this.status,
    required this.value,
    required this.icon,
    this.isOn = false,
  });

  DeviceItem copyWith({
    String? name,
    String? type,
    DeviceStatus? status,
    String? value,
    IconData? icon,
    bool? isOn,
  }) {
    return DeviceItem(
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      value: value ?? this.value,
      icon: icon ?? this.icon,
      isOn: isOn ?? this.isOn,
    );
  }
}

/// Device status enum
enum DeviceStatus {
  online,
  offline,
  waiting,
  error,
}

/// Model for a smart home scene
class SceneItem {
  final String title;
  final String subtitle;
  final bool isActive;
  final IconData icon;

  const SceneItem({
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.icon,
  });
}
