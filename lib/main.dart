import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'services/daily_energy_store.dart';
import 'services/esp32_service.dart';
import 'theme/space_theme.dart';

void main() => runApp(const NekouseApp());

class NekouseApp extends StatefulWidget {
  const NekouseApp({super.key, this.service, this.energyStore});
  final Esp32Service? service;
  final DailyEnergyStore? energyStore;

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
    home: HomeShell(
      service: widget.service ?? Esp32Service(),
      energyStore: widget.energyStore ?? PlatformDailyEnergyStore(),
      themeMode: _themeMode,
      onThemeChanged: (value) => setState(() => _themeMode = value),
    ),
  );
}
