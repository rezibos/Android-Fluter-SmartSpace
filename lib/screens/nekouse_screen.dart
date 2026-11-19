import 'package:flutter/material.dart';

import '../models/room_light.dart';
import '../models/sensor_snapshot.dart';
import '../theme/space_theme.dart';

class NekouseScreen extends StatelessWidget {
  const NekouseScreen({
    super.key,
    required this.snapshot,
    required this.rooms,
    required this.connected,
    required this.gasThreshold,
    required this.onOpenControl,
    required this.onOpenSensors,
  });

  final SensorSnapshot? snapshot;
  final List<RoomLight> rooms;
  final bool connected;
  final int gasThreshold;
  final VoidCallback onOpenControl;
  final VoidCallback onOpenSensors;

  @override
  Widget build(BuildContext context) {
    final danger = snapshot?.isGasDanger(gasThreshold) ?? false;
    final active = rooms.where((room) => room.isOn).length;
    final title = !connected
        ? 'Aku sedang menunggu hub'
        : danger
        ? 'Rumah perlu perhatian'
        : 'Rumah aman';
    final message = !connected
        ? 'Hub belum terhubung. Periksa Wi-Fi agar aku bisa kembali berjaga.'
        : danger
        ? 'Gas melewati batas aman. Buka jendela dan jauhi sumber api.'
        : active == 0
        ? 'Semua lampu sedang beristirahat. Aku tetap memantau rumahmu.'
        : '$active lampu menyala dan semua sensor utama sedang kupantau.';

    return ListView(
      key: const PageStorageKey('nekouse'),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      children: [
        const Text(
          'PENJAGA RUMAH',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Nekouse',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7A1F35), Color(0xFF591426)],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [
              BoxShadow(
                color: Color(0x287A1F35),
                blurRadius: 30,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                width: 190,
                height: 170,
                child: CustomPaint(
                  painter: NekousePainter(
                    accent: context.space.accent,
                    danger: danger,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .75),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _summary(
                context,
                Icons.thermostat_outlined,
                'Suhu',
                snapshot == null
                    ? '—'
                    : '${snapshot!.temperature.toStringAsFixed(1)}°',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summary(
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
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _summary(
                context,
                Icons.lightbulb_outline,
                'Perangkat',
                '$active aktif',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summary(
                context,
                Icons.hub_outlined,
                'Hub',
                connected ? 'Online' : 'Offline',
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        SizedBox(
          height: 54,
          child: FilledButton.icon(
            onPressed: onOpenControl,
            icon: const Icon(Icons.tune_rounded),
            label: const Text('Buka Kontrol Rumah'),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 52,
          child: OutlinedButton.icon(
            onPressed: onOpenSensors,
            icon: const Icon(Icons.monitor_heart_outlined),
            label: const Text('Lihat Sensor'),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.space.active,
              side: BorderSide(color: context.space.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _summary(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool danger = false,
  }) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: danger ? SpacePalette.dangerBackground : context.space.surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: danger ? SpacePalette.danger : context.space.border,
      ),
    ),
    child: Row(
      children: [
        Icon(icon, color: danger ? SpacePalette.danger : context.space.active),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                label,
                style: TextStyle(color: context.space.inkMuted, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class NekousePainter extends CustomPainter {
  const NekousePainter({required this.accent, required this.danger});
  final Color accent;
  final bool danger;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 8);
    final face = Paint()..color = Colors.white;
    final shadow = Paint()..color = Colors.black.withValues(alpha: .12);
    canvas.drawOval(
      Rect.fromCenter(center: center.translate(0, 10), width: 145, height: 118),
      shadow,
    );
    final leftEar = Path()
      ..moveTo(center.dx - 63, center.dy - 33)
      ..lineTo(center.dx - 45, center.dy - 82)
      ..lineTo(center.dx - 15, center.dy - 48)
      ..close();
    final rightEar = Path()
      ..moveTo(center.dx + 63, center.dy - 33)
      ..lineTo(center.dx + 45, center.dy - 82)
      ..lineTo(center.dx + 15, center.dy - 48)
      ..close();
    canvas.drawPath(leftEar, face);
    canvas.drawPath(rightEar, face);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 145, height: 118),
      face,
    );
    final eye = Paint()..color = const Color(0xFF2B1820);
    canvas.drawOval(
      Rect.fromCenter(center: center.translate(-31, -5), width: 18, height: 26),
      eye,
    );
    canvas.drawOval(
      Rect.fromCenter(center: center.translate(31, -5), width: 18, height: 26),
      eye,
    );
    canvas.drawCircle(
      center.translate(0, 20),
      8,
      Paint()..color = danger ? SpacePalette.danger : accent,
    );
    final stroke = Paint()
      ..color = const Color(0xFF7A1F35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (final dy in [10.0, 22.0]) {
      canvas.drawLine(
        center.translate(-18, dy),
        center.translate(-65, dy - 5),
        stroke,
      );
      canvas.drawLine(
        center.translate(18, dy),
        center.translate(65, dy - 5),
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant NekousePainter oldDelegate) =>
      oldDelegate.danger != danger || oldDelegate.accent != accent;
}
