# witdget

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# Android-Fluter-SmartSpace

## Nekouse Smart Space

Aplikasi Flutter untuk memantau sensor dan mengontrol lampu serta pompa pada
Smart Space Hub berbasis ESP32.

### Menjalankan aplikasi

```bash
flutter pub get
flutter run
```

Pada tab **Pengaturan**, pilih **Ubah dan tes alamat IP**, lalu masukkan alamat
IP yang tampil pada OLED ESP32. HP dan hub harus berada pada jaringan Wi-Fi yang
sama.

Endpoint firmware yang digunakan:

- `GET /sensor` untuk suhu, kelembapan, tanah, hujan, gas, lampu, dan relay.
- `GET /lampu?ruang=...&status=...&bright=...` untuk lampu dan kecerahan.
- `GET /relay?status=...` untuk pompa air.

Desain aplikasi mengikuti tema Nekouse dalam `DESAIN.md`: Monokrom sebagai tema
default, Oranye sebagai tema alternatif, dan merah khusus kondisi bahaya.
