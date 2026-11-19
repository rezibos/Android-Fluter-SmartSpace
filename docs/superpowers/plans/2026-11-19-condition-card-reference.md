# Condition Card Reference Implementation Plan

**Goal:** Menyesuaikan panel Kondisi Ruangan dengan referensi dan menampilkan fallback dummy saat ESP32 offline.

1. Gunakan suhu 26.6, kelembapan 78, gas aman, hujan tidak, dan tanah normal ketika snapshot kosong.
2. Tampilkan label Demo ketika memakai fallback.
3. Hilangkan indikator minus/plus atau kontrol samping.
4. Pertahankan empat tombol sensor di footer dan callback Grafik.
5. Format dan analyze sebelum commit.

