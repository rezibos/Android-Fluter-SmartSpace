import 'package:flutter_test/flutter_test.dart';
import 'package:witdget/models/sensor_snapshot.dart';

void main() {
  test('parses ESP32 payload and classifies thresholds', () {
    final snapshot = SensorSnapshot.fromJson({
      'suhu': 28.5,
      'udara': 65,
      'tanah': 3100,
      'hujan': 2400,
      'gas': 480,
      'kamar': 1,
      'tengah': 0,
      'dapur': 1,
      'depan': 0,
      'relay': 1,
    });

    expect(snapshot.temperature, 28.5);
    expect(snapshot.isRaining, isTrue);
    expect(snapshot.isGasDanger(400), isTrue);
    expect(snapshot.soilState, SoilState.dry);
    expect(snapshot.lightStates['kamar'], isTrue);
    expect(snapshot.relayOn, isTrue);
  });

  test('missing values use safe defaults', () {
    final snapshot = SensorSnapshot.fromJson(const {});

    expect(snapshot.temperature, 0);
    expect(snapshot.humidity, 0);
    expect(snapshot.lightStates.values.every((value) => !value), isTrue);
  });
}
