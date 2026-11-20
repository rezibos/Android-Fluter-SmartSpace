import 'package:flutter/material.dart';

import '../models/room_light.dart';
import '../models/sensor_snapshot.dart';
import '../theme/space_theme.dart';
import '../widgets/space_widgets.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({
    super.key,
    required this.rooms,
    required this.snapshot,
    required this.connected,
    required this.lastUpdated,
    required this.gasThreshold,
    required this.relayOn,
    required this.onLightToggle,
    required this.onAllLights,
    required this.onRelayToggle,
    required this.onLightTap,
    required this.onPumpTap,
    required this.onNotificationsTap,
    required this.onProfileTap,
    required this.onRetry,
    required this.onViewSensors,
  });

  final List<RoomLight> rooms;
  final SensorSnapshot? snapshot;
  final bool connected;
  final DateTime? lastUpdated;
  final int gasThreshold;
  final bool relayOn;
  final void Function(RoomLight, bool) onLightToggle;
  final ValueChanged<bool> onAllLights;
  final ValueChanged<bool> onRelayToggle;
  final ValueChanged<RoomLight> onLightTap;
  final VoidCallback onPumpTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;
  final VoidCallback onRetry;
  final VoidCallback onViewSensors;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 19) return 'Selamat sore';
    return 'Selamat malam';
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(
    key: const PageStorageKey('control-reference'),
    slivers: [
      SliverSafeArea(
        bottom: false,
        sliver: SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 118),
          sliver: SliverList.list(
            children: [
              _header(context),
              const SizedBox(height: 24),
              _roomFilter(context),
              const SizedBox(height: 18),
              _conditionPanel(context),
              const SizedBox(height: 18),
              _devicesPanel(context),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _header(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$_greeting, Willy',
              style: TextStyle(color: context.space.inkMuted, fontSize: 13),
            ),
            const SizedBox(height: 3),
            const Text(
              'Rumah Smart Space',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                letterSpacing: -.5,
              ),
            ),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: context.space.surface,
          borderRadius: BorderRadius.circular(99),
          boxShadow: const [
            BoxShadow(
              color: Color(0x102B1820),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Notifikasi',
              onPressed: onNotificationsTap,
              icon: Icon(
                Icons.notifications_none_rounded,
                color: context.space.active,
              ),
            ),
            IconButton(
              tooltip: 'Profil',
              onPressed: onProfileTap,
              icon: Icon(Icons.person_outline, color: context.space.active),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _roomFilter(BuildContext context) => SizedBox(
    height: 48,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _filterButton(
          context,
          icon: connected ? Icons.link_rounded : Icons.add_rounded,
          active: true,
          onTap: onRetry,
          tooltip: connected ? 'Sinkronkan hub' : 'Sambungkan hub',
        ),
        const SizedBox(width: 9),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.space.muted,
            borderRadius: BorderRadius.circular(99),
          ),
          child: const Text(
            'Semua',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 9),
        _filterButton(
          context,
          icon: Icons.weekend_outlined,
          tooltip: 'Ruang Tengah',
        ),
        _filterButton(context, icon: Icons.bed_outlined, tooltip: 'Kamar'),
        _filterButton(
          context,
          icon: Icons.soup_kitchen_outlined,
          tooltip: 'Dapur',
        ),
        _filterButton(
          context,
          icon: Icons.wb_twilight_outlined,
          tooltip: 'Depan',
        ),
      ],
    ),
  );

  Widget _filterButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    bool active = false,
    VoidCallback? onTap,
  }) => Padding(
    padding: const EdgeInsets.only(right: 5),
    child: Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: active ? context.space.active : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 21,
            color: active ? context.space.onActive : context.space.inkMuted,
          ),
        ),
      ),
    ),
  );

  Widget _conditionPanel(BuildContext context) {
    final useDummy = !connected || snapshot == null;
    final temperature = useDummy ? 26.6 : snapshot!.temperature;
    final humidity = useDummy ? 78 : snapshot!.humidity.round();
    final danger = useDummy ? false : snapshot!.isGasDanger(gasThreshold);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.space.muted,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kondisi Rumah',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Smart Space',
                      style: TextStyle(
                        color: context.space.inkMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              SpaceToggle(
                value: connected,
                onChanged: (_) => onRetry(),
                semanticLabel: connected
                    ? 'Hub aktif'
                    : 'Hub nonaktif, ketuk untuk mencoba koneksi',
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.water_drop_rounded,
                size: 16,
                color: context.space.ink,
              ),
              const SizedBox(width: 4),
              Text(
                '$humidity%',
                style: TextStyle(
                  color: context.space.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                temperature.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w500,
                  height: 1,
                  letterSpacing: -3,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 4, left: 3),
                child: Text(
                  '°',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _sensorAction(context, Icons.water_outlined, 'Udara'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _sensorAction(
                  context,
                  Icons.warning_amber_rounded,
                  'Gas',
                  danger: danger,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _sensorAction(
                  context,
                  Icons.water_drop_outlined,
                  'Hujan',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _sensorAction(context, Icons.grass_outlined, 'Tanah'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sensorAction(
    BuildContext context,
    IconData icon,
    String label, {
    bool danger = false,
  }) => InkWell(
    onTap: onViewSensors,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      constraints: const BoxConstraints(minHeight: 82),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
      decoration: BoxDecoration(
        color: context.space.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 25,
            color: danger ? SpacePalette.danger : context.space.active,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    ),
  );

  Widget _devicesPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.space.muted,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
            child: Row(
              children: [
                const Text(
                  'Perangkat',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                PopupMenuButton<bool>(
                  tooltip: 'Opsi perangkat',
                  enabled: connected,
                  onSelected: onAllLights,
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: context.space.inkMuted,
                  ),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: true,
                      child: Text('Nyalakan semua lampu'),
                    ),
                    PopupMenuItem(
                      value: false,
                      child: Text('Matikan semua lampu'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GridView.builder(
            primary: false,
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rooms.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: .82,
            ),
            itemBuilder: (context, index) {
              if (index == rooms.length) {
                return _PanelPumpCard(
                  isOn: relayOn,
                  enabled: connected,
                  onTap: onPumpTap,
                  onToggle: onRelayToggle,
                );
              }
              final room = rooms[index];
              return _PanelDeviceCard(
                room: room,
                assetPath: _assetForRoom(room.id),
                enabled: connected,
                onTap: () => onLightTap(room),
                onToggle: (value) => onLightToggle(room, value),
              );
            },
          ),
        ],
      ),
    );
  }

  String _assetForRoom(String id) => switch (id) {
    'tengah' => 'assets/devices/lamp_tengah.png',
    'kamar' => 'assets/devices/lamp_kamar.png',
    'dapur' => 'assets/devices/lamp_dapur.png',
    'depan' => 'assets/devices/lamp_depan.png',
    _ => 'assets/devices/lamp_tengah.png',
  };
}

class _PanelDeviceCard extends StatelessWidget {
  const _PanelDeviceCard({
    required this.room,
    required this.assetPath,
    required this.enabled,
    required this.onTap,
    required this.onToggle,
  });

  final RoomLight room;
  final String assetPath;
  final bool enabled;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Lampu ${room.name}, ${room.isOn ? 'aktif' : 'mati'}',
    button: true,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: context.space.surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              room.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            Text(
              room.isOn ? 'Menyala' : 'Mati',
              style: TextStyle(color: context.space.inkMuted, fontSize: 11),
            ),
            Expanded(
              child: Center(
                child: Opacity(
                  opacity: room.isOn ? 1 : .72,
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    semanticLabel: 'Gambar lampu ${room.name}',
                  ),
                ),
              ),
            ),
            Row(
              children: [
                SpaceToggle(
                  value: room.isOn,
                  onChanged: enabled ? onToggle : null,
                ),
                const Spacer(),
                Text(
                  '${room.brightness.round()}%',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _PanelPumpCard extends StatelessWidget {
  const _PanelPumpCard({
    required this.isOn,
    required this.enabled,
    required this.onTap,
    required this.onToggle,
  });

  final bool isOn;
  final bool enabled;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Pompa air, ${isOn ? 'aktif' : 'nonaktif'}',
    button: true,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: context.space.surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pompa',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            Text(
              isOn ? 'Aktif' : 'Nonaktif',
              style: TextStyle(color: context.space.inkMuted, fontSize: 11),
            ),
            Expanded(
              child: Center(
                child: Opacity(
                  opacity: isOn ? 1 : .72,
                  child: Image.asset(
                    'assets/devices/pompa.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    semanticLabel: 'Gambar pompa air',
                  ),
                ),
              ),
            ),
            SpaceToggle(value: isOn, onChanged: enabled ? onToggle : null),
          ],
        ),
      ),
    ),
  );
}
