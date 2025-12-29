import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../services/room_storage.dart';
import '../models/device_item.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/device_card.dart';
import 'device_control_screen.dart';

class AllDevicesScreen extends StatefulWidget {
  const AllDevicesScreen({super.key});

  @override
  State<AllDevicesScreen> createState() => _AllDevicesScreenState();
}

class _AllDevicesScreenState extends State<AllDevicesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  List<_DeviceRow> _all = [];
  List<_DeviceRow> _filtered = [];
  int _selectedBottomTab = 1;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_applyFilter);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final rooms = await RoomStorage.loadRooms();
    final rows = <_DeviceRow>[];

    for (int i = 0; i < rooms.length; i++) {
      final room = rooms[i];
      final roomName = (room['name'] ?? 'Room').toString();

      final rawDevices = (room['devices'] as List?) ?? const [];
      for (final d in rawDevices) {
        final m = Map<String, dynamic>.from(d as Map);

        final id = (m['id'] ?? '').toString();
        if (id.isEmpty) continue;

        rows.add(
          _DeviceRow(
            roomIndex: i,
            roomName: roomName,
            device: DeviceItem(
              id: id,
              name: (m['name'] ?? '').toString(),
              type: (m['type'] ?? '').toString(),
              status: DeviceItem.statusFromString((m['status'] ?? 'offline').toString()),
              value: (m['value'] ?? '').toString(),
              icon: RoomStorage.iconFromCodePoint((m['iconCodePoint'] ?? Icons.lightbulb.codePoint) as int),
              isOn: (m['isOn'] == true),
              brightness: (m['brightness'] is num) ? (m['brightness'] as num).toDouble() : 75.0,
              speed: (m['speed'] is num) ? (m['speed'] as num).toInt() : 2,
              temperature: (m['temperature'] is num) ? (m['temperature'] as num).toDouble() : 22.0,
              mode: (m['mode'] ?? 'auto').toString(),
            ),
          ),
        );
      }
    }

    if (!mounted) return;

    setState(() {
      _all = rows;
      _filtered = rows;
      _loading = false;
    });

    _applyFilter();
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) {
      if (!mounted) return;
      setState(() => _filtered = List.from(_all));
      return;
    }

    if (!mounted) return;
    setState(() {
      _filtered = _all.where((row) {
        final d = row.device;
        return d.name.toLowerCase().contains(q) ||
            d.type.toLowerCase().contains(q) ||
            row.roomName.toLowerCase().contains(q);
      }).toList();
    });
  }

  Future<void> _openControl(_DeviceRow row) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DeviceControlScreen(
          device: row.device,
          roomIndex: row.roomIndex,
          deviceId: row.device.id,
        ),
      ),
    );

    // refresh after changes
    await _load();
  }

  // -------- Optional: rename/delete from global list --------

  void _renameDevice(_DeviceRow row) {
    final ctrl = TextEditingController(text: row.device.name);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename Device'),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final newName = ctrl.text.trim();
              if (newName.isEmpty) return;

              await RoomStorage.updateDeviceInRoom(
                roomIndex: row.roomIndex,
                deviceId: row.device.id,
                patch: {'name': newName},
              );

              if (mounted) Navigator.pop(context);
              await _load();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDevice(_DeviceRow row) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Device?'),
        content: Text('Delete "${row.device.name}" from "${row.roomName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorText),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final rooms = await RoomStorage.loadRooms();
    if (row.roomIndex < 0 || row.roomIndex >= rooms.length) return;

    final room = Map<String, dynamic>.from(rooms[row.roomIndex]);
    final devices = (room['devices'] as List?)?.cast<dynamic>() ?? [];

    devices.removeWhere((d) => (d as Map)['id'] == row.device.id);

    room['devices'] = devices;
    rooms[row.roomIndex] = room;
    await RoomStorage.saveRooms(rooms);

    await _load();
  }

  void _openDeviceMenu(_DeviceRow row) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderSoftOf(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _renameDevice(row);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: AppColors.errorText),
              title: Text('Delete', style: TextStyle(color: AppColors.errorText)),
              onTap: () {
                Navigator.pop(context);
                _deleteDevice(row);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgOf(context),
      appBar: AppBar(
        backgroundColor: AppColors.cardOf(context),
        elevation: 0,
        title: Text(
          'All Devices',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.headingOf(context),
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppColors.headingOf(context)),
            onPressed: _load,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search devices or rooms...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColors.cardOf(context),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                ? const Center(child: Text('No devices found'))
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final row = _filtered[i];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardOf(context),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowOf(context),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Room label
                      Row(
                        children: [
                          const Icon(Icons.room_rounded, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            row.roomName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // DeviceCard
                      GestureDetector(
                        onTap: () => _openControl(row),
                        onLongPress: () => _openDeviceMenu(row),
                        child: DeviceCard(
                          device: row.device,
                          onTap: () => _openControl(row),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _selectedBottomTab,
        onTabSelected: (index) {
          if (index == _selectedBottomTab) return;
          setState(() => _selectedBottomTab = index);
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/dashboard');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/devices');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/rooms');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
        onFabPressed: () {},
      ),
    );
  }
}

class _DeviceRow {
  final int roomIndex;
  final String roomName;
  final DeviceItem device;

  _DeviceRow({
    required this.roomIndex,
    required this.roomName,
    required this.device,
  });
}
