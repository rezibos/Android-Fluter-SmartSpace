# Desain Kondisi Rumah, Quick Actions, dan Tab Nekouse

Tanggal: 19 November 2026
Status: Menunggu tinjauan pengguna

## Tujuan

Mengisi ruang kosong halaman Kontrol dengan informasi dan aksi yang berguna, serta memindahkan elemen ilustratif Nekouse ke tab tersendiri agar halaman utama tidak terasa penuh.

## Tambahan Halaman Kontrol

### Kondisi Rumah

Ditempatkan setelah hero maroon dan sebelum chip ruangan. Bagian ini memiliki judul `Kondisi Rumah`, tombol `Lihat semua` yang membuka tab Grafik, dan empat mini-card horizontal:

- Suhu: nilai DHT11 dalam °C.
- Kelembapan: nilai kelembapan udara dalam persen.
- Gas: Aman/Bahaya berdasarkan ambang aktif.
- Cuaca: Hujan/Tidak hujan berdasarkan sensor.

Mini-card memakai surface putih, border warm, ikon maroon, dan aksen gold. Gas bahaya tetap memakai merah. Ketika data belum tersedia, nilai menjadi `—`, bukan data contoh.

### Ringkasan Penggunaan

Kartu lebar menampilkan:

- Jumlah lampu aktif.
- Status pompa.
- Estimasi daya saat ini berdasarkan daya nominal yang sudah dipakai layar Listrik.

Kartu wajib mencantumkan kata `Estimasi` agar tidak dianggap data dari meter listrik.

### Quick Actions

Tiga tombol horizontal:

- Nyalakan Semua.
- Matikan Semua.
- Cek Sensor, yang membuka tab Grafik.

Aksi lampu memakai callback ESP32 yang sudah ada. Tombol dinonaktifkan ketika hub offline.

## Tab Nekouse

Navbar menjadi lima tujuan: Kontrol, Grafik, Nekouse, Listrik, dan Profil. Nekouse ditempatkan di tengah dan tampil sebagai tombol bulat maroon yang sedikit terangkat, sementara empat tujuan lain memakai ikon biasa. Pada layar 360–430 dp, label hanya tampil untuk tab biasa yang aktif; tombol Nekouse selalu berupa ikon kaki kucing.

Halaman Nekouse berisi:

- Ilustrasi maskot berbasis komponen Flutter, tanpa aset internet.
- Status emosional berdasarkan kondisi rumah: `Rumah aman`, `Aku sedang berjaga`, atau `Perlu perhatian`.
- Ringkasan suhu, gas, perangkat aktif, dan status hub.
- Pesan singkat yang berubah berdasarkan sensor.
- Tombol `Buka Kontrol Rumah` dan `Lihat Sensor`.

Tab ini bersifat informatif dan tidak menduplikasi grid perangkat.

## Batas Teknis

- Tidak mengubah service atau endpoint ESP32.
- Tidak menambahkan data sensor palsu.
- Estimasi daya dihitung lokal dan diberi label jelas.
- Alarm gas tetap lebih menonjol daripada warna merek maroon.
- Navbar lima item tetap memiliki target sentuh minimal 48 dp dan tidak overflow pada lebar 360 dp.

## Verifikasi

- Analyzer tanpa masalah.
- Widget test memastikan quick actions memanggil callback yang benar.
- Widget test memastikan tombol Nekouse membuka halaman Nekouse.
- Pemeriksaan layout pada lebar 360 dan 390 dp memastikan navbar tidak overflow.

