import 'package:flutter/material.dart';

import '../models/room_light.dart';
import '../theme/space_theme.dart';
import '../widgets/space_widgets.dart';

class LightDetailScreen extends StatefulWidget {
  const LightDetailScreen({
    super.key,
    required this.room,
    required this.onToggle,
    required this.onBrightness,
  });
  final RoomLight room;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onBrightness;

  @override
  State<LightDetailScreen> createState() => _LightDetailScreenState();
}

class _LightDetailScreenState extends State<LightDetailScreen> {
  late bool isOn = widget.room.isOn;
  late double brightness = widget.room.brightness;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      title: Text('Lampu ${widget.room.name}'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isOn ? context.space.active : context.space.muted,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  widget.room.icon,
                  color: isOn ? context.space.onActive : context.space.ink,
                  size: 34,
                ),
              ),
              const Spacer(),
              SpaceToggle(
                value: isOn,
                onChanged: (value) {
                  setState(() => isOn = value);
                  widget.onToggle(value);
                },
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${brightness.round()}%',
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w800,
              color: isOn ? context.space.ink : context.space.inkMuted,
            ),
          ),
          Text(
            'Kecerahan',
            style: TextStyle(fontSize: 16, color: context.space.inkMuted),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              const Text('Low'),
              Expanded(
                child: Slider(
                  value: brightness,
                  min: 10,
                  max: 100,
                  onChanged: isOn
                      ? (value) => setState(() => brightness = value)
                      : null,
                  onChangeEnd: widget.onBrightness,
                ),
              ),
              const Text('High'),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: isOn
                  ? () {
                      setState(() => isOn = false);
                      widget.onToggle(false);
                    }
                  : null,
              child: const Text('Matikan lampu ini'),
            ),
          ),
        ],
      ),
    ),
  );
}

class PumpDetailScreen extends StatefulWidget {
  const PumpDetailScreen({
    super.key,
    required this.isOn,
    required this.onChanged,
  });
  final bool isOn;
  final ValueChanged<bool> onChanged;
  @override
  State<PumpDetailScreen> createState() => _PumpDetailScreenState();
}

class _PumpDetailScreenState extends State<PumpDetailScreen> {
  late bool isOn = widget.isOn;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      title: const Text('Pompa Air'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.space.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: context.space.border),
            ),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: isOn ? context.space.active : context.space.muted,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.water_drop_outlined,
                    color: isOn ? context.space.onActive : context.space.ink,
                    size: 46,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  isOn ? 'Pompa Aktif' : 'Pompa Nonaktif',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tandon Utama • Status mengikuti Smart Space Hub',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.space.inkMuted),
                ),
                const SizedBox(height: 24),
                SpaceToggle(
                  value: isOn,
                  onChanged: (value) {
                    setState(() => isOn = value);
                    widget.onChanged(value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.gasDanger});
  final bool gasDanger;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      title: const Text('Notifikasi'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'HARI INI',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        if (gasDanger)
          const _Notice(
            icon: Icons.warning_amber_rounded,
            title: 'Gas bocor terdeteksi',
            detail: 'Kadar gas melewati batas aman.',
            danger: true,
          )
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  Icon(Icons.pets_outlined, size: 72),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada peringatan. Rumahmu aman.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.title,
    required this.detail,
    this.danger = false,
  });
  final IconData icon;
  final String title;
  final String detail;
  final bool danger;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: danger ? SpacePalette.danger : context.space.surface,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      children: [
        Icon(icon, color: danger ? Colors.white : context.space.ink),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: danger ? Colors.white : context.space.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: TextStyle(
                  color: danger ? Colors.white : context.space.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      title: const Text('Profil'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: context.space.muted,
          child: Icon(Icons.person_outline, color: context.space.ink, size: 44),
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text(
            'Willy',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 28),
        const TextField(
          decoration: InputDecoration(
            labelText: 'NAMA LENGKAP',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        const TextField(
          decoration: InputDecoration(
            labelText: 'EMAIL',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        const TextField(
          decoration: InputDecoration(
            labelText: 'NOMOR HP',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profil lokal disimpan.')),
            ),
            child: const Text('Simpan Perubahan'),
          ),
        ),
      ],
    ),
  );
}
