import 'room_light.dart';

class EnergyUsage {
  const EnergyUsage({
    required this.currentWatts,
    required this.dailyKwh,
    required this.activeDeviceCount,
  });

  static const lampMaxWatts = 18.0;
  static const pumpWatts = 65.0;
  static const standbyWatts = 8.0;
  static const tariffPerKwh = 1444.70;

  final double currentWatts;
  final double dailyKwh;
  final int activeDeviceCount;

  double get currentKilowatts => currentWatts / 1000;
  double get estimatedCost => dailyKwh * tariffPerKwh;

  static EnergyUsage calculate({
    required List<RoomLight> rooms,
    required bool relayOn,
    required double dailyKwh,
  }) {
    final lampWatts = rooms.fold<double>(
      0,
      (total, room) =>
          total + (room.isOn ? lampMaxWatts * room.brightness / 100 : 0),
    );
    return EnergyUsage(
      currentWatts: standbyWatts + lampWatts + (relayOn ? pumpWatts : 0),
      dailyKwh: dailyKwh,
      activeDeviceCount:
          rooms.where((room) => room.isOn).length + (relayOn ? 1 : 0),
    );
  }

  static double accumulate({
    required double kwh,
    required double watts,
    required Duration elapsed,
  }) => kwh + (watts / 1000) * (elapsed.inMilliseconds / 3600000);
}
