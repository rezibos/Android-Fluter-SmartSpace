# Desain Halaman Kontrol Berbasis Panel Referensi

Tanggal: 19 November 2026
Status: Menunggu tinjauan pengguna

## Cakupan

Hanya halaman Kontrol yang dirombak. Halaman Grafik, Nekouse, Listrik, Profil, navbar, tema maroon–ivory–gold, service ESP32, polling, dan callback perangkat tetap seperti sekarang.

Referensi dipakai untuk struktur, proporsi, dan pengelompokan. Produk AC dan speaker pada referensi tidak disalin; komponennya diganti dengan sensor, lampu, dan pompa Smart Space.

## Susunan Halaman

1. Header sapaan ringkas.
2. Filter ruangan berbentuk ikon horizontal.
3. Panel besar Kondisi Ruangan.
4. Panel besar Perangkat.
5. Navbar yang sudah ada.

## Header

- Baris kecil: sapaan berdasarkan waktu dan nama `Willy`.
- Judul besar: `Rumah Smart Space`.
- Sisi kanan: tombol notifikasi dan profil dalam kapsul putih.
- Logo besar Nekouse di header dihilangkan dari halaman Kontrol agar komposisinya menyerupai referensi; identitas Nekouse tetap tersedia pada tab khusus.

## Filter Ruangan

- Satu baris berisi tombol tambah/sambung hub, Semua, Tengah, Kamar, Dapur, dan Depan.
- Chip Semua aktif memakai maroon.
- Ruangan lain hanya ikon dengan label singkat atau tooltip.
- Tinggi baris 48–52 dp dan dapat digeser horizontal pada layar kecil.

## Panel Kondisi Ruangan

- Panel warm muted beradius 28–32 dp tanpa border berat.
- Header panel: `Kondisi Ruangan`, status hub, dan indikator alarm gas.
- Pusat panel menampilkan suhu besar, kelembapan di atasnya, serta satuan derajat.
- Tombol minus/plus pada referensi tidak dipakai karena suhu hanya dipantau, bukan dikontrol.
- Posisinya diganti dua indikator bulat: status Hujan dan status Tanah.
- Empat tombol kecil pada footer panel:
  - Udara.
  - Gas.
  - Hujan.
  - Tanah.
- Mengetuk footer sensor membuka tab Grafik.
- Gas bahaya tetap memakai merah, bukan maroon.
- Saat belum ada data, angka utama dan nilai sensor memakai `—`.

## Panel Perangkat

- Satu panel warm muted beradius 28–32 dp.
- Grid dua kolom untuk empat lampu.
- Setiap kartu lampu berada di dalam panel, memakai surface putih, dan berisi:
  - Nama ruangan.
  - Ikon perangkat berukuran besar.
  - Status Aktif/Mati.
  - Toggle.
  - Persen kecerahan.
- Kartu aktif memakai aksen maroon pada toggle/ikon, bukan seluruh kartu menjadi maroon, agar menyerupai referensi.
- Ketuk kartu tetap membuka Detail Lampu.

## Pompa dan Footer Perangkat

- Pompa ditampilkan sebagai baris kartu lebar di bawah grid lampu dalam panel yang sama.
- Footer panel memiliki:
  - Semua Nyala.
  - Semua Mati.
  - Estimasi watt.
  - Chevron menuju halaman Listrik.
- Seluruh kontrol dinonaktifkan dengan tampilan yang tetap terbaca saat hub offline.

## Penghapusan Komponen Lama

- Hero maroon besar dihapus.
- Carousel Kondisi Rumah dihapus.
- Kartu Penggunaan Saat Ini terpisah dihapus.
- Tiga kartu Aksi Cepat terpisah dihapus.
- Section Perangkat dan Pompa yang berdiri sendiri digabung ke panel Perangkat.
- Tombol Matikan Semua yang duplikat dihapus.

## Responsif

- Panel memakai margin horizontal 16–20 dp.
- Layout aman pada lebar 360–430 dp.
- Grid perangkat tidak boleh overflow pada font sistem besar.
- Padding bawah minimal 112 dp agar panel tidak tertutup navbar.

## Verifikasi

- Analyzer tanpa masalah.
- Semua callback lampu, kecerahan, pompa, semua nyala/mati, Grafik, dan Listrik tetap terhubung.
- Tidak ada kartu horizontal yang terpotong pada sisi kiri.
- Data offline memakai `—` dan kontrol disabled secara jelas.

