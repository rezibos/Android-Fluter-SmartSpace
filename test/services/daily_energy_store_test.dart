import 'package:flutter_test/flutter_test.dart';
import 'package:witdget/services/daily_energy_store.dart';

void main() {
  test('keeps energy on the same day and resets on a new day', () async {
    final store = MemoryDailyEnergyStore();

    await store.save(date: DateTime(2026, 11, 20), kwh: 1.5);

    expect((await store.load(DateTime(2026, 11, 20))).kwh, 1.5);
    expect((await store.load(DateTime(2026, 11, 21))).kwh, 0);
  });
}
