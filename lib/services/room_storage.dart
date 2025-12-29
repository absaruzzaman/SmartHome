import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/session_manager.dart';

class RoomStorage {
  static const String _roomsKeyPrefix = 'rooms_list_v2_';

  // ---------------- Key ----------------
  static Future<String?> _resolveKey() async {
    final token = await SessionManager.instance.getToken();
    final username = await SessionManager.instance.getUserName();
    if (token == null || token.isEmpty || username == null || username.isEmpty) return null;
    return '$_roomsKeyPrefix$username';
  }

  // ---------------- Icon helpers ----------------
  static int iconCodePoint(IconData icon) => icon.codePoint;

  static IconData iconFromCodePoint(int codePoint) {
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  // ---------------- Builders ----------------
  static Map<String, dynamic> makeRoom({
    required String id,
    required String name,
    required IconData icon,
    bool isOnline = false,
    List<Map<String, dynamic>> devices = const [],
  }) {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': iconCodePoint(icon),
      'isOnline': isOnline,
      'devices': devices,
    };
  }

  static Map<String, dynamic> makeDevice({
    required String id,
    required String name,
    required String type,
    required String status,
    required String value,
    required IconData icon,
    required bool isOn,
    double brightness = 75.0,
    int speed = 2,
    double temperature = 22.0,
    String mode = 'auto',
  }) {
    return {
      'id': id,
      'name': name,
      'type': type,
      'status': status,
      'value': value,
      'iconCodePoint': iconCodePoint(icon),
      'isOn': isOn,
      'brightness': brightness,
      'speed': speed,
      'temperature': temperature,
      'mode': mode,
    };
  }

  // ---------------- Load/Save ----------------
  static Future<List<Map<String, dynamic>>> loadRooms() async {
    final key = await _resolveKey();
    if (key == null) return [];

    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key);
    if (list == null || list.isEmpty) return [];

    return list.map((s) => Map<String, dynamic>.from(jsonDecode(s) as Map)).toList();
  }

  static Future<void> saveRooms(List<Map<String, dynamic>> rooms) async {
    final key = await _resolveKey();
    if (key == null) return;

    final prefs = await SharedPreferences.getInstance();
    final encoded = rooms.map((r) => jsonEncode(r)).toList();
    await prefs.setStringList(key, encoded);
  }

  // =========================================================
  // ✅ ROOM OPERATIONS (this is what your RoomsScreen needs)
  // =========================================================

  /// Generic patch update for a room (safe + reusable)
  static Future<void> updateRoom({
    required int roomIndex,
    required Map<String, dynamic> patch,
  }) async {
    final rooms = await loadRooms();
    if (roomIndex < 0 || roomIndex >= rooms.length) return;

    final room = Map<String, dynamic>.from(rooms[roomIndex]);
    room.addAll(patch);

    rooms[roomIndex] = room;
    await saveRooms(rooms);
  }

  /// ✅ Fixes your error: RoomStorage.renameRoom(...)
  static Future<void> renameRoom({
    required int roomIndex,
    required String newName,
  }) async {
    await updateRoom(roomIndex: roomIndex, patch: {'name': newName});
  }

  /// Delete a room
  static Future<void> deleteRoom({
    required int roomIndex,
  }) async {
    final rooms = await loadRooms();
    if (roomIndex < 0 || roomIndex >= rooms.length) return;

    rooms.removeAt(roomIndex);
    await saveRooms(rooms);
  }

  /// Add a room (returns the updated rooms list if you want it)
  static Future<List<Map<String, dynamic>>> addRoom({
    required Map<String, dynamic> room,
  }) async {
    final rooms = await loadRooms();
    rooms.add(room);
    await saveRooms(rooms);
    return rooms;
  }

  // =========================================================
  // ✅ DEVICE OPERATION (already used by DeviceControlScreen)
  // =========================================================

  static Future<void> updateDeviceInRoom({
    required int roomIndex,
    required String deviceId,
    required Map<String, dynamic> patch,
  }) async {
    final rooms = await loadRooms();
    if (roomIndex < 0 || roomIndex >= rooms.length) return;

    final room = Map<String, dynamic>.from(rooms[roomIndex]);
    final devices = (room['devices'] as List?)?.cast<dynamic>() ?? [];

    final idx = devices.indexWhere((d) => (d as Map)['id'] == deviceId);
    if (idx == -1) return;

    final current = Map<String, dynamic>.from(devices[idx] as Map);
    current.addAll(patch);

    devices[idx] = current;
    room['devices'] = devices;

    rooms[roomIndex] = room;
    await saveRooms(rooms);
  }
}
