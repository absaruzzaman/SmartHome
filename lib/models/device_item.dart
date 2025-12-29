import 'package:flutter/material.dart';

enum DeviceStatus { online, offline, waiting, error }

class DeviceItem {
  final String id;
  String name;
  final String type;
  DeviceStatus status;
  String value;
  IconData icon;

  bool isOn;

  // ✅ CAPS fields
  double brightness;     // lights
  int speed;             // fans
  double temperature;    // thermostat
  String mode;           // air purifier

  DeviceItem({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.value,
    required this.icon,
    required this.isOn,
    this.brightness = 75.0,
    this.speed = 2,
    this.temperature = 22.0,
    this.mode = 'auto',
  });

  // ✅ Helpers (fixes your current screen error)
  static DeviceStatus statusFromString(String s) {
    switch (s) {
      case 'online':
        return DeviceStatus.online;
      case 'offline':
        return DeviceStatus.offline;
      case 'waiting':
        return DeviceStatus.waiting;
      case 'error':
        return DeviceStatus.error;
      default:
        return DeviceStatus.offline;
    }
  }

  static String statusToString(DeviceStatus st) {
    switch (st) {
      case DeviceStatus.online:
        return 'online';
      case DeviceStatus.offline:
        return 'offline';
      case DeviceStatus.waiting:
        return 'waiting';
      case DeviceStatus.error:
        return 'error';
    }
  }
}
