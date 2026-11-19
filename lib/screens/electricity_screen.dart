import 'package:flutter/material.dart';

import '../models/room_light.dart';
import '../theme/space_theme.dart';

class ElectricityScreen extends StatelessWidget {
  const ElectricityScreen({
    super.key,
    required this.rooms,
    required this.relayOn,
  });
  final List<RoomLight> rooms;
  final bool relayOn;

  @override
  Widget build(BuildContext context) {
    final activeLights = rooms.where((room) => room.isOn).length;
    final lightWatt = rooms.fold<double>(
      0,
      (sum, room) => sum + (room.isOn ? 18 * room.brightness / 100 : 0),
    );
    final pumpWatt = relayOn ? 65.0 : 0.0;
    final totalWatt = lightWatt + pumpWatt + 8;
    final estimatedKwh = totalWatt * 8 / 1000;
    return ListView(
      key: const PageStorageKey('electricity'),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      children: [
        const Text(
          'STATISTIK ENERGI',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Konsumsi Listrik',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: context.space.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: context.space.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estimasi hari ini',
                style: TextStyle(color: context.space.inkMuted),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    estimatedKwh.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 58,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 7, left: 7),
                    child: Text(
                      'kWh',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _metric(
                      context,
                      'Daya saat ini',
                      '${totalWatt.toStringAsFixed(1)} W',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _metric(
                      context,
                      'Estimasi biaya',
                      'Rp ${(estimatedKwh * 1450).round()}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Perkiraan dihitung dari daya nominal, bukan sensor meter listrik.',
                style: TextStyle(
                  color: context.space.inkMuted,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Grafik Per Jam',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Container(
          height: 190,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: context.space.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: context.space.border),
          ),
          child: CustomPaint(
            painter: EnergyBarPainter(
              active: context.space.active,
              muted: context.space.muted,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Rincian Perangkat',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _deviceRow(
          context,
          Icons.light_outlined,
          'Lampu Smart Space',
          '$activeLights perangkat aktif',
          lightWatt,
        ),
        const SizedBox(height: 10),
        _deviceRow(
          context,
          Icons.water_drop_outlined,
          'Pompa Air Tandon',
          relayOn ? 'Sedang aktif' : 'Nonaktif',
          pumpWatt,
        ),
        const SizedBox(height: 10),
        _deviceRow(
          context,
          Icons.hub_outlined,
          'Smart Hub & Siaga',
          'Sensor dan sistem',
          8,
        ),
      ],
    );
  }

  Widget _metric(BuildContext context, String label, String value) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: context.space.background,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: context.space.inkMuted, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );

  Widget _deviceRow(
    BuildContext context,
    IconData icon,
    String title,
    String detail,
    double watt,
  ) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.space.surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: context.space.border),
    ),
    child: Row(
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(
                detail,
                style: TextStyle(color: context.space.inkMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          '${watt.toStringAsFixed(1)} W',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

class EnergyBarPainter extends CustomPainter {
  EnergyBarPainter({required this.active, required this.muted});
  final Color active;
  final Color muted;
  @override
  void paint(Canvas canvas, Size size) {
    const values = [.18, .22, .3, .42, .36, .55, .72, .5, .82, .62, .4, .28];
    final gap = size.width / values.length;
    for (var i = 0; i < values.length; i++) {
      final height = size.height * values[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(i * gap + 3, size.height - height, gap - 7, height),
          const Radius.circular(6),
        ),
        Paint()..color = i == 8 ? active : muted,
      );
    }
  }

  @override
  bool shouldRepaint(covariant EnergyBarPainter oldDelegate) => false;
}
