import 'package:flutter/material.dart';

import 'screens/auth_gate.dart';
import 'services/auth_service.dart';
import 'services/daily_energy_store.dart';
import 'services/esp32_service.dart';
import 'services/host_store.dart';
import 'theme/space_theme.dart';

void main() => runApp(const NekouseApp());

class NekouseApp extends StatefulWidget {
  const NekouseApp({
    super.key,
    this.service,
    this.energyStore,
    this.authService,
    this.hostStore,
  });
  final Esp32Service? service;
  final DailyEnergyStore? energyStore;
  final AuthService? authService;
  final HostStore? hostStore;

  @override
  State<NekouseApp> createState() => _NekouseAppState();
}

class _NekouseAppState extends State<NekouseApp> {
  SpaceThemeMode _themeMode = SpaceThemeMode.monochrome;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Nekouse Smart Space',
    debugShowCheckedModeBanner: false,
    theme: SpaceTheme.build(_themeMode),
    home: AuthGate(
      esp32Service: widget.service,
      authService: widget.authService ?? PlatformAuthService(),
      hostStore: widget.hostStore ?? PlatformHostStore(),
      energyStore: widget.energyStore ?? PlatformDailyEnergyStore(),
      themeMode: _themeMode,
      onThemeChanged: (value) => setState(() => _themeMode = value),
    ),
  );
}
