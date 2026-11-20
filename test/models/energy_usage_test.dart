import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:witdget/models/energy_usage.dart';
import 'package:witdget/models/room_light.dart';

void main() {
  test('calculates standby, dimmed lamps, pump, and active count', () {
    final usage = EnergyUsage.calculate(
      rooms: const [
        RoomLight(
          id: 'tengah',
          name: 'Tengah',
          icon: Icons.light,
          isOn: true,
          brightness: 50,
        ),
        RoomLight(
          id: 'kamar',
          name: 'Kamar',
          icon: Icons.light,
          isOn: false,
          brightness: 100,
        ),
      ],
      relayOn: true,
      dailyKwh: 1.25,
    );

    expect(usage.currentWatts, 82);
    expect(usage.currentKilowatts, closeTo(.082, .000001));
    expect(usage.activeDeviceCount, 2);
    expect(usage.estimatedCost, closeTo(1805.875, .001));
  });

  test('accumulates kWh from elapsed time', () {
    expect(
      EnergyUsage.accumulate(
        kwh: 1,
        watts: 1000,
        elapsed: const Duration(minutes: 30),
      ),
      closeTo(1.5, .000001),
    );
  });
}
