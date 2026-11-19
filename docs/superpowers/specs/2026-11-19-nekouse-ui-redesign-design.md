# Desain Perombakan UI Nekouse

Tanggal: 19 November 2026
Status: Menunggu tinjauan pengguna

## 1. Tujuan

Merombak tampilan aplikasi Flutter Smart Space agar mengikuti `DESAIN.md` dan kebutuhan `PRD.md`, sambil mempertahankan integrasi ESP32 yang sudah berjalan. Hasil akhir harus terasa minimalis, ramah, mudah dipahami pengguna awam, dan memperlihatkan kondisi bahaya dengan jelas.

## 2. Batas Lingkup

Perombakan mencakup seluruh antarmuka aplikasi:

- Kontrol sebagai beranda utama.
- Grafik Sensor.
- Pengaturan.
- Detail Lampu.
- Detail Pompa.
- Notifikasi.
- Profil.
- Dialog pengaturan dan pengujian alamat IP hub.
- Komponen bersama, tema, serta state loading, offline, error, dan alarm.

Fungsi jaringan berikut harus tetap tersedia:

- Polling `GET /sensor` setiap dua detik.
- Kontrol lampu melalui `GET /lampu`.
- Kontrol pompa melalui `GET /relay`.
- Sinkronisasi status lampu dan pompa dari respons hub.

Login, backend cloud, Supabase, FCM, dan firmware buzzer tidak ditambahkan dalam pekerjaan ini karena belum didukung implementasi saat ini. UI terkait akun dan notifikasi boleh menggunakan data lokal/demonstrasi, tetapi tidak boleh mengaku terhubung ke layanan yang belum tersedia.

## 3. Arah Visual

Tema default adalah Monokrom sesuai `DESAIN.md`:

- Latar halaman `#F4F4F5`.
- Kartu `#FFFFFF`.
- Elemen aktif dan teks utama `#111111`.
- Teks pendukung `#6B6B70`.
- Border `#E5E5E7`.
- Bahaya `#E5484D` dengan latar lembut `#FDECEC`.
- Aman `#2FB36B`, peringatan `#F2B01E`, dan informasi `#3B82F6`.

Karakter visual memakai ruang kosong yang lega, radius kartu 24–28 dp, bayangan lembut, ikon outline, target sentuh minimal 48 dp, dan angka sensor berukuran besar. Status tidak boleh bergantung pada warna saja; setiap status selalu disertai ikon atau teks.

Tema Oranye disediakan sebagai pilihan kedua melalui token tema yang sama. Warna aktif tema ini `#FF6A1A`; merah tetap khusus bahaya.

## 4. Arsitektur UI

Kode satu file dipisah berdasarkan tanggung jawab:

```text
lib/
  main.dart
  models/
    room_light.dart
    sensor_snapshot.dart
  services/
    esp32_service.dart
  theme/
    space_theme.dart
  screens/
    home_shell.dart
    control_screen.dart
    sensor_screen.dart
    settings_screen.dart
    light_detail_screen.dart
    pump_detail_screen.dart
    notifications_screen.dart
    profile_screen.dart
  widgets/
    alarm_banner.dart
    device_card.dart
    sensor_card.dart
    space_bottom_nav.dart
    space_toggle.dart
```

`HomeShell` menyimpan state aplikasi pada tahap ini agar tidak menambah dependency pengelola state. `Esp32Service` hanya menangani request dan parsing data. Screen menerima data serta callback sehingga tidak mengetahui detail endpoint.

## 5. Navigasi

Bottom navigation memiliki tiga tujuan nyata:

1. Kontrol.
2. Grafik.
3. Pengaturan.

Konten berubah sesuai tab terpilih, bukan hanya indikator navigasinya. Navigasi tampil sebagai kapsul mengambang: tab aktif memiliki latar warna aktif beserta ikon dan label, sedangkan tab lain hanya menampilkan ikon.

Notifikasi dibuka dari ikon lonceng di header Kontrol. Profil dibuka dari avatar. Detail Lampu dibuka dengan mengetuk kartu lampu, sedangkan toggle pada kartu langsung menyalakan atau mematikan perangkat.

## 6. Rancangan Per Layar

### 6.1 Kontrol

Urutan konten:

1. Header sapaan berdasarkan waktu, nama rumah, lonceng, dan avatar.
2. Status hub ringkas dan waktu sinkron terakhir.
3. Banner alarm merah ketika gas melewati ambang.
4. Ringkasan jumlah lampu aktif.
5. Chip horizontal: Semua, Ruang Tengah, Kamar, Dapur, Depan.
6. Grid dua kolom berisi empat kartu lampu.
7. Kartu Pompa Air lebar.
8. Tombol Matikan Semua Lampu.

Kartu lampu aktif memakai latar `active`, teks kontras, status `Aktif • n%`, dan toggle. Kartu mati memakai latar putih, border tipis, dan status `Mati`. Filter ruangan menyaring kartu yang terlihat tanpa mengubah data perangkat.

### 6.2 Detail Lampu

Layar menampilkan nama ruangan, toggle, angka kecerahan besar, slider 10–100%, status daya, dan tombol mematikan lampu. Nilai berubah langsung saat slider digeser, tetapi request hanya dikirim saat geseran selesai. Saat lampu mati, slider nonaktif dan redup.

### 6.3 Detail Pompa

Layar menampilkan status Aktif/Nonaktif, toggle besar, keterangan sinkronisasi, dan ringkasan perangkat. Istilah pin LOW/HIGH tidak diperlihatkan kepada pengguna. Perubahan gagal harus mengembalikan toggle ke keadaan sebelumnya.

### 6.4 Grafik Sensor

Urutan konten:

1. Judul Grafik Sensor dan indikator LIVE/offline.
2. Banner alarm bila gas bahaya.
3. Grid kartu Hujan, Gas, Kelembapan, dan Tanah.
4. Hero suhu dengan angka besar dan kelembapan udara.
5. Tab metrik Gas, Kelembapan, dan Tanah.
6. Grafik riwayat lokal selama sesi aplikasi.

Karena backend penyimpanan belum tersedia, grafik diberi label `Riwayat sesi ini`, bukan `24 jam`. Riwayat disimpan selama aplikasi berjalan dan dibatasi agar tidak tumbuh tanpa batas.

### 6.5 Pengaturan

Bagian Pengaturan terdiri dari:

- Kartu akun lokal yang membuka Profil.
- Kartu Smart Space Hub: status, IP, waktu sinkron terakhir, dan tombol Ubah IP.
- Slider ambang gas 100–600 dengan nilai besar.
- Sakelar Alarm Buzzer dan Notifikasi Peringatan sebagai preferensi lokal.
- Pemilih tema Monokrom dan Oranye.

Pengujian IP memanggil `/sensor`. IP hanya diterapkan jika formatnya valid; kegagalan koneksi dijelaskan dengan pesan yang menyarankan HP dan hub berada pada Wi-Fi yang sama.

### 6.6 Notifikasi

Notifikasi lokal dibuat dari perubahan kondisi sensor selama sesi aplikasi, seperti gas bahaya, hujan, atau hub terhubung kembali. Item dikelompokkan Hari Ini dan menampilkan ikon, waktu, judul, keterangan, serta status baca. Kartu gas bahaya menggunakan tampilan merah penuh.

### 6.7 Profil

Profil menampilkan avatar, nama, email, dan nomor HP sebagai data lokal. Pengguna dapat mengubah data tampilan aplikasi. Tidak ada klaim bahwa data tersimpan di server.

## 7. Aliran Data dan Interaksi

1. `HomeShell` memulai polling dua detik melalui `Esp32Service`.
2. Respons `/sensor` diubah menjadi `SensorSnapshot`.
3. Snapshot memperbarui sensor, lampu, pompa, status koneksi, dan waktu sinkron.
4. Screen menerima state terbaru dan membangun UI.
5. Aksi perangkat menerapkan perubahan optimistik.
6. `Esp32Service` mengirim perintah.
7. Jika gagal, state dikembalikan dan snackbar ramah ditampilkan.
8. Polling berikutnya menjadi sumber kebenaran akhir.

Request memakai timeout tiga detik. Polling tidak boleh memulai request baru bila request sebelumnya belum selesai.

## 8. Aturan Sensor dan Alarm

- Gas dinyatakan bahaya jika nilainya melewati ambang lokal, default 400.
- Hujan jika nilai ADC kurang dari 2500.
- Tanah dikategorikan Basah, Normal, atau Kering menggunakan batas awal yang dijelaskan sebagai perkiraan hingga kalibrasi tersedia.
- Banner alarm tampil di Kontrol dan Grafik.
- Tombol Matikan Alarm hanya menutup/menandai alarm aplikasi karena endpoint buzzer belum tersedia. UI harus menjelaskan bahwa fungsi buzzer perangkat memerlukan dukungan firmware.
- Data yang terakhir berhasil diterima tetap ditampilkan ketika hub offline, disertai waktu pembaruan dan label data lama.

## 9. Error dan State

- Loading awal: skeleton sederhana dan nilai `—`.
- Hub offline: banner abu, kontrol perangkat nonaktif, tombol Coba Lagi.
- Perintah gagal: rollback dan snackbar `Gagal mengirim perintah. Coba lagi.`
- Respons JSON tidak valid: pertahankan snapshot terakhir dan tandai offline.
- Alarm: kartu merah dengan ikon, judul BAHAYA, nilai gas, dan instruksi keselamatan.
- Data grafik kosong: pesan `Data akan muncul setelah sensor mengirim data.`
- Font besar: kartu menggunakan tinggi fleksibel agar teks tidak terpotong.

## 10. Pengujian dan Kriteria Selesai

Pengujian minimum:

- `flutter analyze` tanpa error.
- Widget test membuka aplikasi dan menemukan tiga tab utama.
- Widget test memastikan perpindahan tab benar-benar mengganti layar.
- Test parsing respons `/sensor` yang valid dan tidak lengkap.
- Test klasifikasi gas, hujan, dan tanah.
- Test kartu lampu aktif/mati dan banner alarm.
- Build debug Android berhasil.

Pemeriksaan manual:

- Tampilan tetap rapi pada lebar 360–430 dp.
- Empat lampu dan pompa dapat dikontrol memakai endpoint lama.
- Kecerahan hanya mengirim perintah setelah slider dilepas.
- Status kembali mengikuti ESP32 pada polling berikutnya.
- Alarm gas terlihat jelas di Kontrol dan Grafik.
- Tema Monokrom dan Oranye menjaga kontras serta tidak memakai oranye sebagai warna bahaya.

## 11. Tidak Termasuk

- Autentikasi sungguhan.
- Penyimpanan cloud dan grafik 24 jam.
- Push notification FCM.
- Perubahan firmware buzzer.
- Jadwal, scene, dark mode, dan panel admin.
- Penambahan estimasi konsumsi listrik yang tidak berasal dari sensor nyata.

