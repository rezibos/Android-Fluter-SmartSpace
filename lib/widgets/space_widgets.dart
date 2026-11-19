import 'package:flutter/material.dart';

import '../theme/space_theme.dart';

class SpaceToggle extends StatelessWidget {
  const SpaceToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    toggled: value,
    button: true,
    child: GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: AnimatedOpacity(
        opacity: onChanged == null ? .4 : 1,
        duration: const Duration(milliseconds: 180),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 56,
          height: 32,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: value
                ? context.space.active
                : Color.alphaBlend(
                    context.space.active.withValues(alpha: .12),
                    context.space.surface,
                  ),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: value
                  ? context.space.active
                  : context.space.active.withValues(alpha: .28),
            ),
          ),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: value ? context.space.onActive : Colors.white,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(color: Color(0x22000000), blurRadius: 6),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class DeviceCard extends StatelessWidget {
  const DeviceCard({
    super.key,
    required this.name,
    required this.icon,
    required this.isOn,
    required this.brightness,
    required this.onToggle,
    required this.onTap,
    required this.enabled,
  });

  final String name;
  final IconData icon;
  final bool isOn;
  final int brightness;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final foreground = isOn ? context.space.onActive : context.space.ink;
    return Semantics(
      label: 'Lampu $name, ${isOn ? 'aktif $brightness persen' : 'mati'}',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 174),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isOn ? context.space.active : context.space.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isOn ? context.space.active : context.space.border,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isOn
                      ? Colors.white.withValues(alpha: .13)
                      : context.space.muted,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: isOn ? foreground : context.space.active,
                  size: 25,
                ),
              ),
              const Spacer(),
              Text(
                name,
                style: TextStyle(
                  color: foreground,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                isOn ? 'Aktif • $brightness%' : 'Mati',
                style: TextStyle(color: foreground.withValues(alpha: .72)),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: SpaceToggle(
                  value: isOn,
                  onChanged: enabled ? onToggle : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SensorCard extends StatelessWidget {
  const SensorCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.statusColor,
    this.danger = false,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color statusColor;
  final bool danger;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: danger ? SpacePalette.dangerBackground : context.space.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: danger ? SpacePalette.danger : context.space.border,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: statusColor, size: 22),
            const Spacer(),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          label,
          style: TextStyle(
            color: context.space.inkMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: .5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class AlarmBanner extends StatelessWidget {
  const AlarmBanner({super.key, required this.gas, required this.threshold});
  final int gas;
  final int threshold;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: SpacePalette.danger,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.campaign_outlined, color: Colors.white, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alarm aktif: Gas terdeteksi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$gas melewati ambang $threshold. Buka jendela dan jauhi sumber api.',
                style: const TextStyle(color: Colors.white, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
