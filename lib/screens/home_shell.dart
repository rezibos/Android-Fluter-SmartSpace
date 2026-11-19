import 'dart:async';

import 'package:flutter/material.dart';

import '../models/room_light.dart';
import '../models/sensor_snapshot.dart';
import '../services/esp32_service.dart';
import '../theme/space_theme.dart';
import 'control_screen.dart';
import 'detail_screens.dart';
import 'electricity_screen.dart';
import 'nekouse_screen.dart';
import 'sensor_screen.dart';
import 'settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.service,
    required this.themeMode,
    required this.onThemeChanged,
  });
  final Esp32Service service;
  final SpaceThemeMode themeMode;
  final ValueChanged<SpaceThemeMode> onThemeChanged;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;
  int _gasThreshold = 400;
  bool _connected = false;
  bool _relayOn = false;
  bool _buzzerEnabled = true;
  bool _notificationsEnabled = true;
  bool _pollInFlight = false;
  DateTime? _lastUpdated;
  SensorSnapshot? _snapshot;
  Timer? _timer;
  final List<double> _gasHistory = [];
  late List<RoomLight> _rooms = const [
    RoomLight(
      id: 'tengah',
      name: 'Ruang Tengah',
      icon: Icons.weekend_outlined,
      isOn: false,
      brightness: 70,
    ),
    RoomLight(
      id: 'kamar',
      name: 'Kamar',
      icon: Icons.bed_outlined,
      isOn: false,
      brightness: 80,
    ),
    RoomLight(
      id: 'dapur',
      name: 'Dapur',
      icon: Icons.soup_kitchen_outlined,
      isOn: false,
      brightness: 90,
    ),
    RoomLight(
      id: 'depan',
      name: 'Lampu Depan',
      icon: Icons.wb_twilight_outlined,
      isOn: false,
      brightness: 100,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _poll();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.service.dispose();
    super.dispose();
  }

  Future<void> _poll() async {
    if (_pollInFlight) return;
    _pollInFlight = true;
    try {
      final data = await widget.service.fetchSensor();
      if (!mounted) return;
      setState(() {
        _snapshot = data;
        _connected = true;
        _relayOn = data.relayOn;
        _lastUpdated = DateTime.now();
        _rooms = _rooms
            .map(
              (room) =>
                  room.copyWith(isOn: data.lightStates[room.id] ?? room.isOn),
            )
            .toList();
        _gasHistory.add(data.gas.toDouble());
        if (_gasHistory.length > 60) _gasHistory.removeAt(0);
      });
    } catch (_) {
      if (mounted) setState(() => _connected = false);
    } finally {
      _pollInFlight = false;
    }
  }

  Future<void> _toggleLight(RoomLight room, bool value) async {
    final index = _rooms.indexWhere((item) => item.id == room.id);
    final previous = _rooms[index];
    setState(() => _rooms[index] = previous.copyWith(isOn: value));
    try {
      await widget.service.setLight(
        room.id,
        value,
        previous.brightness.round(),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _rooms[index] = previous);
      _showFailure();
    }
  }

  Future<void> _setAllLights(bool value) async {
    final previous = List<RoomLight>.from(_rooms);
    setState(
      () => _rooms = _rooms.map((room) => room.copyWith(isOn: value)).toList(),
    );
    try {
      await widget.service.setLight('semua', value, 80);
    } catch (_) {
      if (!mounted) return;
      setState(() => _rooms = previous);
      _showFailure();
    }
  }

  Future<void> _toggleRelay(bool value) async {
    final previous = _relayOn;
    setState(() => _relayOn = value);
    try {
      await widget.service.setRelay(value);
    } catch (_) {
      if (!mounted) return;
      setState(() => _relayOn = previous);
      _showFailure();
    }
  }

  Future<void> _setBrightness(RoomLight room, double value) async {
    final index = _rooms.indexWhere((item) => item.id == room.id);
    final previous = _rooms[index];
    setState(() => _rooms[index] = previous.copyWith(brightness: value));
    try {
      await widget.service.setLight(room.id, true, value.round());
    } catch (_) {
      if (!mounted) return;
      setState(() => _rooms[index] = previous);
      _showFailure();
    }
  }

  void _showFailure() => ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Gagal mengirim perintah. Coba lagi.')),
  );

  void _openLight(RoomLight room) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => LightDetailScreen(
        room: room,
        onToggle: (value) => _toggleLight(room, value),
        onBrightness: (value) => _setBrightness(room, value),
      ),
    ),
  );

  void _openPump() => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PumpDetailScreen(isOn: _relayOn, onChanged: _toggleRelay),
    ),
  );

  Future<void> _editHost() async {
    final controller = TextEditingController(text: widget.service.host);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sambungkan Hub'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Masukkan alamat IP yang tampil di layar OLED hub.'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'ALAMAT IP',
                hintText: '192.168.1.10',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (RegExp(r'^[a-zA-Z0-9.-]+$').hasMatch(value)) {
                Navigator.pop(context, value);
              }
            },
            child: const Text('Tes Koneksi'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null) return;
    final previous = widget.service.host;
    widget.service.updateHost(result);
    try {
      await widget.service.fetchSensor();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Hub berhasil terhubung.')));
      await _poll();
    } catch (_) {
      widget.service.updateHost(previous);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Koneksi gagal. Pastikan HP dan hub berada di Wi-Fi yang sama.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      ControlScreen(
        rooms: _rooms,
        snapshot: _snapshot,
        connected: _connected,
        lastUpdated: _lastUpdated,
        gasThreshold: _gasThreshold,
        relayOn: _relayOn,
        onLightToggle: _toggleLight,
        onAllLights: _setAllLights,
        onRelayToggle: _toggleRelay,
        onLightTap: _openLight,
        onPumpTap: _openPump,
        onNotificationsTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotificationsScreen(
              gasDanger: _snapshot?.isGasDanger(_gasThreshold) ?? false,
            ),
          ),
        ),
        onProfileTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        ),
        onRetry: _poll,
        onViewSensors: () => setState(() => _tab = 1),
      ),
      SensorScreen(
        snapshot: _snapshot,
        connected: _connected,
        gasThreshold: _gasThreshold,
        gasHistory: _gasHistory,
      ),
      NekouseScreen(
        snapshot: _snapshot,
        rooms: _rooms,
        connected: _connected,
        gasThreshold: _gasThreshold,
        onOpenControl: () => setState(() => _tab = 0),
        onOpenSensors: () => setState(() => _tab = 1),
      ),
      ElectricityScreen(rooms: _rooms, relayOn: _relayOn),
      SettingsScreen(
        connected: _connected,
        host: widget.service.host,
        gasThreshold: _gasThreshold,
        buzzerEnabled: _buzzerEnabled,
        notificationsEnabled: _notificationsEnabled,
        themeMode: widget.themeMode,
        onThresholdChanged: (value) => setState(() => _gasThreshold = value),
        onBuzzerChanged: (value) => setState(() => _buzzerEnabled = value),
        onNotificationsChanged: (value) =>
            setState(() => _notificationsEnabled = value),
        onThemeChanged: widget.onThemeChanged,
        onEditHost: _editHost,
        onProfileTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        ),
      ),
    ];
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _tab, children: screens),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        child: Container(
          height: 64,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: context.space.surface,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: context.space.border),
            boxShadow: [
              BoxShadow(
                color: context.space.active.withValues(alpha: .12),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.tune_rounded, 'Kontrol'),
              _navItem(1, Icons.show_chart_rounded, 'Grafik'),
              _nekouseNavItem(),
              _navItem(3, Icons.bolt_outlined, 'Listrik'),
              _navItem(4, Icons.settings_outlined, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final selected = _tab == index;
    return InkWell(
      onTap: () => setState(() => _tab = index),
      borderRadius: BorderRadius.circular(99),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: selected ? 108 : 48,
        height: 48,
        decoration: BoxDecoration(
          color: selected ? context.space.active : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: context.space.active.withValues(alpha: .22),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 21,
              color: selected ? context.space.onActive : context.space.active,
            ),
            if (selected) ...[
              const SizedBox(width: 7),
              Text(
                label,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyle(
                  color: context.space.onActive,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _nekouseNavItem() {
    final selected = _tab == 2;
    return Semantics(
      label: 'Nekouse',
      button: true,
      selected: selected,
      child: InkWell(
        onTap: () => setState(() => _tab = 2),
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 54,
          height: 54,
          transform: Matrix4.translationValues(0, selected ? -8 : -5, 0),
          decoration: BoxDecoration(
            color: context.space.active,
            shape: BoxShape.circle,
            border: Border.all(color: context.space.surface, width: 4),
            boxShadow: [
              BoxShadow(
                color: context.space.active.withValues(alpha: .28),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Icon(
            Icons.pets_rounded,
            color: selected ? context.space.accent : context.space.onActive,
            size: 25,
          ),
        ),
      ),
    );
  }
}
