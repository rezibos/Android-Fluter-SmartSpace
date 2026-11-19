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
    if (hour < 11) return 'Selamat pagi,';
    if (hour < 15) return 'Selamat siang,';
    if (hour < 19) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  @override
  Widget build(BuildContext context) {
    final active = rooms.where((room) => room.isOn).length;
    final danger = snapshot?.isGasDanger(gasThreshold) ?? false;
    return CustomScrollView(
      key: const PageStorageKey('control'),
      slivers: [
        SliverSafeArea(
          bottom: false,
          sliver: SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            sliver: SliverList.list(
              children: [
                _header(context),
                const SizedBox(height: 22),
                _heroCard(context, active),
                if (danger) ...[
                  const SizedBox(height: 12),
                  AlarmBanner(gas: snapshot!.gas, threshold: gasThreshold),
                ],
                const SizedBox(height: 24),
                _homeCondition(context),
                const SizedBox(height: 16),
                _usageSummary(context, active),
                const SizedBox(height: 16),
                _quickActions(context),
                const SizedBox(height: 24),
                _roomChips(context),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const Text(
                      'Perangkat',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$active aktif',
                      style: TextStyle(color: context.space.inkMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rooms.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: .9,
                  ),
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return DeviceCard(
                      name: room.name,
                      icon: room.icon,
                      isOn: room.isOn,
                      brightness: room.brightness.round(),
                      enabled: connected,
                      onToggle: (value) => onLightToggle(room, value),
                      onTap: () => onLightTap(room),
                    );
                  },
                ),
                const SizedBox(height: 28),
                const Text(
                  'Pompa Air',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                _pumpCard(context),
                const SizedBox(height: 14),
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: connected ? () => onAllLights(false) : null,
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('Matikan semua lampu'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.space.active,
                      backgroundColor: context.space.muted,
                      side: BorderSide(color: context.space.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _header(BuildContext context) => SizedBox(
    height: 52,
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: context.space.active,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: context.space.active.withValues(alpha: .2),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(child: Icon(Icons.pets, color: context.space.onActive)),
              Positioned(
                right: 7,
                top: 7,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: context.space.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NEKOUSE',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2),
            ),
            Text('Smart Space', style: TextStyle(fontSize: 12)),
          ],
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Notifikasi',
          onPressed: onNotificationsTap,
          style: IconButton.styleFrom(
            backgroundColor: context.space.surface,
            side: BorderSide(color: context.space.border),
            minimumSize: const Size(44, 44),
            shadowColor: const Color(0x16000000),
            elevation: 2,
          ),
          icon: Icon(
            Icons.notifications_none_rounded,
            color: context.space.active,
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          tooltip: 'Profil',
          onPressed: onProfileTap,
          style: IconButton.styleFrom(
            backgroundColor: context.space.surface,
            side: BorderSide(color: context.space.border),
            minimumSize: const Size(44, 44),
          ),
          icon: Icon(Icons.person_outline, color: context.space.active),
        ),
      ],
    ),
  );

  Widget _heroCard(BuildContext context, int active) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7A1F35), Color(0xFF591426)],
      ),
      borderRadius: BorderRadius.circular(28),
      boxShadow: const [
        BoxShadow(
          color: Color(0x287A1F35),
          blurRadius: 28,
          offset: Offset(0, 12),
        ),
      ],
    ),
    child: Stack(
      children: [
        Positioned(
          right: -25,
          top: -38,
          child: Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: context.space.accent.withValues(alpha: .16),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .13),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: connected ? SpacePalette.safe : Colors.white54,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        connected ? 'Hub terhubung' : 'Hub terputus',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (!connected)
                  TextButton(
                    onPressed: onRetry,
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    child: const Text('Coba lagi'),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              _greeting,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Rumah Willy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$active dari ${rooms.length} lampu menyala',
              style: TextStyle(color: Colors.white.withValues(alpha: .76)),
            ),
            if (lastUpdated != null) ...[
              const SizedBox(height: 5),
              Text(
                'Diperbarui ${TimeOfDay.fromDateTime(lastUpdated!).format(context)}',
                style: TextStyle(
                  color: context.space.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ],
    ),
  );

  Widget _roomChips(BuildContext context) => SizedBox(
    height: 72,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children:
          const [
                ('Semua', Icons.grid_view_rounded),
                ('Tengah', Icons.weekend_outlined),
                ('Kamar', Icons.bed_outlined),
                ('Dapur', Icons.soup_kitchen_outlined),
                ('Depan', Icons.wb_twilight_outlined),
              ]
              .map(
                (item) => Container(
                  width: 68,
                  margin: const EdgeInsets.only(right: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: item.$1 == 'Semua'
                        ? context.space.active
                        : context.space.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: item.$1 == 'Semua'
                          ? context.space.active
                          : context.space.border,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F2B1820),
                        blurRadius: 14,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.$2,
                        size: 21,
                        color: item.$1 == 'Semua'
                            ? context.space.onActive
                            : context.space.active,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.$1,
                        style: TextStyle(
                          color: item.$1 == 'Semua'
                              ? context.space.onActive
                              : context.space.inkMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    ),
  );

  Widget _homeCondition(BuildContext context) {
    final danger = snapshot?.isGasDanger(gasThreshold) ?? false;
    final items = [
      (
        'Suhu',
        snapshot == null ? '—' : '${snapshot!.temperature.toStringAsFixed(1)}°',
        Icons.thermostat_outlined,
        context.space.active,
      ),
      (
        'Udara',
        snapshot == null ? '—' : '${snapshot!.humidity.round()}%',
        Icons.water_outlined,
        context.space.accent,
      ),
      (
        'Gas',
        snapshot == null
            ? '—'
            : danger
            ? 'Bahaya'
            : 'Aman',
        Icons.warning_amber_rounded,
        danger ? SpacePalette.danger : SpacePalette.safe,
      ),
      (
        'Cuaca',
        snapshot == null
            ? '—'
            : snapshot!.isRaining
            ? 'Hujan'
            : 'Cerah',
        snapshot?.isRaining == true
            ? Icons.water_drop_outlined
            : Icons.wb_sunny_outlined,
        snapshot?.isRaining == true ? SpacePalette.info : context.space.accent,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Kondisi Rumah',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            TextButton(
              onPressed: onViewSensors,
              child: const Text('Lihat semua'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 105,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                width: 106,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.space.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: context.space.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0C2B1820),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(item.$3, size: 21, color: item.$4),
                    const Spacer(),
                    Text(
                      item.$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      item.$1,
                      style: TextStyle(
                        color: context.space.inkMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _usageSummary(BuildContext context, int active) {
    final lightWatt = rooms.fold<double>(
      0,
      (total, room) => total + (room.isOn ? 18 * room.brightness / 100 : 0),
    );
    final estimatedWatt = lightWatt + (relayOn ? 65 : 0) + 8;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.space.muted,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.space.border),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: context.space.surface,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(Icons.bolt_rounded, color: context.space.active),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Penggunaan saat ini',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  '$active lampu aktif • Pompa ${relayOn ? 'aktif' : 'mati'}',
                  style: TextStyle(color: context.space.inkMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${estimatedWatt.toStringAsFixed(1)} W',
                style: TextStyle(
                  color: context.space.active,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Estimasi',
                style: TextStyle(color: context.space.inkMuted, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickActions(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Aksi Cepat',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: _quickButton(
              context,
              icon: Icons.lightbulb_rounded,
              label: 'Nyalakan',
              onTap: connected ? () => onAllLights(true) : null,
              filled: true,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _quickButton(
              context,
              icon: Icons.lightbulb_outline,
              label: 'Matikan',
              onTap: connected ? () => onAllLights(false) : null,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _quickButton(
              context,
              icon: Icons.monitor_heart_outlined,
              label: 'Sensor',
              onTap: onViewSensors,
            ),
          ),
        ],
      ),
    ],
  );

  Widget _quickButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool filled = false,
  }) => SizedBox(
    height: 58,
    child: OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        foregroundColor: filled ? context.space.onActive : context.space.active,
        backgroundColor: filled ? context.space.active : context.space.surface,
        side: BorderSide(
          color: filled ? context.space.active : context.space.border,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 19),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );

  Widget _pumpCard(BuildContext context) => InkWell(
    onTap: onPumpTap,
    borderRadius: BorderRadius.circular(24),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.space.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.space.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: relayOn
                  ? context.space.active.withValues(alpha: .1)
                  : context.space.muted,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.water_drop_outlined,
              color: relayOn ? context.space.accent : context.space.active,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pompa Air',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  relayOn ? 'Aktif • Tandon Utama' : 'Nonaktif • Tandon Utama',
                  style: TextStyle(color: context.space.inkMuted),
                ),
              ],
            ),
          ),
          SpaceToggle(
            value: relayOn,
            onChanged: connected ? onRelayToggle : null,
            semanticLabel: 'Pompa air, ${relayOn ? 'aktif' : 'nonaktif'}',
          ),
        ],
      ),
    ),
  );
}
