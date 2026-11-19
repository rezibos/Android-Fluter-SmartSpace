import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/sensor_snapshot.dart';

class Esp32Exception implements Exception {
  const Esp32Exception(this.message);
  final String message;
  @override
  String toString() => message;
}

class Esp32Service {
  Esp32Service({
    this.host = '10.202.121.60',
    http.Client? client,
    this.timeout = const Duration(seconds: 3),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;
  String host;
  void updateHost(String value) => host = value.trim();

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.http(host, path, query);

  Future<SensorSnapshot> fetchSensor() async {
    try {
      final response = await _client.get(_uri('/sensor')).timeout(timeout);
      if (response.statusCode != 200) {
        throw Esp32Exception('Hub merespons ${response.statusCode}.');
      }
      final json = jsonDecode(response.body);
      if (json is! Map<String, dynamic>) {
        throw const Esp32Exception('Data sensor tidak valid.');
      }
      return SensorSnapshot.fromJson(json);
    } on Esp32Exception {
      rethrow;
    } catch (_) {
      throw const Esp32Exception('Tidak bisa terhubung ke Smart Space Hub.');
    }
  }

  Future<void> setLight(String room, bool isOn, int brightness) async {
    const rooms = {'kamar', 'tengah', 'dapur', 'depan', 'semua'};
    if (!rooms.contains(room)) {
      throw const Esp32Exception('Ruangan tidak valid.');
    }
    await _command('/lampu', {
      'ruang': room,
      'status': isOn ? '1' : '0',
      'bright': brightness.clamp(10, 100).toString(),
    });
  }

  Future<void> setRelay(bool isOn) =>
      _command('/relay', {'status': isOn ? '1' : '0'});

  Future<void> _command(String path, Map<String, String> query) async {
    try {
      final response = await _client.get(_uri(path, query)).timeout(timeout);
      if (response.statusCode != 200) {
        throw Esp32Exception('Perintah ditolak (${response.statusCode}).');
      }
    } on Esp32Exception {
      rethrow;
    } catch (_) {
      throw const Esp32Exception('Gagal mengirim perintah. Coba lagi.');
    }
  }

  void dispose() => _client.close();
}
