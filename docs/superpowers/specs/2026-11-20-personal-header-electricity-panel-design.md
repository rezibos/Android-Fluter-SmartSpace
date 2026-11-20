# Desain Header Personal dan Panel Penggunaan Listrik

Tanggal: 20 November 2026  
Status: Disetujui untuk implementasi

## Cakupan

Perubahan hanya mencakup header halaman Kontrol dan panel baru Penggunaan Listrik. Panel Kondisi Rumah, grid Perangkat, navigasi, detail perangkat, serta koneksi ESP32 tetap dipertahankan.

## Header Personal Greeting

- Header menggunakan susunan horizontal yang aman pada lebar ponsel 360–430 dp.
- Sisi kiri berisi avatar bulat maroon dengan inisial `W`.
- Di sebelah avatar ditampilkan sapaan sesuai waktu, nama `Willy` sebagai teks utama, serta status rumah `Terhubung` atau `Hub terputus`.
- Sisi kanan berisi tombol Notifikasi dan Profil yang terpisah, masing-masing memiliki target sentuh minimal 48 dp.
- Tombol tetap menjalankan navigasi yang sudah ada.
- Warna menggunakan token tema maroon, ivory, surface, dan muted yang sudah tersedia.

## Posisi Panel Listrik

- Panel Penggunaan Listrik ditempatkan tepat setelah panel Kondisi Rumah dan sebelum grid Perangkat.
- Jarak antarpanel mengikuti ritme halaman yang sudah ada.
- Bentuk visual mengikuti panel Kondisi Rumah agar kedua informasi terasa sebagai satu sistem, bukan kartu yang tidak berkaitan.

## Isi Panel Listrik

- Judul: `Penggunaan Listrik`.
- Label status: `Estimasi langsung`.
- Angka utama: daya aktif saat ini dalam `kW` dengan tiga digit desimal agar pemakaian rumah kecil tetap terbaca.
- Ringkasan bawah:
  - energi `kWh hari ini`;
  - jumlah perangkat aktif;
  - estimasi biaya hari ini dalam rupiah.
- Nilai daya berubah langsung saat status atau tingkat kecerahan perangkat berubah.
- Seluruh angka diberi konteks `Estimasi` karena aplikasi belum menerima pembacaan watt nyata dari sensor energi ESP32.

## Rumus Daya

- Setiap lampu menggunakan daya maksimum 18 W.
- Daya lampu aktif dihitung dengan `18 W × brightness / 100`.
- Lampu mati menggunakan 0 W.
- Pompa aktif menggunakan 65 W dan pompa mati menggunakan 0 W.
- Sistem menggunakan daya standby tetap 8 W.
- Daya saat ini dalam kW dihitung dengan `total watt / 1000`.
- Estimasi biaya menggunakan tarif konfigurasi tetap Rp1.444,70 per kWh dan ditampilkan sebagai estimasi, bukan tagihan resmi.

## Akumulasi Energi Harian

- Energi dihitung dari daya sebelumnya dikalikan waktu berlalu: `kWh += kW × durasi jam`.
- Akumulasi diperbarui mengikuti siklus polling aplikasi tanpa mengubah komunikasi ESP32.
- Nilai kWh, tanggal pencatatan, dan waktu pembaruan terakhir disimpan secara lokal.
- Saat tanggal lokal berubah, kWh hari sebelumnya direset menjadi nol sebelum akumulasi baru dilakukan.
- Saat aplikasi dibuka kembali pada hari yang sama, nilai diteruskan dari penyimpanan lokal.
- Durasi ketika aplikasi tidak berjalan tidak diestimasi agar aplikasi tidak mengklaim penggunaan yang tidak teramati.

## Penyimpanan Lokal

- Gunakan penyimpanan key-value lokal Flutter.
- Kunci penyimpanan dibuat khusus untuk energi harian, tanggal energi, dan waktu pembaruan.
- Kesalahan membaca atau menulis penyimpanan tidak boleh memutus kontrol perangkat; panel kembali ke nilai sesi saat penyimpanan gagal.

## Interaksi dan Aksesibilitas

- Panel listrik bersifat informasional dan tidak mematikan perangkat ketika diketuk.
- Angka utama memiliki label semantik lengkap dalam kW.
- Ringkasan kWh, perangkat aktif, dan biaya tetap terbaca pada pembesaran font Android.
- Header tidak boleh overflow pada lebar 360 dp.

## Verifikasi

- Header tampil tanpa overflow pada lebar 360–430 dp.
- Status header mengikuti kondisi koneksi saat ini.
- Daya kW berubah ketika lampu, brightness, atau pompa berubah.
- kWh bertambah berdasarkan waktu dan daya aktif.
- Nilai kWh bertahan setelah aplikasi dibuka kembali pada hari yang sama.
- Nilai kWh reset saat tanggal berubah.
- Kegagalan penyimpanan tidak mengganggu kontrol ESP32.
- Flutter analyzer selesai tanpa masalah.

