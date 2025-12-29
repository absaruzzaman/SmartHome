import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import '../services/room_storage.dart';
import '../utils/id_gen.dart';
import 'room_devices_screen.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedBottomTab = 2;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  List<Map<String, dynamic>> _rooms = [];

  final TextEditingController _roomNameCtrl = TextEditingController();
  IconData _selectedRoomIcon = Icons.home_rounded;

  final List<IconData> _roomIcons = const [
    Icons.weekend_rounded,
    Icons.bed_rounded,
    Icons.restaurant_rounded,
    Icons.bathtub_rounded,
    Icons.work_rounded,
    Icons.garage_rounded,
    Icons.park_rounded,
    Icons.home_rounded,
    Icons.dining_rounded,
    Icons.meeting_room_rounded,
    Icons.lightbulb_rounded,
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
    _initRooms();
  }

  @override
  void dispose() {
    _roomNameCtrl.dispose();
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

  Future<void> _initRooms() async {
    final loaded = await RoomStorage.loadRooms();

    if (loaded.isEmpty) {
      final List<Map<String, dynamic>> defaults = <Map<String, dynamic>>[
        RoomStorage.makeRoom(
          id: IdGen.room(),
          name: 'Living Room',
          icon: Icons.weekend_rounded,
          isOnline: true,
          devices: const [],
        ),
        RoomStorage.makeRoom(
          id: IdGen.room(),
          name: 'Master Bedroom',
          icon: Icons.bed_rounded,
          isOnline: true,
          devices: const [],
        ),
        RoomStorage.makeRoom(
          id: IdGen.room(),
          name: 'Kitchen',
          icon: Icons.restaurant_rounded,
          isOnline: true,
          devices: const [],
        ),
        RoomStorage.makeRoom(
          id: IdGen.room(),
          name: 'Bathroom',
          icon: Icons.bathtub_rounded,
          isOnline: false,
          devices: const [],
        ),
      ];

      await RoomStorage.saveRooms(defaults);

      if (!mounted) return;
      setState(() => _rooms = defaults);
      return;
    }

    if (!mounted) return;
    setState(() => _rooms = loaded);
  }

  // ---------------- Add Room ----------------

  void _openAddRoomDialog() {
    final card = AppColors.cardOf(context);
    final heading = AppColors.headingOf(context);
    final secondary = AppColors.textSecondaryOf(context);
    final borderSoft = AppColors.borderSoftOf(context);
    final primarySoft = AppColors.primarySoftOf(context);

    _roomNameCtrl.clear();
    _selectedRoomIcon = Icons.home_rounded;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Add New Room',
                style: TextStyle(fontWeight: FontWeight.bold, color: heading),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _roomNameCtrl,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Room name',
                      hintText: 'e.g. Dining Room',
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
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Choose icon',
                      style: TextStyle(fontSize: 12, color: secondary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _roomIcons.map((icon) {
                      final selected = icon == _selectedRoomIcon;
                      return GestureDetector(
                        onTap: () => setDialogState(() => _selectedRoomIcon = icon),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: selected ? primarySoft : card,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected ? AppColors.primary : borderSoft,
                              width: 1.2,
                            ),
                          ),
                          child: Icon(
                            icon,
                            color: selected ? AppColors.primary : secondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final name = _roomNameCtrl.text.trim();
                    if (name.isEmpty) {
                      _showSnackbar('Room name required');
                      return;
                    }

                    final exists = _rooms.any((r) =>
                    (r['name'] as String).toLowerCase() == name.toLowerCase());
                    if (exists) {
                      _showSnackbar('Room already exists');
                      return;
                    }

                    final room = RoomStorage.makeRoom(
                      id: IdGen.room(),
                      name: name,
                      icon: _selectedRoomIcon,
                      isOnline: false,
                      devices: const [],
                    );

                    setState(() => _rooms.add(room));
                    await RoomStorage.saveRooms(_rooms);

                    if (mounted) Navigator.pop(context);
                    _showSnackbar('Room added');
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------- Rename / Delete Room ----------------

  void _openRoomMenu(int roomIndex) {
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
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('Rename Room'),
                onTap: () {
                  Navigator.pop(context);
                  _renameRoom(roomIndex);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline_rounded, color: errorText),
                title: Text('Delete Room', style: TextStyle(color: errorText)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteRoom(roomIndex);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _renameRoom(int roomIndex) async {
    final room = _rooms[roomIndex];
    final ctrl = TextEditingController(text: (room['name'] ?? '').toString());
    final card = AppColors.cardOf(context);
    final heading = AppColors.headingOf(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: card,
        title: Text('Rename Room', style: TextStyle(color: heading)),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );

    if (ok != true) return;
    final newName = ctrl.text.trim();
    if (newName.isEmpty) return;

    setState(() => _rooms[roomIndex]['name'] = newName);
    await RoomStorage.renameRoom(roomIndex: roomIndex, newName: newName);

    _showSnackbar('Room renamed');
  }

  Future<void> _deleteRoom(int roomIndex) async {
    final errorText = AppColors.errorTextOf(context);
    final card = AppColors.cardOf(context);
    final heading = AppColors.headingOf(context);

    final name = (_rooms[roomIndex]['name'] ?? '').toString();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: card,
        title: Text('Delete Room?', style: TextStyle(color: heading)),
        content: Text('Delete "$name" and all its devices?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: errorText),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => _rooms.removeAt(roomIndex));
    await RoomStorage.saveRooms(_rooms);

    _showSnackbar('Room deleted');
  }

  // ---------------- Navigation ----------------

  void _openRoom(int index) {
    final room = _rooms[index];
    final roomName = (room['name'] ?? 'Room').toString();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomDevicesScreen(
          roomIndex: index,
          roomName: roomName,
        ),
      ),
    ).then((_) => _initRooms());
  }

  int _deviceCount(Map<String, dynamic> room) {
    final devices = (room['devices'] as List?) ?? [];
    return devices.length;
  }

  IconData _roomIcon(Map<String, dynamic> room) {
    final cp = room['iconCodePoint'] as int;
    return RoomStorage.iconFromCodePoint(cp);
  }

  bool _roomOnline(Map<String, dynamic> room) {
    final v = room['isOnline'];
    return v == true;
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.bgOf(context);
    final card = AppColors.cardOf(context);
    final heading = AppColors.headingOf(context);
    final secondary = AppColors.textSecondaryOf(context);
    final shadow = AppColors.shadowOf(context);
    final borderSoft = AppColors.borderSoftOf(context);

    final onlineDot = AppColors.onlineText; // good for both (just a green)
    final offlineDot = secondary;

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddRoomDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
        onFabPressed: _openAddRoomDialog,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // Top bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: card,
                    boxShadow: [
                      BoxShadow(
                        color: shadow,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border(
                      bottom: BorderSide(color: borderSoft),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Rooms',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: heading,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _rooms.isEmpty
                      ? Center(
                    child: Text(
                      'No rooms yet. Add one.',
                      style: TextStyle(color: secondary),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(16).copyWith(bottom: 120),
                    itemCount: _rooms.length,
                    itemBuilder: (context, i) {
                      final room = _rooms[i];
                      final name = (room['name'] ?? 'Room').toString();
                      final icon = _roomIcon(room);
                      final devices = _deviceCount(room);
                      final online = _roomOnline(room);

                      return GestureDetector(
                        onTap: () => _openRoom(i),
                        onLongPress: () => _openRoomMenu(i),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: shadow,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: Border.all(color: borderSoft),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(icon, color: AppColors.primary, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: heading,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$devices device${devices == 1 ? '' : 's'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: online ? onlineDot : offlineDot,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.arrow_forward_ios, size: 16, color: secondary),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
