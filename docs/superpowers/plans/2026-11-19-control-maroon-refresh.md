# Control Maroon Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Mempertahankan seluruh fitur halaman Kontrol saat ini sambil memperbaiki posisi header/navbar dan menerapkan palet maroon–ivory–gold.

**Architecture:** Tidak ada perubahan pada model, service ESP32, polling, atau callback kontrol. Perubahan dibatasi pada theme tokens, komposisi presentasional `ControlScreen`, `DeviceCard`, serta layout bottom navigation dalam `HomeShell`.

**Tech Stack:** Flutter Material 3, Dart, flutter_test.

## Global Constraints

- Jangan menghapus fitur beranda yang sudah ada.
- Jangan mengubah endpoint `/sensor`, `/lampu`, atau `/relay`.
- Default palette: maroon `#7A1F35`, ivory `#FFF8F2`, gold `#C89B5B`.
- Header aman dari status bar dan navbar tidak menutupi konten.
- Alarm tetap menggunakan merah `#E5484D`.

---

### Task 1: Maroon theme tokens

**Files:**
- Modify: `lib/theme/space_theme.dart`
- Test: `test/widget_test.dart`

**Interfaces:**
- Produces: default `SpacePalette` with maroon active color and gold accent.

- [ ] Add a test asserting the default theme uses `Color(0xFF7A1F35)`.
- [ ] Run the test to confirm RED against the monochrome palette.
- [ ] Replace default theme values and add `accent` to `SpacePalette`.
- [ ] Run analyzer and test where the environment permits.

### Task 2: Preserve and reposition Control content

**Files:**
- Modify: `lib/screens/control_screen.dart`
- Modify: `lib/widgets/space_widgets.dart`

**Interfaces:**
- Consumes existing callbacks and data without signature changes.
- Produces: safe header, maroon hero, icon room chips, refreshed cards and pump section.

- [ ] Wrap top content in `SliverSafeArea` and add 14–18 dp visual spacing.
- [ ] Keep header, connection state, greeting, room chips, devices, pump, and all-lights action.
- [ ] Combine greeting and connection state inside the hero without removing retry behavior.
- [ ] Restyle active/inactive cards and room chips using maroon/ivory/gold.
- [ ] Run analyzer.

### Task 3: Restore proportional floating navbar

**Files:**
- Modify: `lib/screens/home_shell.dart`
- Test: `test/widget_test.dart`

**Interfaces:**
- Keeps the four existing destinations and `_tab` behavior.

- [ ] Reduce container height to 64 dp with a full pill radius.
- [ ] Give the active tab intrinsic width and inactive tabs 48 dp touch targets.
- [ ] Preserve Kontrol, Grafik, Listrik, and Profil navigation.
- [ ] Run formatter, analyzer, tests, and build where permitted.

