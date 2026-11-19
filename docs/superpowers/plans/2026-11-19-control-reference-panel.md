# Control Reference Panel Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Membangun ulang halaman Kontrol dengan dua panel besar seperti referensi tanpa mengubah integrasi ESP32.

**Architecture:** `ControlScreen` tetap stateless dan menerima snapshot, perangkat, serta callback dari `HomeShell`. Satu callback tambahan membuka tab Listrik.

## Tasks

1. Ganti header dan filter ruangan dengan layout ringkas.
2. Bangun panel Kondisi Ruangan dari snapshot asli.
3. Bangun panel Perangkat berisi grid lampu, pompa, aksi massal, dan estimasi daya.
4. Hubungkan `onViewElectricity` ke indeks tab Listrik pada `HomeShell`.
5. Update widget test, format, analyze, dan test jika sandbox mengizinkan.

