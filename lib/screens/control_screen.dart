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
    required this.onViewElectricity,
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
  final VoidCallback onViewElectricity;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 19) return 'Selamat sore';
    return 'Selamat malam';
  }

  double get _estimatedWatt =>
      rooms.fold<double>(
        0,
        (total, room) => total + (room.isOn ? 18 * room.brightness / 100 : 0),
      ) +
      (relayOn ? 65 : 0) +
      8;

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
    final danger = snapshot?.isGasDanger(gasThreshold) ?? false;
    final soilLabel = switch (snapshot?.soilState) {
      SoilState.wet => 'Basah',
      SoilState.normal => 'Normal',
      SoilState.dry => 'Kering',
      null => '—',
    };
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
                      'Kondisi Ruangan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      connected
                          ? 'Data sensor langsung'
                          : 'Hub belum terhubung',
                      style: TextStyle(
                        color: context.space.inkMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: danger
                      ? SpacePalette.dangerBackground
                      : context.space.surface,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: danger
                            ? SpacePalette.danger
                            : connected
                            ? SpacePalette.safe
                            : context.space.inkMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      danger
                          ? 'Gas bahaya'
                          : connected
                          ? 'Aman'
                          : 'Offline',
                      style: TextStyle(
                        color: danger ? SpacePalette.danger : context.space.ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            snapshot == null
                ? '—'
                : '${snapshot!.humidity.round()}% kelembapan',
            style: TextStyle(
              color: context.space.inkMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _roundIndicator(
                context,
                snapshot?.isRaining == true
                    ? Icons.water_drop_rounded
                    : Icons.wb_sunny_outlined,
                snapshot?.isRaining == true
                    ? SpacePalette.info
                    : context.space.accent,
              ),
              const SizedBox(width: 22),
              Text(
                snapshot == null
                    ? '—'
                    : snapshot!.temperature.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w500,
                  height: 1,
                  letterSpacing: -3,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 30, left: 3),
                child: Text(
                  '°',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 14),
              _roundIndicator(
                context,
                Icons.grass_outlined,
                snapshot?.soilState == SoilState.dry
                    ? SpacePalette.warning
                    : SpacePalette.safe,
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _sensorAction(
                  context,
                  Icons.water_outlined,
                  'Udara',
                  snapshot == null ? '—' : '${snapshot!.humidity.round()}%',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _sensorAction(
                  context,
                  Icons.warning_amber_rounded,
                  'Gas',
                  snapshot == null
                      ? '—'
                      : danger
                      ? 'Bahaya'
                      : 'Aman',
                  danger: danger,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _sensorAction(
                  context,
                  Icons.water_drop_outlined,
                  'Hujan',
                  snapshot == null
                      ? '—'
                      : snapshot!.isRaining
                      ? 'Ya'
                      : 'Tidak',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _sensorAction(
                  context,
                  Icons.grass_outlined,
                  'Tanah',
                  soilLabel,
                ),
              ),
            ],
          ),
          if (!connected) ...[
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba hubungkan lagi'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _roundIndicator(BuildContext context, IconData icon, Color color) =>
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: context.space.surface,
          shape: BoxShape.circle,
          border: Border.all(color: context.space.border),
        ),
        child: Icon(icon, color: color, size: 21),
      );

  Widget _sensorAction(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool danger = false,
  }) => InkWell(
    onTap: onViewSensors,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 9),
      decoration: BoxDecoration(
        color: context.space.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 19,
            color: danger ? SpacePalette.danger : context.space.active,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: context.space.inkMuted, fontSize: 9),
          ),
        ],
      ),
    ),
  );

  Widget _devicesPanel(BuildContext context) {
    final activeCount = rooms.where((room) => room.isOn).length;
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
                Text(
                  '$activeCount dari ${rooms.length} lampu aktif',
                  style: TextStyle(color: context.space.inkMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rooms.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: .98,
            ),
            itemBuilder: (context, index) {
              final room = rooms[index];
              return _PanelDeviceCard(
                room: room,
                enabled: connected,
                onTap: () => onLightTap(room),
                onToggle: (value) => onLightToggle(room, value),
              );
            },
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: onPumpTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.space.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: context.space.muted,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.water_drop_outlined,
                      color: relayOn
                          ? context.space.accent
                          : context.space.active,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pompa Air',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          relayOn
                              ? 'Aktif • Tandon Utama'
                              : 'Nonaktif • Tandon Utama',
                          style: TextStyle(
                            color: context.space.inkMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SpaceToggle(
                    value: relayOn,
                    onChanged: connected ? onRelayToggle : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: context.space.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _massAction(
                  context,
                  icon: Icons.add_rounded,
                  label: 'Semua Nyala',
                  onTap: connected ? () => onAllLights(true) : null,
                  filled: true,
                ),
                const SizedBox(width: 8),
                _massAction(
                  context,
                  icon: Icons.power_settings_new_rounded,
                  label: 'Semua Mati',
                  onTap: connected ? () => onAllLights(false) : null,
                ),
                const Spacer(),
                InkWell(
                  onTap: onViewElectricity,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${_estimatedWatt.toStringAsFixed(0)} W',
                              style: TextStyle(
                                color: context.space.active,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Estimasi',
                              style: TextStyle(
                                color: context.space.inkMuted,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: context.space.active,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _massAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool filled = false,
  }) => Tooltip(
    message: label,
    child: IconButton(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: filled ? context.space.active : context.space.muted,
        foregroundColor: filled ? context.space.onActive : context.space.active,
      ),
      icon: Icon(icon),
    ),
  );
}

class _PanelDeviceCard extends StatelessWidget {
  const _PanelDeviceCard({
    required this.room,
    required this.enabled,
    required this.onTap,
    required this.onToggle,
  });

  final RoomLight room;
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.space.surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        room.isOn ? 'Aktif' : 'Mati',
                        style: TextStyle(
                          color: context.space.inkMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                SpaceToggle(
                  value: room.isOn,
                  onChanged: enabled ? onToggle : null,
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: Icon(
                room.icon,
                size: 50,
                color: room.isOn
                    ? context.space.active
                    : context.space.inkMuted.withValues(alpha: .55),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  Icons.light_mode_outlined,
                  size: 15,
                  color: context.space.accent,
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
