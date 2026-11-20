import 'package:flutter/services.dart';

abstract class HostStore {
  Future<String?> load();
  Future<void> save(String host);
  Future<void> clear();
}

class PlatformHostStore implements HostStore {
  static const _channel = MethodChannel('nekouse/app_settings');

  @override
  Future<String?> load() => _channel.invokeMethod<String>('loadHost');

  @override
  Future<void> save(String host) =>
      _channel.invokeMethod<void>('saveHost', {'host': host});

  @override
  Future<void> clear() => _channel.invokeMethod<void>('clearHost');
}

class MemoryHostStore implements HostStore {
  MemoryHostStore([this.host]);
  String? host;

  @override
  Future<String?> load() async => host;

  @override
  Future<void> save(String host) async => this.host = host;

  @override
  Future<void> clear() async => host = null;
}
