import 'package:flutter/services.dart';

class DailyEnergyRecord {
  const DailyEnergyRecord({required this.date, required this.kwh});

  final DateTime date;
  final double kwh;
}

abstract class DailyEnergyStore {
  Future<DailyEnergyRecord> load(DateTime now);

  Future<void> save({required DateTime date, required double kwh});

  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

class PlatformDailyEnergyStore implements DailyEnergyStore {
  static const _channel = MethodChannel('nekouse/daily_energy');

  @override
  Future<DailyEnergyRecord> load(DateTime now) async {
    final values = await _channel.invokeMapMethod<String, dynamic>(
      'loadDailyEnergy',
    );
    final today = DailyEnergyStore.dateKey(now);
    if (values?['date'] != today) {
      return DailyEnergyRecord(date: now, kwh: 0);
    }
    return DailyEnergyRecord(
      date: now,
      kwh: (values?['kwh'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  Future<void> save({required DateTime date, required double kwh}) =>
      _channel.invokeMethod<void>('saveDailyEnergy', {
        'date': DailyEnergyStore.dateKey(date),
        'kwh': kwh,
      });
}

class MemoryDailyEnergyStore implements DailyEnergyStore {
  String? _date;
  double _kwh = 0;

  @override
  Future<DailyEnergyRecord> load(DateTime now) async {
    if (_date != DailyEnergyStore.dateKey(now)) {
      return DailyEnergyRecord(date: now, kwh: 0);
    }
    return DailyEnergyRecord(date: now, kwh: _kwh);
  }

  @override
  Future<void> save({required DateTime date, required double kwh}) async {
    _date = DailyEnergyStore.dateKey(date);
    _kwh = kwh;
  }
}
