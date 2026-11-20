# Setup Firebase Authentication

1. Buka [Firebase Console](https://console.firebase.google.com/) dan buat project.
2. Tambahkan aplikasi Android dengan package name `com.example.witdget`.
3. Unduh `google-services.json` lalu simpan tepat sebagai `android/app/google-services.json`.
4. Buka **Authentication > Sign-in method**, lalu aktifkan **Email/Password**.
5. Buka **Authentication > Users > Add user** untuk membuat email dan password pengguna secara manual.
6. Jalankan `flutter clean`, `flutter pub get`, lalu `flutter run`.

Tanpa `google-services.json`, aplikasi tetap dapat dibuka tetapi tombol login dinonaktifkan dan menampilkan pesan bahwa Firebase belum dikonfigurasi.

Dokumentasi resmi:

- [Menambahkan Firebase ke Android](https://firebase.google.com/docs/android/setup)
- [Email/password authentication](https://firebase.google.com/docs/auth/android/password-auth)
