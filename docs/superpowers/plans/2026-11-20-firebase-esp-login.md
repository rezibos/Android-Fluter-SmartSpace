# Firebase ESP32 Login Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Menambahkan login Firebase email/password yang juga mewajibkan koneksi ESP32, menyimpan sesi dan IP, serta menjalankan animasi logo sebelum membuka halaman Kontrol.

**Architecture:** `AuthService` mengisolasi Firebase Authentication Android melalui platform channel, `HostStore` menyimpan IP melalui platform channel, dan `AuthGate` mengorkestrasi startup/login/logout. `LoginScreen` hanya menangani form, status, pesan, dan animasi; `Esp32Service` tetap menjadi satu-satunya jalur pengujian hub.

**Tech Stack:** Flutter 3, Dart 3.13+, Firebase Android BoM 35.2.0, Firebase Auth Android, Kotlin, Android SharedPreferences, Material 3, flutter_test.

## Global Constraints

- Login hanya berhasil jika Firebase Authentication dan `Esp32Service.fetchSensor()` sama-sama berhasil.
- Akun dibuat manual di Firebase Console; tidak ada pendaftaran akun di aplikasi.
- Password tidak disimpan, dicatat, atau dikirim ke ESP32.
- IP tersimpan dan sesi Firebase dipakai untuk melewati Login pada startup berikutnya.
- Jika ESP32 gagal setelah Firebase login, host dikembalikan, Firebase sign out dijalankan, dan pengguna tetap di Login.
- Logo sukses membesar tanpa rotasi/bounce selama total 700–900 ms; Reduce Motion memakai fade singkat.
- `google-services.json` tidak dibuat palsu dan tidak dimasukkan sebelum pengguna mengunduhnya dari Firebase Console.
- Android application ID tetap `com.example.witdget`.

---

### Task 1: Firebase dan Konfigurasi Android

**Files:**
- Modify: `android/settings.gradle.kts`
- Modify: `android/app/build.gradle.kts`
- Modify: `android/app/src/main/kotlin/com/example/witdget/MainActivity.kt`
- Create: `docs/FIREBASE_SETUP.md`

**Interfaces:**
- Produces: Firebase Auth tersedia melalui channel `nekouse/firebase_auth` dan Google Services plugin 4.6.0 tersedia untuk Android.
- Konfigurasi aplikasi tetap dapat menampilkan pesan setup saat Firebase belum siap.

- [ ] **Step 1: Tambahkan dependency Android resmi**

```kotlin
dependencies {
    implementation(platform("com.google.firebase:firebase-bom:35.2.0"))
    implementation("com.google.firebase:firebase-auth")
}
```

Pendekatan native dipakai karena sandbox tidak dapat mengunduh paket FlutterFire dari pub.dev. Autentikasi tetap menggunakan Firebase Authentication SDK resmi.

- [ ] **Step 2: Tambahkan Google Services plugin**

Pada `android/settings.gradle.kts`:

```kotlin
plugins {
    id("com.google.gms.google-services") version "4.6.0" apply false
}
```

Pada `android/app/build.gradle.kts`, apply hanya ketika file konfigurasi ada agar checkout belum terkonfigurasi masih dapat dianalisis:

```kotlin
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}
```

Set `minSdk = 24` sesuai prasyarat Android Firebase Flutter terbaru.

- [ ] **Step 3: Dokumentasikan setup pengguna**

`docs/FIREBASE_SETUP.md` harus berisi langkah konkret:

1. Buat Firebase project.
2. Daftarkan Android app `com.example.witdget`.
3. Unduh `google-services.json` ke `android/app/google-services.json`.
4. Aktifkan Authentication > Sign-in method > Email/Password.
5. Buat user manual pada Authentication > Users.
6. Jalankan `flutterfire configure` dan `flutter run`.

Cantumkan tautan resmi Firebase Flutter setup dan password authentication.

### Task 2: Aset Logo Login

**Files:**
- Create: `assets/branding/nekouse_login.png`
- Modify: `pubspec.yaml`

**Interfaces:**
- Produces: PNG transparan logo kucing merah yang dapat dirender oleh `Image.asset`.

- [ ] **Step 1: Bersihkan aset referensi dengan image generation**

Gunakan gambar pengguna `/tmp/codex-clipboard-bnNTPY.png` sebagai referensi. Hapus latar putih, pertahankan bentuk/mata/kumis dan warna merah, tanpa menambah teks atau elemen baru. Simpan hasil transparan sebagai `assets/branding/nekouse_login.png`.

- [ ] **Step 2: Daftarkan aset**

```yaml
flutter:
  assets:
    - assets/branding/
    - assets/devices/
```

- [ ] **Step 3: Verifikasi file**

Run: `file assets/branding/nekouse_login.png`
Expected: PNG RGBA dengan alpha channel.

### Task 3: Abstraksi Firebase Authentication

**Files:**
- Create: `lib/services/auth_service.dart`
- Create: `test/services/auth_service_test.dart`

**Interfaces:**
- Produces: `AuthService.isSignedIn`, `signIn(email, password)`, `signOut()`, `AuthFailure`, `FirebaseAuthService`, dan `MemoryAuthService`.

- [ ] **Step 1: Tulis test pemetaan error**

```dart
expect(AuthFailure.messageForCode('invalid-credential'),
  'Email atau password tidak sesuai.');
expect(AuthFailure.messageForCode('too-many-requests'),
  'Terlalu banyak percobaan. Coba lagi nanti.');
expect(AuthFailure.messageForCode('network-request-failed'),
  'Tidak dapat menghubungi layanan login.');
```

- [ ] **Step 2: Implementasikan kontrak dan adapter Firebase**

```dart
abstract class AuthService {
  bool get isSignedIn;
  Future<void> signIn({required String email, required String password});
  Future<void> signOut();
}

class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;
  static String messageForCode(String code) => switch (code) {
    'invalid-credential' || 'user-not-found' || 'wrong-password' =>
      'Email atau password tidak sesuai.',
    'too-many-requests' => 'Terlalu banyak percobaan. Coba lagi nanti.',
    'network-request-failed' => 'Tidak dapat menghubungi layanan login.',
    _ => 'Login tidak dapat diproses. Coba lagi.',
  };
}
```

`PlatformAuthService` memakai channel `nekouse/firebase_auth`; implementasi Kotlin membungkus `FirebaseAuth.getInstance()`, memetakan exception menjadi kode aman, dan tidak mencatat kredensial. `MemoryAuthService` menyediakan hasil deterministik untuk test.

- [ ] **Step 3: Jalankan test**

Run: `flutter test test/services/auth_service_test.dart`
Expected: semua pemetaan pesan dan state memory service PASS.

### Task 4: Penyimpanan Host ESP32

**Files:**
- Create: `lib/services/host_store.dart`
- Modify: `android/app/src/main/kotlin/com/example/witdget/MainActivity.kt`
- Create: `test/services/host_store_test.dart`

**Interfaces:**
- Produces: `HostStore.load()`, `save(host)`, `clear()`, `PlatformHostStore`, dan `MemoryHostStore`.
- Channel Android: `nekouse/app_settings` dengan method `loadHost`, `saveHost`, `clearHost`.

- [ ] **Step 1: Tulis test memory store**

```dart
final store = MemoryHostStore();
expect(await store.load(), isNull);
await store.save('192.168.1.10');
expect(await store.load(), '192.168.1.10');
await store.clear();
expect(await store.load(), isNull);
```

- [ ] **Step 2: Implementasikan Dart store**

Gunakan `MethodChannel('nekouse/app_settings')`; nilai host saja yang disimpan, tidak ada email/password/token.

- [ ] **Step 3: Implementasikan Kotlin SharedPreferences**

Gunakan preference file `nekouse_settings`, key `esp32_host`, dan tangani ketiga method secara eksplisit.

- [ ] **Step 4: Jalankan test**

Run: `flutter test test/services/host_store_test.dart`
Expected: load/save/clear PASS.

### Task 5: Validasi Form Login

**Files:**
- Create: `lib/models/login_input.dart`
- Create: `test/models/login_input_test.dart`

**Interfaces:**
- Produces: `LoginInput.validateHost`, `validateEmail`, dan `validatePassword`, masing-masing mengembalikan `String?`.

- [ ] **Step 1: Tulis test input valid dan berbahaya**

```dart
expect(LoginInput.validateHost('192.168.1.10'), isNull);
expect(LoginInput.validateHost('esp32.local'), isNull);
expect(LoginInput.validateHost('http://192.168.1.10/path'), isNotNull);
expect(LoginInput.validateEmail('user@example.com'), isNull);
expect(LoginInput.validateEmail('user'), isNotNull);
expect(LoginInput.validatePassword(''), isNotNull);
```

- [ ] **Step 2: Implementasikan validator**

Host menggunakan `RegExp(r'^[a-zA-Z0-9.-]+$')`, email menggunakan pola sederhana yang mewajibkan karakter sebelum/sesudah `@` dan titik domain, password hanya wajib tidak kosong.

- [ ] **Step 3: Jalankan test**

Run: `flutter test test/models/login_input_test.dart`
Expected: seluruh kasus validasi PASS.

### Task 6: AuthGate dan Alur Login

**Files:**
- Create: `lib/screens/auth_gate.dart`
- Modify: `lib/main.dart`
- Modify: `lib/screens/home_shell.dart`
- Test: `test/widget_test.dart`

**Interfaces:**
- Consumes: `AuthService`, `HostStore`, `Esp32Service`, `DailyEnergyStore`.
- Produces: startup gate, `Future<String?> login(...)`, dan `Future<void> logout()`.

- [ ] **Step 1: Ubah main menjadi inisialisasi Firebase yang aman**

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseReady = false;
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (_) {}
  runApp(NekouseApp(firebaseReady: firebaseReady));
}
```

`NekouseApp` menerima service injection untuk test dan menggunakan `AuthGate` sebagai `home`.

- [ ] **Step 2: Implementasikan startup gate**

Jika Firebase siap, user signed in, dan host tersimpan tersedia, set host lalu panggil `fetchSensor()`. Hanya hasil sukses yang membuka `HomeShell`; kegagalan menampilkan Login dengan host prefilled.

- [ ] **Step 3: Implementasikan transaksi login**

Urutan wajib:

```dart
await authService.signIn(email: email, password: password);
final previousHost = esp32Service.host;
esp32Service.updateHost(host);
try {
  await esp32Service.fetchSensor();
  await hostStore.save(host);
  return null;
} catch (_) {
  esp32Service.updateHost(previousHost);
  await authService.signOut();
  return 'Login berhasil, tetapi hub ESP32 tidak dapat dihubungi.';
}
```

- [ ] **Step 4: Implementasikan logout**

Sign out Firebase, clear host, buat instance ESP32 baru setelah HomeShell lama dibuang, dan tampilkan Login.

- [ ] **Step 5: Ubah kepemilikan service dengan aman**

`HomeShell` menerima callback `onLogout`. Pastikan service yang sedang dipakai ditutup tepat sekali ketika keluar/dispose dan tidak dipakai lagi oleh Login berikutnya.

### Task 7: UI dan Animasi Login

**Files:**
- Create: `lib/screens/login_screen.dart`
- Modify: `test/widget_test.dart`

**Interfaces:**
- Consumes: `initialHost`, `firebaseReady`, `onLogin`, dan `onAuthenticated`.
- Produces: form tiga input, loading/error, serta animasi sukses 800 ms.

- [ ] **Step 1: Tulis widget expectations**

```dart
expect(find.text('IP ESP32'), findsOneWidget);
expect(find.text('Email'), findsOneWidget);
expect(find.text('Password'), findsOneWidget);
expect(find.widgetWithText(FilledButton, 'Masuk'), findsOneWidget);
```

- [ ] **Step 2: Bangun form responsif**

Gunakan `SafeArea > SingleChildScrollView > ConstrainedBox`, `Form`, tiga `TextFormField`, password visibility toggle, dan `FilledButton` tinggi minimal 52 dp. Logo memakai `assets/branding/nekouse_login.png`.

- [ ] **Step 3: Implementasikan animasi sukses**

Gunakan satu `AnimationController(duration: 800ms)`:

- opacity form: interval 0.0–0.3;
- alignment logo ke tengah: interval 0.0–0.55;
- scale logo 1.0 ke 4.5: interval 0.25–1.0;
- background ivory ke maroon: interval 0.15–1.0;
- setelah selesai panggil `onAuthenticated` dan tampilkan HomeShell dengan `AnimatedSwitcher` fade.

Gunakan `MediaQuery.disableAnimations`; jika true, durasi 120 ms dan hanya fade.

- [ ] **Step 4: Implementasikan pesan aman**

Tampilkan satu error banner inline. Saat `firebaseReady == false`, banner berisi `Firebase belum dikonfigurasi pada aplikasi ini.` dan tombol Masuk dinonaktifkan.

- [ ] **Step 5: Jalankan widget tests**

Run: `flutter test test/widget_test.dart`
Expected: validasi, loading, error, sukses, dan perpindahan gate PASS.

### Task 8: Logout dari Profil

**Files:**
- Modify: `lib/screens/detail_screens.dart`
- Modify: `lib/screens/settings_screen.dart`
- Modify: `lib/screens/home_shell.dart`
- Test: `test/widget_test.dart`

**Interfaces:**
- Consumes: `VoidCallback/Future<void> onLogout` dari AuthGate.
- Produces: aksi `Keluar` yang meminta konfirmasi dan kembali ke Login.

- [ ] **Step 1: Tambahkan callback logout**

Teruskan callback ke Settings dan Profile tanpa membuat Firebase call langsung di widget tersebut.

- [ ] **Step 2: Tambahkan aksi Keluar**

Gunakan `ListTile`/tombol dengan ikon logout dan warna danger. Dialog konfirmasi berisi `Batal` dan `Keluar`; hanya konfirmasi yang memanggil callback.

- [ ] **Step 3: Uji alur logout**

Pastikan fake auth berubah menjadi signed out, fake host menjadi null, dan Login kembali tampil.

### Task 9: Verifikasi dan Pengiriman

**Files:**
- Review seluruh file Task 1–8.

**Interfaces:**
- Produces: implementasi terformat, dianalisis, terdokumentasi, dan dipush.

- [ ] **Step 1: Format**

Run: `dart format lib test`
Expected: tidak ada file yang gagal diparse.

- [ ] **Step 2: Analyzer**

Run: `flutter analyze`
Expected: `No issues found!` setelah dependency berhasil diunduh.

- [ ] **Step 3: Test**

Run: `flutter test`
Expected: seluruh test PASS. Jika sandbox melarang bind socket lokal, catat batasan tersebut tanpa mengklaim test lulus.

- [ ] **Step 4: Build Android**

Dengan `android/app/google-services.json` yang valid:

Run: `flutter build apk --debug`
Expected: APK debug berhasil dibuat. Tanpa file tersebut, verifikasi pesan setup dan conditional Gradle path.

- [ ] **Step 5: Commit dan push**

```bash
git add pubspec.yaml pubspec.lock android lib assets test docs
git commit -m "feat: add Firebase and ESP32 login flow"
git push origin main
```

