import 'package:flutter/material.dart';

import '../theme/space_theme.dart';
import '../widgets/space_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.connected,
    required this.host,
    required this.gasThreshold,
    required this.buzzerEnabled,
    required this.notificationsEnabled,
    required this.themeMode,
    required this.onThresholdChanged,
    required this.onBuzzerChanged,
    required this.onNotificationsChanged,
    required this.onThemeChanged,
    required this.onEditHost,
    required this.onProfileTap,
  });

  final bool connected;
  final String host;
  final int gasThreshold;
  final bool buzzerEnabled;
  final bool notificationsEnabled;
  final SpaceThemeMode themeMode;
  final ValueChanged<int> onThresholdChanged;
  final ValueChanged<bool> onBuzzerChanged;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<SpaceThemeMode> onThemeChanged;
  final VoidCallback onEditHost;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) => ListView(
    key: const PageStorageKey('settings'),
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
    children: [
      const Text(
        'AKUN',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: 4),
      const Text(
        'Pengaturan',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 22),
      _card(
        context,
        child: InkWell(
          onTap: onProfileTap,
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: context.space.muted,
                child: Icon(Icons.person_outline, color: context.space.ink),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Willy',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text('Profil lokal', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      _card(
        context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PERANGKAT UTAMA',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: .8,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.hub_outlined,
                  color: connected ? SpacePalette.safe : context.space.inkMuted,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Smart Space Hub',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  connected ? 'Terhubung' : 'Terputus',
                  style: TextStyle(
                    color: connected ? SpacePalette.safe : SpacePalette.danger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(host, style: TextStyle(color: context.space.inkMuted)),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onEditHost,
                child: const Text('Ubah dan tes alamat IP'),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      const Text(
        'Keamanan Sensor',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 12),
      _card(
        context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Batas Gas',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
                Text(
                  '$gasThreshold',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Slider(
              value: gasThreshold.toDouble(),
              min: 100,
              max: 600,
              divisions: 50,
              onChanged: (value) => onThresholdChanged(value.round()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Aman', style: TextStyle(color: context.space.inkMuted)),
                Text('Ambang', style: TextStyle(color: context.space.inkMuted)),
                Text('Bahaya', style: TextStyle(color: context.space.inkMuted)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Preferensi ini tersimpan selama aplikasi berjalan. Dukungan buzzer perangkat memerlukan firmware.',
              style: TextStyle(
                color: context.space.inkMuted,
                height: 1.4,
                fontSize: 12,
              ),
            ),
            const Divider(height: 30),
            _switchRow(
              context,
              Icons.volume_up_outlined,
              'Alarm Buzzer',
              buzzerEnabled,
              onBuzzerChanged,
            ),
            const SizedBox(height: 16),
            _switchRow(
              context,
              Icons.notifications_none,
              'Notifikasi Peringatan',
              notificationsEnabled,
              onNotificationsChanged,
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      const Text(
        'Tema',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _themeChoice(
              context,
              'Monokrom',
              SpaceThemeMode.monochrome,
              const Color(0xFF111111),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _themeChoice(
              context,
              'Oranye',
              SpaceThemeMode.orange,
              const Color(0xFFFF6A1A),
            ),
          ),
        ],
      ),
    ],
  );

  Widget _card(BuildContext context, {required Widget child}) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: context.space.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: context.space.border),
    ),
    child: child,
  );

  Widget _switchRow(
    BuildContext context,
    IconData icon,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) => Row(
    children: [
      Icon(icon),
      const SizedBox(width: 12),
      Expanded(
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      SpaceToggle(value: value, onChanged: onChanged),
    ],
  );

  Widget _themeChoice(
    BuildContext context,
    String label,
    SpaceThemeMode value,
    Color swatch,
  ) {
    final selected = themeMode == value;
    return InkWell(
      onTap: () => onThemeChanged(value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.space.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? context.space.active : context.space.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(color: swatch, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (selected) const Icon(Icons.check_circle, size: 20),
          ],
        ),
      ),
    );
  }
}
