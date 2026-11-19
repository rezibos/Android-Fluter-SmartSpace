# Desain Pembersihan Dashboard Kontrol

Tanggal: 19 November 2026
Status: Disetujui secara visual, menunggu tinjauan spesifikasi

## Masalah yang Diperbaiki

- Carousel Kondisi Rumah terpotong pada sisi kiri.
- Terlalu banyak kartu dengan radius dan bobot visual serupa.
- Hero terlalu tinggi dan dominan.
- Penggunaan daya mengambil satu kartu penuh meskipun hanya informasi sekunder.
- Quick actions memiliki tiga tombol, termasuk Sensor yang menduplikasi navigasi Grafik.
- Grid perangkat terdorong terlalu jauh ke bawah.

## Susunan Final

1. Header Nekouse.
2. Hero maroon ringkas.
3. Panel Kondisi Rumah 2×2.
4. Dua quick actions.
5. Filter ruangan ringan.
6. Grid empat lampu.
7. Kartu pompa.

## Hero Ringkas

- Tinggi visual sekitar 160–180 dp.
- Baris pertama: status hub dan tombol Coba Lagi bila offline.
- Bagian utama: sapaan dan nama rumah.
- Footer: jumlah lampu aktif, status pompa, dan estimasi watt dalam tiga item ringkas.
- Ornamen lingkaran besar dihapus.
- Informasi waktu sinkron hanya tampil kecil jika tersedia.

## Kondisi Rumah

- Satu kartu putih beradius 24 dp.
- Empat sensor ditata grid 2×2: Suhu, Udara, Gas, Cuaca.
- Divider vertikal dan horizontal tipis memisahkan nilai.
- Tidak menggunakan horizontal scroll sehingga tidak ada kartu terpotong.
- Tombol `Lihat semua` tetap membuka Grafik.
- Data kosong memakai `—`; gas bahaya memakai merah.

## Quick Actions

- Hanya dua tombol dengan lebar seimbang: `Semua Nyala` dan `Semua Mati`.
- Tombol aktif utama memakai maroon; tombol kedua memakai putih/ivory.
- Saat hub offline, keduanya tampil disabled dengan kontras yang tetap terbaca.
- Tombol Sensor dihapus karena sudah tersedia melalui `Lihat semua` dan tab Grafik.

## Filter Ruangan

- Tinggi 46–48 dp.
- Bentuk chip ringan: ikon kecil dan label dalam satu baris.
- Chip Semua aktif maroon; chip lain putih dengan border warm.
- Horizontal scroll hanya dipakai pada filter, dengan padding konsisten dan tanpa offset negatif.

## Perangkat dan Pompa

- Grid lampu tetap dua kolom dan langsung mengikuti filter.
- Seluruh callback toggle/detail/kecerahan dipertahankan.
- Kartu Pompa tetap berada setelah grid.
- Tombol `Matikan semua lampu` terpisah di bawah dihapus karena sudah ada pada Quick Actions.

## Batas Teknis

- Tidak mengubah `Esp32Service`, polling, threshold, atau rollback.
- Tidak mengubah halaman Grafik, Nekouse, Listrik, dan Profil.
- Estimasi daya tetap diberi label `Estimasi`.
- Layout wajib aman pada lebar 360–430 dp.

## Verifikasi

- Analyzer tanpa masalah.
- Tidak ada overflow atau elemen terpotong pada lebar 360 dan 390 dp.
- Quick actions tetap memanggil `onAllLights(true|false)`.
- `Lihat semua` tetap membuka tab Grafik.

