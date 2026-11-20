# Desain Grid Perangkat dengan Gambar Produk

Tanggal: 19 November 2026
Status: Menunggu tinjauan pengguna

## Cakupan

Hanya panel Perangkat pada halaman Kontrol yang berubah. Panel Kondisi Ruangan, header, filter, navbar, halaman lain, dan integrasi ESP32 tetap.

## Header Panel

- Header menampilkan judul `Perangkat` di kiri.
- Tombol tiga titik berada di kanan.
- Teks jumlah lampu aktif dihapus.

## Grid

- Grid dua kolom berisi lima kartu:
  1. Tengah.
  2. Kamar.
  3. Dapur.
  4. Depan.
  5. Pompa.
- Nama ruangan menggunakan versi singkat di atas.
- Kartu keenam tidak dibuat; kartu Pompa pada baris terakhir tetap mengambil satu kolom seperti referensi.
- Kartu pompa lebar lama dihapus.

## Kartu Lampu

- Surface putih, radius 22–24 dp.
- Nama singkat dan status berada di kiri atas.
- Gambar produk lampu transparan mengisi bagian kanan/tengah.
- Toggle berada di kiri bawah.
- Persentase kecerahan berada di kanan bawah.
- Ketuk kartu tetap membuka Detail Lampu.
- Toggle tetap mengirim perintah ESP32.

## Kartu Pompa

- Menggunakan struktur visual yang sama dengan kartu lampu.
- Nama `Pompa`, status Aktif/Nonaktif, gambar pompa transparan, dan toggle.
- Tidak menampilkan persen kecerahan.
- Ketuk kartu membuka Detail Pompa.

## Aset Gambar

- Dibuat lima aset PNG transparan: empat variasi lampu dan satu pompa.
- Gaya: product render minimal, pencahayaan studio lembut, warna maroon–gold–ivory, tanpa teks, logo, background, atau watermark.
- Disimpan di `assets/devices/` dan didaftarkan pada `pubspec.yaml`.
- Gambar harus tetap terbaca pada ukuran kartu kecil.

## Penghapusan

- Footer panel berisi tambah, power, estimasi watt, dan chevron dihapus.
- Kartu Pompa lebar di bawah grid dihapus.
- Ringkasan `0 dari 4 lampu aktif` pada header panel dihapus.

## Verifikasi

- Semua lima gambar termuat tanpa error asset.
- Grid aman pada lebar 360–430 dp.
- Nama tidak terpotong.
- Toggle lampu dan pompa tetap berfungsi.
- Analyzer tanpa masalah.

