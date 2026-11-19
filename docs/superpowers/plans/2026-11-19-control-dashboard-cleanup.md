# Control Dashboard Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Menyederhanakan halaman Kontrol tanpa mengurangi fungsi perangkat.

**Architecture:** Hanya widget presentasional dalam `ControlScreen` yang berubah. Data dan callback dari `HomeShell` dipertahankan.

## Tasks

1. Ringkas hero dan gabungkan jumlah lampu, pompa, serta estimasi watt.
2. Ganti carousel sensor dengan panel grid 2×2 tanpa scroll.
3. Hapus kartu penggunaan terpisah dan tombol Sensor yang duplikat.
4. Ringkas filter ruangan menjadi chip horizontal 48 dp.
5. Hapus tombol Matikan Semua yang duplikat setelah Pompa.
6. Format, analyze, dan jalankan test bila sandbox mengizinkan.

