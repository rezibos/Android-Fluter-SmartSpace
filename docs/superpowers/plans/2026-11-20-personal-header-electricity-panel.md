# Personal Header and Electricity Panel Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Membangun header personal serta panel estimasi daya kW dan energi harian kWh yang tersimpan lokal, tanpa mengubah koneksi kontrol ESP32.

**Architecture:** Perhitungan listrik ditempatkan pada model murni `EnergyUsage` agar rumus dapat diuji tanpa Flutter UI. `DailyEnergyStore` menggunakan Android `SharedPreferences` melalui `MethodChannel`, sedangkan `HomeShell` mengakumulasi energi pada siklus polling dan memberikan snapshot ke `ControlScreen` untuk dirender.

**Tech Stack:** Flutter, Dart, Kotlin, Android SharedPreferences, Material 3, `flutter_test`.

## Global Constraints

- Empat lampu masing-masing maksimum 18 W, pompa 65 W, dan standby sistem 8 W.
- Tarif estimasi tetap Rp1.444,70 per kWh.
- Durasi ketika aplikasi tidak berjalan tidak diakumulasi.
- Data energi reset ketika tanggal lokal berubah.
- Kesalahan penyimpanan tidak boleh memutus kontrol ESP32.
- Header harus aman pada lebar 360–430 dp dan target sentuh minimal 48 dp.
- Semua nilai harus diberi konteks `Estimasi` karena bukan pembacaan sensor daya fisik.

---

### Task 1: Model Perhitungan Energi

**Files:**
- Create: `lib/models/energy_usage.dart`
- Create: `test/models/energy_usage_test.dart`

**Interfaces:**
- Consumes: `List<RoomLight>`, status relay, nilai kWh, dan rentang waktu.
- Produces: `EnergyUsage.currentWatts(...)`, `EnergyUsage.currentKilowatts(...)`, `EnergyUsage.accumulate(...)`, `estimatedCost`, dan `activeDeviceCount`.

- [ ] **Step 1: Tulis pengujian rumus yang gagal**

```dart
test('calculates standby, dimmed lamps, pump, and active count', () {
  final usage = EnergyUsage.calculate(
    rooms: const [
      RoomLight(id: 'tengah', name: 'Tengah', icon: Icons.light,
        isOn: true, brightness: 50),
      RoomLight(id: 'kamar', name: 'Kamar', icon: Icons.light,
        isOn: false, brightness: 100),
    ],
    relayOn: true,
    dailyKwh: 1.25,
  );
  expect(usage.currentWatts, 82); // 8 + 9 + 65
  expect(usage.currentKilowatts, closeTo(.082, .000001));
  expect(usage.activeDeviceCount, 2);
  expect(usage.estimatedCost, closeTo(1805.875, .001));
});

test('accumulates kWh from elapsed time', () {
  expect(EnergyUsage.accumulate(kwh: 1, watts: 1000,
    elapsed: const Duration(minutes: 30)), closeTo(1.5, .000001));
});
```

- [ ] **Step 2: Jalankan test dan pastikan gagal**

Run: `flutter test test/models/energy_usage_test.dart`
Expected: FAIL karena `EnergyUsage` belum tersedia.

- [ ] **Step 3: Implementasikan model murni**

```dart
class EnergyUsage {
  const EnergyUsage({required this.currentWatts, required this.dailyKwh,
    required this.activeDeviceCount});

  static const lampMaxWatts = 18.0;
  static const pumpWatts = 65.0;
  static const standbyWatts = 8.0;
  static const tariffPerKwh = 1444.70;

  final double currentWatts;
  final double dailyKwh;
  final int activeDeviceCount;

  double get currentKilowatts => currentWatts / 1000;
  double get estimatedCost => dailyKwh * tariffPerKwh;

  static EnergyUsage calculate({required List<RoomLight> rooms,
    required bool relayOn, required double dailyKwh}) {
    final lampWatts = rooms.fold<double>(0, (total, room) =>
      total + (room.isOn ? lampMaxWatts * room.brightness / 100 : 0));
    return EnergyUsage(
      currentWatts: standbyWatts + lampWatts + (relayOn ? pumpWatts : 0),
      dailyKwh: dailyKwh,
      activeDeviceCount:
        rooms.where((room) => room.isOn).length + (relayOn ? 1 : 0),
    );
  }

  static double accumulate({required double kwh, required double watts,
    required Duration elapsed}) =>
      kwh + (watts / 1000) * (elapsed.inMilliseconds / 3600000);
}
```

- [ ] **Step 4: Jalankan test model**

Run: `flutter test test/models/energy_usage_test.dart`
Expected: PASS untuk rumus watt, kW, kWh, biaya, dan jumlah perangkat.

### Task 2: Penyimpanan Energi Harian

**Files:**
- Create: `lib/services/daily_energy_store.dart`
- Modify: `android/app/src/main/kotlin/com/example/witdget/MainActivity.kt`
- Create: `test/services/daily_energy_store_test.dart`

**Interfaces:**
- Produces: `DailyEnergyRecord`, `DailyEnergyStore.load(DateTime now)`, dan `DailyEnergyStore.save(...)`.
- `load` mengembalikan nol ketika tanggal tersimpan berbeda dari tanggal lokal hari ini.

- [x] **Step 1: Sediakan channel penyimpanan Android tanpa dependency eksternal**

Gunakan channel `nekouse/daily_energy` dengan method `loadDailyEnergy` dan `saveDailyEnergy`. Implementasi Kotlin membaca/menulis Android `SharedPreferences` bernama `nekouse_energy`.

- [ ] **Step 2: Tulis pengujian reset dan persistensi**

```dart
final store = MemoryDailyEnergyStore();
await store.save(date: DateTime(2026, 11, 20), kwh: 1.5);
expect((await store.load(DateTime(2026, 11, 20))).kwh, 1.5);
expect((await store.load(DateTime(2026, 11, 21))).kwh, 0);
```

- [ ] **Step 3: Implementasikan penyimpanan dengan kegagalan aman**

```dart
class DailyEnergyRecord {
  const DailyEnergyRecord({required this.date, required this.kwh});
  final DateTime date;
  final double kwh;
}

abstract class DailyEnergyStore {
  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Future<DailyEnergyRecord> load(DateTime now);

  Future<void> save({required DateTime date, required double kwh});
}

class PlatformDailyEnergyStore implements DailyEnergyStore {
  static const channel = MethodChannel('nekouse/daily_energy');

  @override
  Future<DailyEnergyRecord> load(DateTime now) async {
    final values = await channel.invokeMapMethod<String, dynamic>(
      'loadDailyEnergy',
    );
    if (values?['date'] != DailyEnergyStore.dateKey(now)) {
      return DailyEnergyRecord(date: now, kwh: 0);
    }
    return DailyEnergyRecord(
      date: now,
      kwh: (values?['kwh'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  Future<void> save({required DateTime date, required double kwh}) =>
      channel.invokeMethod<void>('saveDailyEnergy', {
        'date': DailyEnergyStore.dateKey(date),
        'kwh': kwh,
      });
}

class MemoryDailyEnergyStore implements DailyEnergyStore {
  String? date;
  double kwh = 0;

  @override
  Future<DailyEnergyRecord> load(DateTime now) async => DailyEnergyRecord(
    date: now,
    kwh: date == DailyEnergyStore.dateKey(now) ? kwh : 0,
  );

  @override
  Future<void> save({required DateTime date, required double kwh}) async {
    this.date = DailyEnergyStore.dateKey(date);
    this.kwh = kwh;
  }
}
```

- [ ] **Step 4: Jalankan test penyimpanan**

Run: `flutter test test/services/daily_energy_store_test.dart`
Expected: PASS untuk hari sama, pergantian hari, dan nilai awal nol.

### Task 3: Integrasi Akumulasi di HomeShell

**Files:**
- Modify: `lib/screens/home_shell.dart`
- Modify: `lib/main.dart`
- Test: `test/widget_test.dart`

**Interfaces:**
- Consumes: `DailyEnergyStore`, `EnergyUsage.calculate`, dan waktu polling.
- Produces ke `ControlScreen`: `EnergyUsage energyUsage`.

- [ ] **Step 1: Tambahkan injeksi store yang dapat diuji**

```dart
const HomeShell({required this.service, required this.themeMode,
  required this.onThemeChanged, required this.energyStore});
final DailyEnergyStore energyStore;
```

- [ ] **Step 2: Muat nilai harian saat init**

```dart
double _dailyKwh = 0;
DateTime? _energyUpdatedAt;

Future<void> _loadDailyEnergy() async {
  try {
    final record = await widget.energyStore.load(DateTime.now());
    if (mounted) setState(() => _dailyKwh = record.kwh);
  } catch (_) {
    // Kontrol perangkat tetap berjalan dengan nilai sesi nol.
  }
  _energyUpdatedAt = DateTime.now();
}
```

- [ ] **Step 3: Akumulasi sebelum status polling diganti**

```dart
Future<void> _accrueEnergy(DateTime now) async {
  final previous = _energyUpdatedAt;
  _energyUpdatedAt = now;
  if (previous == null || !_isSameDate(previous, now)) {
    _dailyKwh = 0;
  } else {
    final watts = EnergyUsage.calculate(rooms: _rooms,
      relayOn: _relayOn, dailyKwh: _dailyKwh).currentWatts;
    _dailyKwh = EnergyUsage.accumulate(kwh: _dailyKwh,
      watts: watts, elapsed: now.difference(previous));
  }
  try {
    await widget.energyStore.save(date: now, kwh: _dailyKwh);
  } catch (_) {}
}
```

- [ ] **Step 4: Teruskan snapshot ke halaman Kontrol**

```dart
energyUsage: EnergyUsage.calculate(
  rooms: _rooms,
  relayOn: _relayOn,
  dailyKwh: _dailyKwh,
),
```

- [ ] **Step 5: Perbarui widget test dengan store mock**

Run: `flutter test test/widget_test.dart`
Expected: halaman tetap terbuka dan panel menerima data awal tanpa koneksi penyimpanan nyata.

### Task 4: Header Personal dan Panel Listrik

**Files:**
- Modify: `lib/screens/control_screen.dart`
- Test: `test/widget_test.dart`

**Interfaces:**
- Consumes: `connected`, callbacks header yang ada, dan `EnergyUsage energyUsage`.
- Produces: header personal responsif dan panel informasional listrik.

- [ ] **Step 1: Tambahkan ekspektasi widget**

```dart
expect(find.text('Willy'), findsOneWidget);
expect(find.text('Penggunaan Listrik'), findsOneWidget);
expect(find.text('kWh hari ini'), findsOneWidget);
expect(find.text('Estimasi biaya'), findsOneWidget);
```

- [ ] **Step 2: Ubah header menjadi personal greeting**

Gunakan avatar 48 dp berinisial `W`, kolom sapaan/nama/status dengan `Expanded`, serta dua `IconButton` 48 dp. Status memakai titik aman hijau saat terhubung dan maroon redup saat terputus.

- [ ] **Step 3: Tambahkan panel setelah Kondisi Rumah**

```dart
_conditionPanel(context),
const SizedBox(height: 18),
_electricityPanel(context),
const SizedBox(height: 18),
_devicesPanel(context),
```

Panel menampilkan `energyUsage.currentKilowatts.toStringAsFixed(3)`, `dailyKwh`, jumlah perangkat aktif, dan format rupiah biaya. Gunakan `Semantics` untuk angka utama dan `FittedBox`/layout fleksibel agar tidak overflow pada 360 dp.

- [ ] **Step 4: Jalankan widget test**

Run: `flutter test test/widget_test.dart`
Expected: PASS dan seluruh teks header/panel ditemukan.

### Task 5: Verifikasi dan Pengiriman

**Files:**
- Review seluruh file pada Task 1–4.

**Interfaces:**
- Consumes: seluruh implementasi.
- Produces: perubahan terformat, dianalisis, dan dipush.

- [ ] **Step 1: Format kode**

Run: `dart format lib test`
Expected: semua file Dart terformat.

- [ ] **Step 2: Jalankan analyzer**

Run: `flutter analyze`
Expected: `No issues found!`.

- [ ] **Step 3: Jalankan seluruh test**

Run: `flutter test`
Expected: seluruh test PASS; jika sandbox menolak socket lokal, laporkan batasan tersebut dan tetap sertakan hasil analyzer serta test murni yang dapat dijalankan.

- [ ] **Step 4: Commit dan push**

```bash
git add pubspec.yaml pubspec.lock lib/models/energy_usage.dart \
  lib/services/daily_energy_store.dart lib/screens/home_shell.dart \
  lib/screens/control_screen.dart lib/main.dart test docs/superpowers/plans
git commit -m "feat: add personal header and daily energy tracking"
git push origin main
```

