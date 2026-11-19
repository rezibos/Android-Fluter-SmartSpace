import 'package:flutter/material.dart';

import '../models/sensor_snapshot.dart';
import '../theme/space_theme.dart';
import '../widgets/space_widgets.dart';

class SensorScreen extends StatefulWidget {
  const SensorScreen({
    super.key,
    required this.snapshot,
    required this.connected,
    required this.gasThreshold,
    required this.gasHistory,
  });
  final SensorSnapshot? snapshot;
  final bool connected;
  final int gasThreshold;
  final List<double> gasHistory;

  @override
  State<SensorScreen> createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  int selectedMetric = 0;

  @override
  Widget build(BuildContext context) {
    final data = widget.snapshot;
    final danger = data?.isGasDanger(widget.gasThreshold) ?? false;
    final soil = switch (data?.soilState) {
      SoilState.wet => 'Basah',
      SoilState.normal => 'Normal',
      SoilState.dry => 'Kering',
      null => '—',
    };
    return ListView(
      key: const PageStorageKey('sensor'),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PANTAUAN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Grafik Sensor',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.space.surface,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: context.space.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.connected
                          ? SpacePalette.safe
                          : context.space.inkMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    widget.connected ? 'LIVE' : 'OFFLINE',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (danger) ...[
          const SizedBox(height: 18),
          AlarmBanner(gas: data!.gas, threshold: widget.gasThreshold),
        ],
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.22,
          children: [
            SensorCard(
              label: 'HUJAN',
              value: data == null
                  ? '—'
                  : data.isRaining
                  ? 'Hujan'
                  : 'Tidak hujan',
              icon: Icons.water_drop_outlined,
              statusColor: data?.isRaining == true
                  ? SpacePalette.info
                  : SpacePalette.safe,
            ),
            SensorCard(
              label: 'GAS',
              value: data == null
                  ? '—'
                  : danger
                  ? 'BAHAYA'
                  : 'Aman',
              icon: Icons.warning_amber_rounded,
              statusColor: danger ? SpacePalette.danger : SpacePalette.safe,
              danger: danger,
            ),
            SensorCard(
              label: 'KELEMBAPAN',
              value: data == null ? '—' : '${data.humidity.round()}%',
              icon: Icons.water_outlined,
              statusColor: SpacePalette.info,
            ),
            SensorCard(
              label: 'TANAH',
              value: soil,
              icon: Icons.grass_outlined,
              statusColor: data?.soilState == SoilState.dry
                  ? SpacePalette.warning
                  : SpacePalette.safe,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: context.space.active,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SUHU RUANGAN',
                      style: TextStyle(
                        color: context.space.onActive.withValues(alpha: .7),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data == null
                          ? '—'
                          : '${data.temperature.toStringAsFixed(1)}°',
                      style: TextStyle(
                        color: context.space.onActive,
                        fontSize: 52,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Icon(
                    Icons.water_drop_outlined,
                    color: context.space.onActive,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data == null ? '—' : '${data.humidity.round()}%',
                    style: TextStyle(
                      color: context.space.onActive,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Riwayat sesi ini',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('Gas')),
            ButtonSegment(value: 1, label: Text('Udara')),
            ButtonSegment(value: 2, label: Text('Tanah')),
          ],
          selected: {selectedMetric},
          onSelectionChanged: (value) =>
              setState(() => selectedMetric = value.first),
          showSelectedIcon: false,
        ),
        const SizedBox(height: 14),
        Container(
          height: 220,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: context.space.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: context.space.border),
          ),
          child: widget.gasHistory.length < 2
              ? Center(
                  child: Text(
                    'Data akan muncul setelah sensor mengirim data.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.space.inkMuted),
                  ),
                )
              : CustomPaint(
                  painter: SensorLinePainter(
                    values: widget.gasHistory,
                    color: danger ? SpacePalette.danger : context.space.active,
                  ),
                  size: Size.infinite,
                ),
        ),
      ],
    );
  }
}

class SensorLinePainter extends CustomPainter {
  SensorLinePainter({required this.values, required this.color});
  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFFE5E5E7)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = (maxValue - minValue).abs() < 1 ? 1 : maxValue - minValue;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final point = Offset(
        size.width * i / (values.length - 1),
        size.height - ((values[i] - minValue) / range * size.height * .75) - 16,
      );
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant SensorLinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}
