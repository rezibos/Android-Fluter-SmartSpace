import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/daily_energy_store.dart';
import '../services/esp32_service.dart';
import '../services/host_store.dart';
import '../theme/space_theme.dart';
import 'home_shell.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    required this.authService,
    required this.hostStore,
    required this.energyStore,
    required this.themeMode,
    required this.onThemeChanged,
    this.esp32Service,
  });

  final AuthService authService;
  final HostStore hostStore;
  final DailyEnergyStore energyStore;
  final Esp32Service? esp32Service;
  final SpaceThemeMode themeMode;
  final ValueChanged<SpaceThemeMode> onThemeChanged;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Esp32Service _esp32Service;
  bool _checking = true;
  bool _firebaseReady = false;
  bool _authenticated = false;
  String _initialHost = '';

  @override
  void initState() {
    super.initState();
    _esp32Service = widget.esp32Service ?? Esp32Service();
    _bootstrap();
  }

  @override
  void dispose() {
    _esp32Service.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      _firebaseReady = await widget.authService.isConfigured();
      _initialHost = await widget.hostStore.load() ?? '';
      if (_firebaseReady &&
          await widget.authService.isSignedIn() &&
          _initialHost.isNotEmpty) {
        _esp32Service.updateHost(_initialHost);
        await _esp32Service.fetchSensor();
        _authenticated = true;
      }
    } catch (_) {
      _authenticated = false;
    }
    if (mounted) setState(() => _checking = false);
  }

  Future<String?> _login(String host, String email, String password) async {
    try {
      await widget.authService.signIn(email: email, password: password);
    } on AuthFailure catch (error) {
      return error.message;
    }
    final previousHost = _esp32Service.host;
    _esp32Service.updateHost(host);
    try {
      await _esp32Service.fetchSensor();
      await widget.hostStore.save(host);
      _initialHost = host;
      return null;
    } catch (_) {
      _esp32Service.updateHost(previousHost);
      await widget.authService.signOut();
      return 'Login berhasil, tetapi hub ESP32 tidak dapat dihubungi.';
    }
  }

  Future<void> _logout() async {
    await widget.authService.signOut();
    await widget.hostStore.clear();
    if (mounted) {
      setState(() {
        _authenticated = false;
        _initialHost = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      child: _authenticated
          ? HomeShell(
              key: const ValueKey('home'),
              service: _esp32Service,
              disposeService: false,
              energyStore: widget.energyStore,
              themeMode: widget.themeMode,
              onThemeChanged: widget.onThemeChanged,
              onLogout: _logout,
              onHostChanged: widget.hostStore.save,
            )
          : LoginScreen(
              key: const ValueKey('login'),
              firebaseReady: _firebaseReady,
              initialHost: _initialHost,
              onLogin: _login,
              onAuthenticated: () => setState(() => _authenticated = true),
            ),
    );
  }
}
