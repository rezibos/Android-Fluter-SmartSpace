import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:witdget/main.dart';
import 'package:witdget/models/sensor_snapshot.dart';
import 'package:witdget/services/esp32_service.dart';

class FakeEsp32Service extends Esp32Service {
  @override
  Future<SensorSnapshot> fetchSensor() async => SensorSnapshot.fromJson({
    'suhu': 28.5,
    'udara': 65,
    'tanah': 2100,
    'hujan': 3100,
    'gas': 250,
    'kamar': 0,
    'tengah': 1,
    'dapur': 0,
    'depan': 1,
    'relay': 0,
  });

  @override
  Future<void> setLight(String room, bool isOn, int brightness) async {}

  @override
  Future<void> setRelay(bool isOn) async {}

  @override
  void dispose() {}
}

void main() {
  testWidgets('bottom navigation switches between the three main screens', (
    tester,
  ) async {
    await tester.pumpWidget(NekouseApp(service: FakeEsp32Service()));
    await tester.pump();

    expect(find.text('Perangkat'), findsOneWidget);
    await tester.tap(find.text('Grafik'));
    await tester.pumpAndSettle();
    expect(find.text('Grafik Sensor'), findsOneWidget);

    await tester.tap(find.text('Listrik'));
    await tester.pumpAndSettle();
    expect(find.text('Konsumsi Listrik'), findsOneWidget);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Keamanan Sensor'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });
}
