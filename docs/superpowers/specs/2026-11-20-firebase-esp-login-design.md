# Desain Login Firebase dan ESP32

Tanggal: 20 November 2026  
Status: Disetujui untuk implementasi

## Tujuan

Menambahkan halaman Login sebagai gerbang aplikasi. Pengguna hanya dapat membuka halaman Kontrol setelah akun Firebase berhasil diautentikasi dan alamat IP ESP32 berhasil diuji.

## Cakupan

- Login email/password menggunakan Firebase Authentication.
- Pengujian koneksi ESP32 menggunakan alamat IP yang dimasukkan pengguna.
- Penyimpanan sesi Firebase dan alamat IP ESP32.
- Animasi transisi logo ketika login berhasil.
- Akun dibuat manual melalui Firebase Console; aplikasi tidak menyediakan pendaftaran akun.
- Halaman Kontrol, koneksi perangkat, sensor, navbar, dan desain yang sudah disetujui tetap dipertahankan.

## Tampilan Login

- Latar menggunakan warna background tema ivory.
- Ikon aplikasi kucing merah dari referensi pengguna ditampilkan sebagai fokus visual di bagian atas.
- Form berisi tepat tiga input dengan urutan:
  1. `IP ESP32` dengan contoh `192.168.1.10`.
  2. `Email`.
  3. `Password`.
- Input password menyediakan tombol tampilkan/sembunyikan.
- Tombol utama menggunakan label `Masuk`.
- Tidak ada tombol daftar akun.
- Layout aman pada lebar 360–430 dp, keyboard, dan pembesaran font Android.
- Semua target sentuh interaktif minimal 48 dp.

## Validasi Form

- IP ESP32 wajib diisi dan hanya menerima hostname/IP tanpa skema, path, spasi, atau karakter berbahaya.
- Email wajib menggunakan format email yang masuk akal.
- Password wajib diisi.
- Pesan validasi muncul di bawah input terkait.
- Saat proses berjalan, tombol Masuk dinonaktifkan dan menampilkan status loading.

## Alur Login

1. Pengguna mengisi IP ESP32, email, dan password.
2. Aplikasi memvalidasi seluruh input secara lokal.
3. Aplikasi menjalankan `signInWithEmailAndPassword` melalui Firebase Authentication.
4. Setelah Firebase berhasil, alamat IP diterapkan sementara ke `Esp32Service`.
5. Aplikasi memanggil endpoint sensor melalui fungsi `fetchSensor()` yang sudah ada.
6. Jika ESP32 merespons, IP disimpan dan animasi sukses dimulai.
7. Setelah animasi selesai, aplikasi mengganti layar Login dengan `HomeShell` pada tab Kontrol.
8. Jika pengujian ESP32 gagal, aplikasi mengembalikan host sebelumnya, tetap berada di Login, dan keluar dari sesi Firebase yang baru dibuat agar kedua syarat tetap konsisten.

## Sesi dan Startup

- Firebase Authentication mengelola persistensi sesi akun; password tidak disimpan aplikasi.
- IP ESP32 terakhir disimpan di Android SharedPreferences melalui platform channel.
- Saat aplikasi dibuka, splash/auth gate memeriksa pengguna Firebase saat ini dan IP tersimpan.
- Jika sesi Firebase tersedia dan IP tersimpan berhasil terhubung ke ESP32, aplikasi langsung membuka Kontrol.
- Jika sesi tersedia tetapi ESP32 tidak terhubung, aplikasi menampilkan Login dengan IP terakhir sudah terisi.
- Jika konfigurasi Firebase belum tersedia, Login menampilkan pesan setup yang dapat dipahami dan aplikasi tidak crash.

## Animasi Login Berhasil

- Form dan teks memudar terlebih dahulu.
- Logo bergerak ke tengah dan membesar hingga menutupi sebagian besar layar.
- Latar bertransisi dari ivory ke maroon.
- `HomeShell` muncul menggunakan fade setelah animasi logo.
- Durasi total 700–900 ms dengan kurva ease-out; tidak ada rotasi atau efek bounce.
- Ketika Reduce Motion/nonaktifkan animasi Android aktif, transisi menjadi fade singkat atau pergantian langsung.

## Pesan Error

- Kredensial tidak sesuai: `Email atau password tidak sesuai.`
- Terlalu banyak percobaan: `Terlalu banyak percobaan. Coba lagi nanti.`
- Jaringan Firebase gagal: `Tidak dapat menghubungi layanan login.`
- ESP32 gagal: `Login berhasil, tetapi hub ESP32 tidak dapat dihubungi.`
- Konfigurasi Firebase belum dipasang: `Firebase belum dikonfigurasi pada aplikasi ini.`
- Error teknis tidak menampilkan stack trace atau detail rahasia kepada pengguna.

## Firebase dan Konfigurasi Android

- Gunakan Firebase Authentication SDK Android resmi melalui platform channel agar UI Flutter tetap dapat diuji tanpa konfigurasi Firebase nyata.
- Tambahkan Google Services plugin pada konfigurasi Gradle Android sesuai dokumentasi Firebase Flutter terbaru.
- `google-services.json` harus ditempatkan di `android/app/google-services.json` oleh pengguna setelah project Firebase dibuat.
- File konfigurasi tidak dibuat-buat, tidak berisi kredensial palsu, dan tidak digantikan placeholder yang dapat dianggap valid.
- Dokumentasikan langkah membuat Firebase project, mendaftarkan aplikasi Android `com.example.witdget`, mengaktifkan Email/Password Authentication, menambahkan akun manual, dan menempatkan file konfigurasi.

## Penyimpanan IP dan Logout

- Platform channel penyimpanan lokal diperluas dengan method baca, simpan, dan hapus host ESP32.
- Password tidak pernah diteruskan ke ESP32 atau penyimpanan lokal.
- Aksi logout memanggil Firebase sign out, menghapus host tersimpan, dan kembali ke Login.
- Jika halaman Profil belum mempunyai tombol logout yang sesuai, tambahkan aksi `Keluar` yang meminta konfirmasi sebelum keluar.

## Keamanan

- Jangan mencatat email, password, token Firebase, atau respons autentikasi ke log.
- Firebase error dipetakan menjadi pesan publik yang aman.
- Host ESP32 divalidasi sebelum digunakan untuk menyusun URL.
- Request ESP32 tetap menggunakan timeout yang sudah diterapkan oleh service.
- Aplikasi tidak mengklaim koneksi aman ke ESP32 jika masih menggunakan HTTP lokal.

## Struktur Komponen

- `AuthGate`: menentukan Login atau HomeShell berdasarkan startup Firebase dan koneksi hub.
- `LoginScreen`: mengelola form, validasi, loading, error, dan animasi sukses.
- `AuthService`: pembungkus kecil untuk Firebase Authentication agar dapat diganti dengan fake pada test.
- `StoredHost`: antarmuka penyimpanan host melalui platform channel dengan implementasi memori untuk test.
- `Esp32Service`: tetap menjadi sumber pengujian koneksi hub dan kontrol perangkat.

## Verifikasi

- Form menolak IP, email, dan password yang tidak valid.
- Login gagal tidak membuka HomeShell.
- Firebase berhasil tetapi ESP32 gagal akan sign out dan tetap di Login.
- Firebase dan ESP32 berhasil menjalankan animasi lalu membuka tab Kontrol.
- Sesi dan IP tersimpan dapat melewati Login saat startup berikutnya.
- Logout menghapus sesi dan host lalu kembali ke Login.
- Login tidak overflow pada lebar 360–430 dp dan saat keyboard terbuka.
- Analyzer selesai tanpa masalah.
- Test unit mencakup validasi, pemetaan error, dan penyimpanan host.
- Widget test mencakup loading, error, sukses, serta auth gate.

