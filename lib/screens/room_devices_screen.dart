import 'dart:math';
import 'package:flutter/material.dart';

import '../utils/id_gen.dart';
import '../theme/app_colors.dart';
import '../services/room_storage.dart';
import '../models/device_item.dart';
import '../widgets/device_card.dart';
import 'device_control_screen.dart';

class RoomDevicesScreen extends StatefulWidget {
  final int roomIndex;
  final String roomName;

  const RoomDevicesScreen({
    super.key,
    required this.roomIndex,
    required this.roomName,
  });

  @override
  State<RoomDevicesScreen> createState() => _RoomDevicesScreenState();
}

class _RoomDevicesScreenState extends State<RoomDevicesScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  List<Animation<double>> _fadeAnimations = [];
  List<Animation<Offset>> _slideAnimations = [];

  List<DeviceItem> _devices = [];

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: const Duration(milliseconds: 800), vsync: this);

    _loadDevices();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _loadDevices() async {
    final rooms = await RoomStorage.loadRooms();
    if (rooms.isEmpty || widget.roomIndex >= rooms.length) {
      if (!mounted) return;
      setState(() => _devices = []);
      return;
    }

    final room = rooms[widget.roomIndex];
    final rawDevices = (room['devices'] as List?) ?? const [];

    final items = rawDevices
        .map((d) {
      final m = Map<String, dynamic>.from(d as Map);
      final id = (m['id'] ?? '') as String;
      if (id.isEmpty) return null;

      return DeviceItem(
        id: id,
        name: (m['name'] ?? '') as String,
        type: (m['type'] ?? '') as String,
        status: DeviceItem.statusFromString((m['status'] ?? 'offline') as String),
        value: (m['value'] ?? '') as String,
        icon: RoomStorage.iconFromCodePoint(m['iconCodePoint'] as int),
        isOn: (m['isOn'] == true),
        brightness: (m['brightness'] is num) ? (m['brightness'] as num).toDouble() : 75.0,
        speed: (m['speed'] is num) ? (m['speed'] as num).toInt() : 2,
        temperature: (m['temperature'] is num) ? (m['temperature'] as num).toDouble() : 22.0,
        mode: (m['mode'] ?? 'auto') as String,
      );
    })
        .whereType<DeviceItem>()
        .toList();

    final n = max(items.length, 1);

    _fadeAnimations = List.generate(
      n,
          (index) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(index * 0.1, 0.5 + (index * 0.1), curve: Curves.easeOut),
        ),
      ),
    );

    _slideAnimations = List.generate(
      n,
          (index) => Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(index * 0.1, 0.5 + (index * 0.1), curve: Curves.easeOut),
        ),
      ),
    );

    if (!mounted) return;
    setState(() => _devices = items);
    _animationController.forward(from: 0);
  }

  Future<void> _persistDevices() async {
    final rooms = await RoomStorage.loadRooms();
    if (rooms.isEmpty || widget.roomIndex >= rooms.length) return;

    final room = rooms[widget.roomIndex];

    room['devices'] = _devices.map((d) {
      return RoomStorage.makeDevice(
        id: d.id,
        name: d.name,
        type: d.type,
        status: DeviceItem.statusToString(d.status),
        value: d.value,
        icon: d.icon,
        isOn: d.isOn,
        brightness: d.brightness,
        speed: d.speed,
        temperature: d.temperature,
        mode: d.mode,
      );
    }).toList();

    rooms[widget.roomIndex] = room;
    await RoomStorage.saveRooms(rooms);
  }

  String _newId() => IdGen.device();

  IconData _iconForType(String type) {
    switch (type) {
      case 'fan':
        return Icons.air_rounded;
      case 'socket':
        return Icons.power_rounded;
      case 'thermostat':
        return Icons.thermostat_rounded;
      case 'air_purifier':
        return Icons.air_rounded;
      case 'light':
      default:
        return Icons.lightbulb_rounded;
    }
  }

  // ------------------ Add device ------------------

  void _openAddDeviceDialog() {
    final card = AppColors.cardOf(context);
    final heading = AppColors.headingOf(context);
    final secondary = AppColors.textSecondaryOf(context);
    final borderSoft = AppColors.borderSoftOf(context);

    final nameCtrl = TextEditingController();
    String type = 'light';
    IconData icon = _iconForType(type);

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (_, setDialogState) {
            return AlertDialog(
              backgroundColor: card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Add Device', style: TextStyle(color: heading)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Device name',
                      hintText: 'e.g. Ceiling Light',
                      labelStyle: TextStyle(color: secondary),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderSoft),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: type,
                    dropdownColor: card,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      labelStyle: TextStyle(color: secondary),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'light', child: Text('Light')),
                      DropdownMenuItem(value: 'fan', child: Text('Fan')),
                      DropdownMenuItem(value: 'socket', child: Text('Socket')),
                      DropdownMenuItem(value: 'thermostat', child: Text('Thermostat')),
                      DropdownMenuItem(value: 'air_purifier', child: Text('Air Purifier')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setDialogState(() {
                        type = v;
                        icon = _iconForType(v);
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) {
                      _showSnackbar('Device name required');
                      return;
                    }

                    // defaults per type
                    double brightness = 75.0;
                    int speed = 2;
                    double temperature = 22.0;
                    String mode = 'auto';

                    if (type == 'socket') {
                      brightness = 0;
                    }

                    setState(() {
                      _devices.add(
                        DeviceItem(
                          id: _newId(),
                          name: name,
                          type: type,
                          status: DeviceStatus.offline,
                          value: 'Off',
                          icon: icon,
                          isOn: false,
                          brightness: brightness,
                          speed: speed,
                          temperature: temperature,
                          mode: mode,
                        ),
                      );
                    });

                    await _persistDevices();
                    if (mounted) Navigator.pop(context);
                    _showSnackbar('Device added');
                    await _loadDevices();
                  },
                  child: const Text('Add', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ------------------ Rename / Delete device ------------------

  void _renameDevice(DeviceItem device) {
    final card = AppColors.cardOf(context);
    final heading = AppColors.headingOf(context);

    final ctrl = TextEditingController(text: device.name);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: card,
          title: Text('Rename Device', style: TextStyle(color: heading)),
          content: TextField(controller: ctrl),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                final newName = ctrl.text.trim();
                if (newName.isEmpty) {
                  _showSnackbar('Name required');
                  return;
                }

                setState(() => device.name = newName);
                await _persistDevices();

                if (mounted) Navigator.pop(context);
                _showSnackbar('Device renamed');
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteDevice(DeviceItem device) async {
    final card = AppColors.cardOf(context);
    final heading = AppColors.headingOf(context);
    final errorText = AppColors.errorTextOf(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: card,
          title: Text('Delete Device?', style: TextStyle(color: heading)),
          content: Text('Delete "${device.name}" from this room?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: errorText),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    setState(() => _devices.removeWhere((d) => d.id == device.id));
    await _persistDevices();
    _showSnackbar('Device deleted');
  }

  void _openDeviceMenu(DeviceItem device) {
    final card = AppColors.cardOf(context);
    final borderSoft = AppColors.borderSoftOf(context);
    final errorText = AppColors.errorTextOf(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: borderSoft,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('Rename Device'),
                onTap: () {
                  Navigator.pop(context);
                  _renameDevice(device);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline_rounded, color: errorText),
                title: Text('Delete Device', style: TextStyle(color: errorText)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteDevice(device);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // ------------------ Open control ------------------

  Future<void> _openControl(DeviceItem device) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DeviceControlScreen(
          device: device,
          roomIndex: widget.roomIndex,
          deviceId: device.id,
        ),
      ),
    );

    await _loadDevices();
  }

  void _showOverflowMenu() {
    final card = AppColors.cardOf(context);
    final borderSoft = AppColors.borderSoftOf(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: borderSoft,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.add_circle_outline_rounded),
                title: const Text('Add Device'),
                onTap: () {
                  Navigator.pop(context);
                  _openAddDeviceDialog();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.bgOf(context);
    final card = AppColors.cardOf(context);
    final heading = AppColors.headingOf(context);
    final secondary = AppColors.textSecondaryOf(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: card, // ✅ not Colors.white
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: heading, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.roomName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: heading,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: heading),
            onPressed: _showOverflowMenu,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _devices.isEmpty
            ? Center(
          child: Text(
            'No devices yet. Add one from menu.',
            style: TextStyle(color: secondary),
          ),
        )
            : GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.1,
          ),
          itemCount: _devices.length,
          itemBuilder: (context, index) {
            final device = _devices[index];
            return FadeTransition(
              opacity: _fadeAnimations[index],
              child: SlideTransition(
                position: _slideAnimations[index],
                child: GestureDetector(
                  onLongPress: () => _openDeviceMenu(device),
                  child: DeviceCard(
                    device: device,
                    onTap: () => _openControl(device),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
