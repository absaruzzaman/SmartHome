import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../widgets/info_card.dart';
import '../models/device_item.dart';
import '../services/room_storage.dart';

class DeviceControlScreen extends StatefulWidget {
  final DeviceItem device;
  final int roomIndex;
  final String deviceId;

  const DeviceControlScreen({
    super.key,
    required this.device,
    required this.roomIndex,
    required this.deviceId,
  });

  @override
  State<DeviceControlScreen> createState() => _DeviceControlScreenState();
}

class _DeviceControlScreenState extends State<DeviceControlScreen>
    with SingleTickerProviderStateMixin {
  late bool _isOn;

  late double _brightness;
  late int _speed;
  late double _temperature;
  late String _mode;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _isOn = widget.device.isOn;
    _brightness = widget.device.brightness;
    _speed = widget.device.speed;
    _temperature = widget.device.temperature;
    _mode = widget.device.mode;

    _animationController =
        AnimationController(duration: const Duration(milliseconds: 600), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _isLight => widget.device.type == 'light';
  bool get _isFan => widget.device.type == 'fan';
  bool get _isThermostat => widget.device.type == 'thermostat';
  bool get _isAirPurifier => widget.device.type == 'air_purifier';
  bool get _isSocket => widget.device.type == 'socket';

  Future<void> _savePatch(Map<String, dynamic> patch) async {
    await RoomStorage.updateDeviceInRoom(
      roomIndex: widget.roomIndex,
      deviceId: widget.deviceId,
      patch: patch,
    );
  }

  Future<void> _saveAll() async {
    final value = _isOn ? 'On' : 'Off';

    await _savePatch({
      'isOn': _isOn,
      'value': value,

      // CAPS fields
      'brightness': _brightness,
      'speed': _speed,
      'temperature': _temperature,
      'mode': _mode,
    });
  }

  void _togglePower(bool value) {
    HapticFeedback.lightImpact();
    setState(() => _isOn = value);
    _saveAll();
  }

  void _setBrightness(double v) {
    setState(() => _brightness = v);
    _saveAll();
  }

  void _setSpeed(int v) {
    setState(() => _speed = v.clamp(1, 5));
    _saveAll();
  }

  void _setTemp(double v) {
    setState(() => _temperature = v);
    _saveAll();
  }

  void _setMode(String v) {
    setState(() => _mode = v);
    _saveAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgOf(context),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildDeviceHeader(context),
                        const SizedBox(height: 20),

                        _buildPowerCard(context),
                        const SizedBox(height: 14),

                        if (_isLight) ...[
                          _buildBrightnessCard(context),
                          const SizedBox(height: 14),
                        ],

                        if (_isFan) ...[
                          _buildFanSpeedCard(context),
                          const SizedBox(height: 14),
                        ],

                        if (_isThermostat) ...[
                          _buildThermostatCard(context),
                          const SizedBox(height: 14),
                        ],

                        if (_isAirPurifier) ...[
                          _buildAirPurifierCard(context),
                          const SizedBox(height: 14),
                        ],

                        _buildStatusChip(context),
                        const SizedBox(height: 14),

                        const InfoCard(
                          message: 'Device state is saved locally (SharedPreferences).',
                          icon: Icons.info_outline_rounded,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.headingOf(context),
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primarySoftOf(context).withOpacity(0.6),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(widget.device.icon, size: 40, color: AppColors.primary),
        ),
        const SizedBox(height: 14),
        Text(
          widget.device.name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.headingOf(context),
            fontFamily: 'Inter',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          widget.device.type,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondaryOf(context),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildPowerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySoftOf(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOf(context),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Power',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.headingOf(context),
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to turn on or off',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryOf(context),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isOn,
            onChanged: _togglePower,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildBrightnessCard(BuildContext context) {
    return _card(
      context,
      title: 'Brightness',
      trailing: Text(
        '${_brightness.round()}%',
        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
      ),
      child: Slider(
        value: _brightness,
        min: 0,
        max: 100,
        onChanged: _isOn ? _setBrightness : null,
      ),
    );
  }

  Widget _buildFanSpeedCard(BuildContext context) {
    return _card(
      context,
      title: 'Fan Speed',
      trailing: Text(
        '$_speed',
        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _isOn ? () => _setSpeed(_speed - 1) : null,
            icon: const Icon(Icons.remove_circle_outline_rounded),
          ),
          Expanded(
            child: Slider(
              value: _speed.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: _isOn ? (v) => _setSpeed(v.round()) : null,
            ),
          ),
          IconButton(
            onPressed: _isOn ? () => _setSpeed(_speed + 1) : null,
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildThermostatCard(BuildContext context) {
    return _card(
      context,
      title: 'Temperature',
      trailing: Text(
        '${_temperature.toStringAsFixed(1)}°C',
        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
      ),
      child: Slider(
        value: _temperature,
        min: 16,
        max: 30,
        onChanged: _isOn ? _setTemp : null,
      ),
    );
  }

  Widget _buildAirPurifierCard(BuildContext context) {
    return _card(
      context,
      title: 'Mode',
      trailing: Text(
        _mode.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
      ),
      child: DropdownButtonFormField<String>(
        value: _mode,
        items: const [
          DropdownMenuItem(value: 'auto', child: Text('Auto')),
          DropdownMenuItem(value: 'sleep', child: Text('Sleep')),
          DropdownMenuItem(value: 'turbo', child: Text('Turbo')),
        ],
        onChanged: _isOn ? (v) => _setMode(v ?? 'auto') : null,
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    // for now: show ONLINE if device isOn (you can later tie to device.status)
    final bg = AppColors.onlineBgOf(context);
    final fg = AppColors.onlineTextOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOf(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 8,
            height: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'ONLINE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: fg,
              fontFamily: 'Inter',
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(
      BuildContext context, {
        required String title,
        required Widget child,
        Widget? trailing,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOf(context),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.headingOf(context),
                  fontFamily: 'Inter',
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
