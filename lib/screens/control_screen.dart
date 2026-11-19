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

  double get _estimatedWatt =>
      rooms.fold<double>(
        0,
        (total, room) => total + (room.isOn ? 18 * room.brightness / 100 : 0),
      ) +
      (relayOn ? 65 : 0) +
      8;

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
                _quickActions(context),
                const SizedBox(height: 20),
                _roomChips(context),
                const SizedBox(height: 22),
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
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7A1F35), Color(0xFF591426)],
      ),
      borderRadius: BorderRadius.circular(26),
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
            const SizedBox(height: 16),
            Text(
              _greeting,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .7),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Rumah Willy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _heroStat('$active/${rooms.length}', 'Lampu'),
                  _heroDivider(),
                  _heroStat(relayOn ? 'Aktif' : 'Mati', 'Pompa'),
                  _heroDivider(),
                  _heroStat(
                    '${_estimatedWatt.toStringAsFixed(0)} W',
                    'Estimasi',
                  ),
                ],
              ),
            ),
            if (lastUpdated != null) ...[
              const SizedBox(height: 8),
              Text(
                'Sinkron ${TimeOfDay.fromDateTime(lastUpdated!).format(context)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .55),
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ],
    ),
  );

  Widget _heroStat(String value, String label) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          maxLines: 1,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: .6),
            fontSize: 10,
          ),
        ),
      ],
    ),
  );

  Widget _heroDivider() => Container(
    width: 1,
    height: 28,
    color: Colors.white.withValues(alpha: .15),
  );

  Widget _roomChips(BuildContext context) => SizedBox(
    height: 48,
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
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: item.$1 == 'Semua'
                        ? context.space.active
                        : context.space.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: item.$1 == 'Semua'
                          ? context.space.active
                          : context.space.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.$2,
                        size: 18,
                        color: item.$1 == 'Semua'
                            ? context.space.onActive
                            : context.space.active,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        item.$1,
                        style: TextStyle(
                          color: item.$1 == 'Semua'
                              ? context.space.onActive
                              : context.space.inkMuted,
                          fontSize: 12,
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
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.space.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.space.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A2B1820),
                blurRadius: 18,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _conditionItem(context, items[0])),
                  Container(width: 1, height: 54, color: context.space.border),
                  Expanded(child: _conditionItem(context, items[1])),
                ],
              ),
              Divider(height: 1, color: context.space.border),
              Row(
                children: [
                  Expanded(child: _conditionItem(context, items[2])),
                  Container(width: 1, height: 54, color: context.space.border),
                  Expanded(child: _conditionItem(context, items[3])),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _conditionItem(
    BuildContext context,
    (String, String, IconData, Color) item,
  ) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: item.$4.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(item.$3, size: 19, color: item.$4),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.$2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                item.$1,
                style: TextStyle(color: context.space.inkMuted, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    ),
  );

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
              label: 'Semua Nyala',
              onTap: connected ? () => onAllLights(true) : null,
              filled: true,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _quickButton(
              context,
              icon: Icons.lightbulb_outline,
              label: 'Semua Mati',
              onTap: connected ? () => onAllLights(false) : null,
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
    height: 52,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 19),
          const SizedBox(width: 7),
          Text(
            label,
            maxLines: 1,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
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
