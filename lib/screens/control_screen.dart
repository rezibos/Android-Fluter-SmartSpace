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
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
          sliver: SliverList.list(
            children: [
              _header(context),
              const SizedBox(height: 20),
              _connectionCard(context),
              if (danger) ...[
                const SizedBox(height: 12),
                AlarmBanner(gas: snapshot!.gas, threshold: gasThreshold),
              ],
              const SizedBox(height: 28),
              Text(
                '$_greeting\nRumah Willy',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$active dari ${rooms.length} lampu menyala',
                style: TextStyle(color: context.space.inkMuted, fontSize: 15),
              ),
              const SizedBox(height: 22),
              _roomChips(context),
              const SizedBox(height: 28),
              Row(
                children: [
                  const Text(
                    'Perangkat',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
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
                    foregroundColor: context.space.ink,
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
      ],
    );
  }

  Widget _header(BuildContext context) => Row(
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: context.space.active,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.pets_outlined, color: context.space.onActive),
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
        icon: const Icon(Icons.notifications_none_rounded),
      ),
      IconButton(
        tooltip: 'Profil',
        onPressed: onProfileTap,
        icon: CircleAvatar(
          radius: 18,
          backgroundColor: context.space.muted,
          child: Icon(Icons.person_outline, color: context.space.ink),
        ),
      ),
    ],
  );

  Widget _connectionCard(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    decoration: BoxDecoration(
      color: context.space.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: context.space.border),
    ),
    child: Row(
      children: [
        Icon(
          connected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
          color: connected ? SpacePalette.safe : context.space.inkMuted,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                connected ? 'Hub terhubung' : 'Hub tidak terhubung',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                lastUpdated == null
                    ? 'Belum ada data'
                    : 'Terakhir diperbarui ${TimeOfDay.fromDateTime(lastUpdated!).format(context)}',
                style: TextStyle(color: context.space.inkMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        if (!connected)
          TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
      ],
    ),
  );

  Widget _roomChips(BuildContext context) => SizedBox(
    height: 44,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: ['Semua', 'Tengah', 'Kamar', 'Dapur', 'Depan']
          .map(
            (label) => Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 17),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: label == 'Semua'
                    ? context.space.active
                    : context.space.surface,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: label == 'Semua'
                      ? context.space.active
                      : context.space.border,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: label == 'Semua'
                      ? context.space.onActive
                      : context.space.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
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
              color: context.space.muted,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.water_drop_outlined),
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
