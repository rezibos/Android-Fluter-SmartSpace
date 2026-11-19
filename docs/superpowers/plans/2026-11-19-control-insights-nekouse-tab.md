# Control Insights and Nekouse Tab Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Menambahkan Kondisi Rumah, ringkasan penggunaan, quick actions, dan tab Nekouse tanpa mengubah integrasi ESP32.

**Architecture:** `ControlScreen` tetap presentasional dan menerima callback baru untuk membuka Grafik. `NekouseScreen` menerima snapshot/status dari `HomeShell`. Daftar screen dan navbar diperluas menjadi lima indeks.

**Tech Stack:** Flutter Material 3, Dart, flutter_test.

## Tasks

### Task 1: Control insights

- Modify `lib/screens/control_screen.dart`.
- Tambahkan `onViewSensors`.
- Render empat nilai sensor dari `SensorSnapshot`, estimasi daya, dan tiga quick actions.
- Pertahankan semua kontrol perangkat yang ada.

### Task 2: Nekouse screen

- Create `lib/screens/nekouse_screen.dart`.
- Render maskot Flutter lokal, status dinamis, ringkasan sensor/perangkat, dan dua callback navigasi.
- Jangan menampilkan nilai contoh ketika snapshot kosong.

### Task 3: Five-destination navbar

- Modify `lib/screens/home_shell.dart`.
- Urutan: Kontrol, Grafik, Nekouse, Listrik, Profil.
- Tombol Nekouse berbentuk lingkaran maroon terangkat di tengah.
- Pertahankan target sentuh dan hindari overflow pada 360 dp.

### Task 4: Verification

- Update `test/widget_test.dart` untuk tab Nekouse.
- Run `dart format lib test`.
- Run `flutter analyze`.
- Run widget tests/build bila socket sandbox mengizinkan.

