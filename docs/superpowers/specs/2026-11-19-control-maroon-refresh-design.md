# Desain Penyegaran Halaman Kontrol Maroon

Tanggal: 19 November 2026
Status: Disetujui secara visual, menunggu tinjauan spesifikasi

## Tujuan

Memperbaiki halaman Kontrol berdasarkan screenshot pengguna: menjauhkan header dari status bar, mengembalikan kualitas navbar kapsul, mengganti tema hitam-putih dengan identitas maroon yang hangat, dan membuat hierarki halaman lebih menarik tanpa mengubah koneksi maupun kontrol ESP32.

## Palet

- `background`: `#FFF8F2` (warm ivory).
- `surface`: `#FFFFFF`.
- `surfaceMuted`: `#F5EAE6`.
- `border`: `#E9D9D5`.
- `ink`: `#2B1820`.
- `inkMuted`: `#75636A`.
- `active`: `#7A1F35` (maroon).
- `activeDark`: `#591426`.
- `onActive`: `#FFFFFF`.
- `accent`: `#C89B5B` (muted gold).
- Warna alarm tetap `#E5484D`, bukan maroon.

Palet ini menggantikan Monokrom sebagai tampilan default. Tema Oranye yang sudah tersedia tetap dapat dipilih dari Pengaturan.

## Header

- Konten dibungkus `SafeArea` dan memiliki jarak visual 14–18 dp dari batas bawah status bar.
- Tinggi elemen utama 52 dp.
- Logo menggunakan latar maroon dengan ikon putih serta aksen titik gold.
- Notifikasi dan profil masing-masing berada dalam tombol putih 44 dp dengan border lembut dan bayangan ringan.
- Header tidak memakai kartu besar agar area atas tetap lega.

## Hero Kontrol

- Sapaan, nama rumah, jumlah lampu aktif, dan status hub digabung dalam satu hero card maroon.
- Hero menggunakan gradasi lembut dari `#7A1F35` ke `#591426`, bukan gradasi mencolok.
- Status hub ditampilkan sebagai chip ivory transparan dengan titik hijau/abu.
- Ornamen lingkaran gold transparan dipakai secukupnya untuk kedalaman visual.
- Banner alarm tetap muncul terpisah di bawah hero agar keadaan bahaya tidak tersamar.

## Chip Ruangan

- Ukuran 64×64 dp, radius 18 dp.
- Setiap chip berisi ikon dan label, sesuai desain sistem awal.
- Chip Semua aktif memakai maroon dengan teks putih.
- Chip lain memakai surface putih dengan border warm.

## Kartu Perangkat

- Kartu aktif memakai maroon, ikon putih, status putih transparan, dan toggle ivory.
- Kartu mati memakai putih dengan border warm serta ikon dalam kotak `surfaceMuted`.
- Radius 24 dp, tinggi sekitar 168–176 dp, bayangan lebih lembut.
- Grid tetap dua kolom dan seluruh fungsi ketuk kartu/toggle dipertahankan.

## Kartu Pompa dan Aksi Massal

- Ikon pompa menggunakan kotak maroon muda dan aksen gold untuk status aktif.
- Tombol Matikan Semua menggunakan latar maroon sangat muda, teks maroon, dan border senada.
- Tidak ada istilah pin atau active-low pada tampilan pengguna.

## Navbar

- Navbar tetap mengambang, tetapi tinggi diturunkan dari 72 menjadi sekitar 64 dp.
- Margin horizontal 18–20 dp dan bawah 14–18 dp.
- Latar putih, radius kapsul penuh, border warm, serta bayangan lembut ke atas.
- Item aktif memiliki lebar intrinsik 100–112 dp, latar maroon, ikon dan label putih.
- Item tidak aktif memiliki area sentuh 48×48 dp dan hanya menampilkan ikon maroon-muted.
- Empat item tidak lagi semuanya memakai `Expanded`; `Row` memakai distribusi ruang yang menjaga kapsul aktif tidak terjepit.

## Responsif dan Perilaku

- Tidak ada perubahan endpoint, polling, sinkronisasi, atau rollback.
- Layout harus aman pada lebar 360–430 dp.
- Header tidak boleh bertabrakan dengan kamera punch-hole atau status bar.
- Navbar tidak boleh menutupi tombol terakhir; padding bawah daftar minimal 112 dp.
- Font sistem besar tidak boleh memotong label aktif navbar; label dapat mengecil atau menyembunyikan diri di lebar sangat sempit.

## Verifikasi

- `flutter analyze` tanpa masalah.
- Widget test memastikan empat tujuan navbar tetap dapat dipilih.
- Pemeriksaan screenshot pada ukuran 390×844 memastikan header turun, hero tidak terpotong, dan navbar proporsional.
- Kontrol lampu, kecerahan, pompa, serta polling `/sensor` tetap menggunakan service yang sama.

