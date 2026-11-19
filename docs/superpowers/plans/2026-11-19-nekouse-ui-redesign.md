# Nekouse UI Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Mengganti dashboard biru satu halaman menjadi aplikasi Nekouse bertema monokrom/oranye dengan tiga tab nyata, layar detail, dan integrasi ESP32 yang tetap berfungsi.

**Architecture:** `SmartSpaceController` pada `HomeShell` memegang state dan polling, sedangkan `Esp32Service` menangani HTTP serta parsing. Screen dan widget bersifat presentasional: menerima model dan callback, sehingga endpoint jaringan tidak tersebar di UI.

**Tech Stack:** Flutter 3, Dart 3.13, Material 3, package `http`, `flutter_test`, `CustomPainter` untuk grafik.

## Global Constraints

- Pertahankan endpoint `GET /sensor`, `GET /lampu`, dan `GET /relay`.
- Polling setiap 2 detik dengan timeout 3 detik dan tanpa request polling tumpang tindih.
- Kecerahan lampu berada pada rentang 10–100 dan dikirim ketika slider dilepas.
- Tema default Monokrom; tema kedua Oranye; merah `#E5484D` hanya untuk bahaya.
- Status perangkat dari polling ESP32 menjadi sumber kebenaran akhir.
- Tidak menambahkan klaim backend, autentikasi, FCM, penyimpanan cloud, atau buzzer firmware.
- Tata letak mendukung lebar 360–430 dp, target sentuh minimal 48 dp, serta font sistem besar.

---

### Task 1: Models, classification, and ESP32 service

**Files:**
- Create: `lib/models/room_light.dart`
- Create: `lib/models/sensor_snapshot.dart`
- Create: `lib/services/esp32_service.dart`
- Create: `test/models/sensor_snapshot_test.dart`

**Interfaces:**
- Produces: `RoomLight`, `SensorSnapshot.fromJson(Map<String, dynamic>)`, `SoilState`, `Esp32Service.fetchSensor()`, `setLight()`, dan `setRelay()`.

- [ ] **Step 1: Write failing parsing and classification tests**

```dart
test('parses ESP32 payload and classifies thresholds', () {
  final snapshot = SensorSnapshot.fromJson({
    'suhu': 28.5, 'udara': 65, 'tanah': 3100, 'hujan': 2400,
    'gas': 480, 'kamar': 1, 'tengah': 0, 'dapur': 1,
    'depan': 0, 'relay': 1,
  });
  expect(snapshot.temperature, 28.5);
  expect(snapshot.isRaining, isTrue);
  expect(snapshot.isGasDanger(400), isTrue);
  expect(snapshot.soilState, SoilState.dry);
});
```

- [ ] **Step 2: Run the focused test and verify RED**

Run: `flutter test test/models/sensor_snapshot_test.dart`
Expected: FAIL because `SensorSnapshot` does not exist.

- [ ] **Step 3: Implement immutable models and validated HTTP methods**

`fetchSensor` parses only numeric values and throws `Esp32Exception` for non-200 or invalid JSON. `setLight` accepts only the four room IDs plus `semua`, while brightness is clamped to 10–100. `setRelay` sends `status=1|0`.

- [ ] **Step 4: Run focused tests and analyzer**

Run: `flutter test test/models/sensor_snapshot_test.dart && flutter analyze`
Expected: PASS and no analyzer errors.

- [ ] **Step 5: Commit**

```bash
git add lib/models lib/services test/models
git commit -m "feat: add Smart Space sensor models and ESP32 service"
```

### Task 2: Theme and reusable Nekouse components

**Files:**
- Create: `lib/theme/space_theme.dart`
- Create: `lib/widgets/space_toggle.dart`
- Create: `lib/widgets/device_card.dart`
- Create: `lib/widgets/sensor_card.dart`
- Create: `lib/widgets/alarm_banner.dart`
- Create: `lib/widgets/space_bottom_nav.dart`
- Create: `test/widgets/design_system_test.dart`

**Interfaces:**
- Consumes: `RoomLight`, `SoilState`.
- Produces: `SpacePalette`, `SpaceTheme.monochrome()`, `SpaceTheme.orange()`, and reusable widgets with semantic labels.

- [ ] **Step 1: Write failing widget tests for tokens and states**

```dart
testWidgets('active device card shows status and accessible toggle', (tester) async {
  await tester.pumpWidget(testHost(
    DeviceCard(name: 'Kamar', icon: Icons.bed_outlined,
      isOn: true, brightness: 70, onToggle: (_) {}, onTap: () {}),
  ));
  expect(find.text('Aktif • 70%'), findsOneWidget);
  expect(find.bySemanticsLabel('Lampu Kamar, aktif 70 persen'), findsOneWidget);
});
```

- [ ] **Step 2: Run the focused test and verify RED**

Run: `flutter test test/widgets/design_system_test.dart`
Expected: FAIL because the widgets do not exist.

- [ ] **Step 3: Implement theme tokens and components**

Use card radius 24/28, page margin 20, inactive border `#E5E5E7`, active background from the selected palette, pill toggle 56×32, and danger banner with icon plus safety copy.

- [ ] **Step 4: Run widget tests**

Run: `flutter test test/widgets/design_system_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/theme lib/widgets test/widgets
git commit -m "feat: add Nekouse theme and reusable UI components"
```

### Task 3: Home shell, polling, and three real tabs

**Files:**
- Create: `lib/screens/home_shell.dart`
- Create: `lib/screens/control_screen.dart`
- Create: `lib/screens/sensor_screen.dart`
- Create: `lib/screens/settings_screen.dart`
- Replace: `lib/main.dart`
- Create: `test/screens/home_shell_test.dart`

**Interfaces:**
- Consumes: model, service, theme, and widget interfaces from Tasks 1–2.
- Produces: `HomeShell(service: Esp32Service)` with tabs Kontrol, Grafik, Pengaturan and injectable service for tests.

- [ ] **Step 1: Write failing navigation test**

```dart
testWidgets('bottom navigation switches between three real screens', (tester) async {
  await tester.pumpWidget(NekouseApp(service: FakeEsp32Service()));
  expect(find.text('Perangkat'), findsOneWidget);
  await tester.tap(find.text('Grafik'));
  await tester.pumpAndSettle();
  expect(find.text('Grafik Sensor'), findsOneWidget);
  await tester.tap(find.text('Pengaturan'));
  await tester.pumpAndSettle();
  expect(find.text('Keamanan Sensor'), findsOneWidget);
});
```

- [ ] **Step 2: Run the focused test and verify RED**

Run: `flutter test test/screens/home_shell_test.dart`
Expected: FAIL because `NekouseApp` and screens do not exist.

- [ ] **Step 3: Implement shell and polling lifecycle**

Start polling in `initState`, cancel it in `dispose`, skip ticks while `_pollInFlight` is true, retain the last snapshot on failure, and expose `lastUpdated`. Disable controls while offline. Implement the exact content order from the approved design specification.

- [ ] **Step 4: Implement settings interactions**

The IP dialog validates IPv4/hostname text, tests `/sensor`, and applies the new base URL only after a successful response. Gas threshold and notification/buzzer switches remain local preferences and are labeled as such.

- [ ] **Step 5: Run tests and analyzer**

Run: `flutter test test/screens/home_shell_test.dart && flutter analyze`
Expected: PASS and no analyzer errors.

- [ ] **Step 6: Commit**

```bash
git add lib/main.dart lib/screens test/screens
git commit -m "feat: build Nekouse control sensor and settings screens"
```

### Task 4: Detail, notification, and profile routes

**Files:**
- Create: `lib/screens/light_detail_screen.dart`
- Create: `lib/screens/pump_detail_screen.dart`
- Create: `lib/screens/notifications_screen.dart`
- Create: `lib/screens/profile_screen.dart`
- Modify: `lib/screens/control_screen.dart`
- Modify: `lib/screens/settings_screen.dart`
- Create: `test/screens/detail_routes_test.dart`

**Interfaces:**
- Consumes: callbacks provided by `HomeShell`.
- Produces: detail route results containing updated brightness/profile preferences without direct HTTP access.

- [ ] **Step 1: Write failing route tests**

```dart
testWidgets('tapping a lamp card opens its brightness detail', (tester) async {
  await tester.pumpWidget(NekouseApp(service: FakeEsp32Service()));
  await tester.tap(find.text('Kamar'));
  await tester.pumpAndSettle();
  expect(find.text('Kecerahan'), findsOneWidget);
  expect(find.byType(Slider), findsOneWidget);
});
```

- [ ] **Step 2: Run the focused test and verify RED**

Run: `flutter test test/screens/detail_routes_test.dart`
Expected: FAIL because detail routes do not exist.

- [ ] **Step 3: Implement routes and callback-only interactions**

Detail Lampu sends brightness only through `onChangeEnd`; Detail Pompa hides active-LOW terminology; Notifikasi groups local events; Profil edits local display data and does not claim server persistence.

- [ ] **Step 4: Run route tests**

Run: `flutter test test/screens/detail_routes_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/screens test/screens/detail_routes_test.dart
git commit -m "feat: add Nekouse detail notification and profile flows"
```

### Task 5: Failure rollback, responsive QA, and final verification

**Files:**
- Modify: `lib/screens/home_shell.dart`
- Modify: `lib/screens/control_screen.dart`
- Modify: `lib/screens/sensor_screen.dart`
- Modify: `test/screens/home_shell_test.dart`
- Modify: `README.md`

**Interfaces:**
- Consumes all previous tasks.
- Produces the release-ready application and setup instructions.

- [ ] **Step 1: Add failing rollback and offline tests**

```dart
testWidgets('failed light command rolls back and explains the failure', (tester) async {
  await tester.pumpWidget(NekouseApp(service: FailingCommandService()));
  await tester.tap(find.bySemanticsLabel('Lampu Kamar, mati'));
  await tester.pump();
  expect(find.text('Gagal mengirim perintah. Coba lagi.'), findsOneWidget);
});
```

- [ ] **Step 2: Implement rollback and offline presentation**

Store the previous device state before each optimistic update, restore it on exception, show the required snackbar, retain old sensor values, and label them with the last update time.

- [ ] **Step 3: Run formatter and complete verification**

Run: `dart format lib test && flutter analyze && flutter test && flutter build apk --debug`
Expected: formatter succeeds, analyzer has no errors, all tests pass, and debug APK is built.

- [ ] **Step 4: Update README with actual run instructions**

Document `flutter pub get`, `flutter run`, where to change/test the hub IP, required same-Wi-Fi condition, and the three ESP32 endpoints.

- [ ] **Step 5: Commit**

```bash
git add lib test README.md
git commit -m "test: verify responsive Smart Space device controls"
```

