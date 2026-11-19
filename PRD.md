# PRD: Smart Space Apps ("Nekouse")

| | |
|---|---|
| **Nama produk** | Smart Space Apps (maskot/identitas: Nekouse) |
| **Versi dokumen** | 1.0 (draft) |
| **Jenis** | Aplikasi mobile IoT: monitoring sensor + kontrol lampu/pompa + alarm gas |
| **Platform** | Flutter (Android dulu, iOS menyusul dari basis kode yang sama) |
| **Konteks** | Project-Based Learning, mata kuliah Pemrograman Perangkat Bergerak, Teknik Informatika UMRAH, 15 minggu, tim 6 orang |
| **Dokumen pendamping** | `DESAIN.md` (desain UI/UX), `sketch_oct14a.ino` (firmware ESP32), proposal Smart Space Apps |

Legenda status yang dipakai di seluruh dokumen:
- ✅ **Sudah ada** di firmware ESP32
- 🔧 **Perlu perubahan firmware**
- 📱 **Sisi aplikasi / backend** (tidak menyentuh firmware)
- ⭐ **Usulan baru** (belum ada di proposal maupun firmware)

---

## 1. Ringkasan Eksekutif

Smart Space Apps adalah aplikasi mobile untuk memantau dan mengontrol sebuah ruang/rumah pintar lewat HP. Di rumah terpasang satu mikrokontroler ESP32 ("Smart Space Hub") yang terhubung ke lima jenis sensor (suhu, kelembapan udara, kelembapan tanah, hujan, gas), empat lampu yang bisa diredupkan, satu relay (untuk pompa air), buzzer alarm, dan layar OLED. Aplikasi menampilkan data sensor secara real-time, menyimpan riwayatnya sebagai grafik 24 jam, mengontrol lampu dan pompa dari jarak jauh, serta mengirim peringatan (alarm + push notification) ketika kadar gas melewati ambang batas.

Prinsip produk: **sederhana, langsung kelihatan mana yang aktif dan mana yang berbahaya, dan bisa dipakai orang awam tanpa penjelasan.**

Identitas "Nekouse" (neko = kucing, house = rumah): aplikasi diibaratkan kucing penjaga rumah yang mengerjakan perintah pengguna saat pemilik pergi, dengan mata besar yang melambangkan kewaspadaan terhadap kondisi ruangan.

---

## 2. Latar Belakang dan Masalah

Penelitian sebelumnya sudah membuktikan data sensor ESP32 bisa dikirim ke cloud dan diakses lewat HP, tetapi ada kesenjangan: (1) pemantauan banyak ruangan dalam satu akun tidak menjadi fokus, (2) grafik riwayat sensor tidak tersedia, (3) notifikasi otomatis saat melewati ambang batas tidak menjadi fokus, dan (4) antarmuka yang lemah membuat data sulit dipahami pengguna awam. Sebagian lain hanya berupa situs web, bukan aplikasi mobile.

Masalah nyata dari sisi pengguna:

1. Harus berjalan ke saklar tiap ruangan; saklar biasa juga tidak bisa mengatur terang-redup.
2. Kondisi rumah (suhu, hujan, kelembapan tanah, gas) harus dicek satu per satu, atau tidak diketahui sama sekali saat pemilik di luar.
3. Kebocoran gas saat rumah ditinggal tidak ada yang memberi tahu.
4. Pompa air dinyalakan manual dan sering lupa dimatikan.

---

## 3. Tujuan, Sasaran, dan Metrik Keberhasilan

Empat tujuan proyek (selaras dengan rumusan masalah proposal):

| ID | Tujuan | Metrik keberhasilan (target uji) |
|---|---|---|
| G1 | Menampilkan 5 data sensor real-time dan mengontrol lampu + pompa dari aplikasi | Data sensor tampil dan diperbarui ≤ 3 detik sekali; perintah lampu/pompa terlihat efeknya di perangkat ≤ 2 detik pada jaringan normal; keberhasilan perintah ≥ 95% dalam 100 percobaan |
| G2 | Arsitektur 5 lapisan yang menghubungkan sensor, backend/API, database, dan aplikasi | Seluruh alur ESP32 → backend → database → aplikasi berjalan end-to-end tanpa langkah manual |
| G3 | UI/UX mudah dipahami pengguna awam | Pengguna baru dapat menyalakan satu lampu dan menemukan status gas tanpa bantuan dalam ≤ 60 detik (diukur pada uji internal tim, ≥ 5 orang) |
| G4 | Notifikasi otomatis saat kondisi di luar ambang batas | Alarm banner tampil ≤ 5 detik setelah nilai melewati ambang; push notification diterima saat aplikasi tertutup pada ≥ 90% uji |

---

## 4. Di Luar Scope (Non-Goals) untuk Rilis Ini

- Usability testing resmi dengan pengguna di lapangan (direkomendasikan sebagai pengembangan lanjutan).
- Otomasi/penjadwalan perangkat (mis. lampu menyala saat petang) dan scene.
- Prediksi berbasis AI.
- Web dashboard admin penuh, multi-bahasa, enkripsi end-to-end.
- Kontrol warna lampu (hardware tidak mendukung).
- Dukungan perangkat ESP32 selain Smart Space Hub (satu hub per ruangan dulu).

> Hal-hal di atas disebut proposal sebagai pengembangan lanjutan (Subbab 5.2). Dark mode dan penjadwalan **sengaja** ditandai "Could Have" di Bagian 7 agar bisa diambil kalau waktu cukup.

---

## 5. Persona Pengguna

### P1. Willy, penghuni rumah (persona utama)
- **Siapa:** pemilik/penghuni rumah, sering keluar rumah, memakai HP sehari-hari, bukan teknisi.
- **Kebutuhan:** menyalakan/mematikan lampu tanpa bangun; tahu kondisi rumah dari mana saja; diperingatkan kalau ada gas bocor.
- **Frustrasi:** lupa mematikan lampu atau pompa; tidak tahu hujan sudah turun; aplikasi yang penuh istilah teknis.
- **Skenario khas:** malam hari dari tempat tidur menyalakan lampu ruang tamu 40%; sebelum tidur mengecek status gas.

### P2. Pengelola kantor
- Memantau dan mengontrol pencahayaan beberapa ruangan dari satu akun. (Multi-ruangan: lihat FR-DEV-03, prioritas Should.)

### P3. Pengelola gudang
- Memantau kadar gas dan kelembapan, melihat grafik tren 24 jam, mematikan alarm setelah kondisi ditangani.

### P4. Administrator sistem
- Mengelola data perangkat IoT dan data pengguna, memantau status seluruh ruangan (Could Have pada rilis ini).

---

## 6. Ruang Lingkup dan Gambaran Sistem

### 6.1 Perangkat keras (fakta dari firmware dan proposal)

| Komponen | Pin ESP32 | Fungsi | Status |
|---|---|---|---|
| DHT11 | 14 | Suhu dan kelembapan udara | ✅ |
| Sensor kelembapan tanah | 34 (ADC1) | Nilai analog mentah 0–4095 | ✅ |
| Sensor hujan | 35 (ADC1) | < 2500 = HUJAN | ✅ |
| Sensor gas MQ-2 | 32 (ADC1) | > 400 = BAHAYA (ambang awal, bisa dikalibrasi) | ✅ |
| Lampu Kamar | 2 | PWM 5 kHz, 8-bit | ✅ |
| Lampu Ruang Tengah | 0 | PWM | ✅ |
| Lampu Dapur | 4 | PWM | ✅ |
| Lampu Depan | 16 | PWM | ✅ |
| Relay (pompa air) | 13 | Aktif LOW | ✅ |
| Buzzer | 19 | Bunyi saat gas melewati ambang | 🔧 belum ada di kode |
| OLED SSD1306 128x64 | SDA 21, SCL 22 | Menampilkan IP + data sensor | ✅ |

### 6.2 Arsitektur 5 lapisan

| Lapisan | Isi | Teknologi |
|---|---|---|
| Sensing/Actuator | Sensor, lampu PWM, relay, buzzer, OLED | ESP32 |
| Communication | Kirim data dan terima perintah | HTTP (REST) atau MQTT |
| Backend/API | Validasi data, cek ambang batas, endpoint REST, picu notifikasi | Node.js (Express) atau Laravel (dipilih tim saat implementasi) |
| Database | users, devices, sensor_data, actuators, notifications | Supabase (PostgreSQL + realtime) |
| Application | Aplikasi mobile | Flutter (Dart), state: Provider/Riverpod |
| (Pendukung) Notifikasi | Push notification | Firebase Cloud Messaging (FCM) |

### 6.3 Alur data

```
Sensor → ESP32 → (Wi-Fi: HTTP/MQTT) → REST API → Supabase → Aplikasi Flutter → Pengguna
                                          │
                                          └─(melewati ambang)→ FCM → HP pengguna
Perintah kontrol: Aplikasi → REST API → ESP32 (lampu / pompa / matikan alarm)
```

### 6.4 Strategi bertahap karena kondisi firmware saat ini

Firmware yang ada sekarang adalah **HTTP server lokal** di ESP32 (endpoint `/sensor`, `/lampu`, `/relay`) tanpa backend, tanpa login, tanpa buzzer, dan tanpa pengiriman ke cloud. Supaya proyek tetap realistis dalam 15 minggu:

| Fase | Isi | Akses |
|---|---|---|
| **Fase A (MVP lokal)** | Aplikasi memanggil endpoint ESP32 langsung lewat IP lokal: kontrol lampu, relay, baca sensor. Ambang gas dicek di aplikasi. | Hanya satu jaringan Wi-Fi |
| **Fase B (target proposal)** | ESP32 mengirim data berkala ke backend; backend menyimpan ke Supabase, mengecek ambang, mengirim FCM; aplikasi membaca dari backend, perintah lewat backend. | Jarak jauh |
| **Fase C (lanjutan)** | Jadwal, scene, multi-ruangan penuh, dark mode, panel admin. | |

Seluruh requirement di bawah diberi tanda fase (A/B/C) agar tim bisa memotong scope tanpa merusak desain.

---

## 7. Daftar Fitur dan Prioritas (MoSCoW)

| ID | Fitur | Prioritas | Fase | Status |
|---|---|---|---|---|
| F1 | Sambungkan aplikasi ke Smart Space Hub | Must | A | ✅ (IP lokal) / 📱 |
| F2 | Nyala/mati lampu per ruangan + tombol "semua lampu" | Must | A | ✅ |
| F3 | Atur kecerahan lampu (10–100%) | Must | A | ✅ |
| F4 | Kontrol pompa air (relay) | Must | A | ✅ |
| F5 | Monitoring 5 sensor real-time | Must | A | ✅ |
| F6 | Alarm gas: banner, kartu darurat, tombol Matikan Alarm | Must | A/B | 📱 + 🔧 (buzzer) |
| F7 | Pengaturan ambang gas, sakelar alarm buzzer, sakelar notifikasi | Must | A/B | 📱 + 🔧 |
| F8 | Grafik tren 24 jam dengan garis ambang | Should | B | 📱 (butuh penyimpanan) |
| F9 | Login/Registrasi + profil akun | Should | B | 📱 |
| F10 | Push notification (FCM) saat aplikasi tertutup | Should | B | 📱 |
| F11 | Daftar riwayat notifikasi (hari ini/kemarin, tandai dibaca) | Should | B | 📱 |
| F12 | Multi-ruangan dalam satu akun | Should | B | 📱 |
| F13 | Pemulihan status setelah ESP32 restart | Could | B | 🔧 |
| F14 | Dark mode / ganti tema | Could | C | 📱 |
| F15 | Panel admin (kelola perangkat dan pengguna) | Could | C | 📱 |
| F16 | Jadwal lampu otomatis | Could | C | 🔧/📱 ⭐ |
| F17 | Scene/aksi cepat | Won't (rilis ini) | | ⭐ |
| F18 | Warna lampu | Won't | | butuh hardware lain |

---

## 8. User Story dan Acceptance Criteria

**US-01 Sambung ke hub** (P1, Must)
Sebagai penghuni, saya ingin menyambungkan aplikasi ke Smart Space Hub supaya saya bisa mengontrol rumah dari HP.
- [ ] Given aplikasi baru dibuka pertama kali, When saya memasukkan IP hub dan menekan "Tes Koneksi", Then muncul status Terhubung + kekuatan sinyal atau pesan gagal yang jelas.
- [ ] IP yang valid tersimpan dan tidak diminta lagi saat aplikasi dibuka berikutnya.
- [ ] Format IP salah ditolak dengan pesan perbaikan sebelum mencoba koneksi.

**US-02 Nyalakan lampu** (P1, Must)
Sebagai penghuni, saya ingin menyalakan/mematikan lampu tiap ruangan dengan satu ketukan.
- [ ] Given hub terhubung, When saya mengetuk toggle lampu Kamar, Then lampu menyala dan toggle berubah ≤ 2 detik.
- [ ] Jika perintah gagal, toggle kembali ke posisi semula dan muncul pesan "Gagal mengirim perintah".
- [ ] Ringkasan di beranda ("3 dari 5 lampu menyala") ikut berubah.

**US-03 Atur kecerahan** (P1, Must)
- [ ] Saya bisa menggeser kecerahan dari 10% sampai 100%; nilai di bawah 10 tidak bisa dipilih.
- [ ] Angka persen besar mengikuti geseran secara langsung; perintah dikirim setelah geseran berhenti (bukan tiap pixel).

**US-04 Matikan semua lampu** (P1, Must)
- [ ] Satu tombol mematikan empat lampu sekaligus (parameter `ruang=semua`).

**US-05 Kontrol pompa air** (P1, Must)
- [ ] Toggle pompa menampilkan status Aktif/Nonaktif yang jelas dan ikut sinkron dengan kondisi relay sebenarnya.
- [ ] Logika relay aktif-LOW diabaikan oleh pengguna: aplikasi hanya menampilkan "Aktif/Nonaktif".

**US-06 Lihat kondisi rumah** (P1, Must)
- [ ] Layar menampilkan suhu (°C), kelembapan udara (%), kelembapan tanah (Kering/Normal/Basah), hujan (Hujan/Tidak hujan), dan gas (Aman/Bahaya).
- [ ] Ada keterangan "terakhir diperbarui" atau penanda LIVE.

**US-07 Diperingatkan gas bocor** (P1, Must)
- [ ] Given kadar gas melewati ambang, Then banner alarm merah muncul di layar Grafik Sensor ≤ 5 detik, kartu darurat muncul di layar Notifikasi, dan (Fase B) push notification terkirim.
- [ ] Tombol "Matikan Alarm" menghentikan buzzer dan mengubah banner menjadi tertutup; alarm bisa muncul lagi kalau kondisi masih bahaya setelah jeda yang ditentukan (lihat BR-06).

**US-08 Atur ambang gas** (P1, Must)
- [ ] Slider ambang bisa diubah dalam rentang 100–600 (satuan: lihat BR-03) dan nilainya tersimpan.
- [ ] Sakelar Alarm Buzzer dan Notifikasi Peringatan bisa dimatikan masing-masing.

**US-09 Lihat tren** (P1, Should)
- [ ] Grafik 24 jam tersedia untuk Gas, Kelembapan, dan Tanah dengan garis ambang batas dan titik puncak yang bisa diketuk.

**US-10 Akun** (P1, Should)
- [ ] Registrasi, login, logout; ubah nama, email, nomor HP, foto, password; password disimpan hash di server.

---

## 9. Functional Requirements

### 9.1 Koneksi dan perangkat (DEV)
| ID | Requirement | Prioritas | Fase |
|---|---|---|---|
| FR-DEV-01 | Aplikasi menyimpan alamat IP/Hub ID dan menyediakan layar tes koneksi. | Must | A |
| FR-DEV-02 | Status hub ditampilkan di Pengaturan: Terhubung/Terputus, kekuatan sinyal, waktu sinkron terakhir. | Must | A |
| FR-DEV-03 | Satu akun dapat memiliki lebih dari satu perangkat/ruangan (tabel `devices`), dengan pemilih ruangan. | Should | B |
| FR-DEV-04 | Saat hub terputus, semua kontrol dinonaktifkan dan tampil pesan "Hub tidak terhubung" dengan tombol Coba Lagi. | Must | A |

### 9.2 Kontrol lampu (LGT)
| ID | Requirement | Prioritas | Fase |
|---|---|---|---|
| FR-LGT-01 | Empat lampu: Kamar, Ruang Tengah, Dapur, Depan, masing-masing punya toggle dan kecerahan sendiri. | Must | A |
| FR-LGT-02 | Kecerahan 10–100% (selaras `constrain(bright,10,100)` di firmware). | Must | A |
| FR-LGT-03 | Tombol "Matikan semua" dan "Nyalakan semua". | Must | A |
| FR-LGT-04 | Kartu lampu menampilkan status singkat (mis. "Aktif • 70%" atau "Mati"). | Must | A |
| FR-LGT-05 | Pembaruan optimistik pada UI dengan rollback bila perintah gagal. | Should | A |
| FR-LGT-06 | Kecerahan terakhir tiap lampu diingat oleh aplikasi karena firmware hanya mengirim status 0/1 pada `/sensor`. | Should | A |

### 9.3 Pompa air / relay (PMP)
| ID | Requirement | Prioritas | Fase |
|---|---|---|---|
| FR-PMP-01 | Toggle pompa memanggil `/relay?status=1|0`. | Must | A |
| FR-PMP-02 | Status pompa diambil dari field `relay` pada `/sensor` dan menjadi sumber kebenaran. | Must | A |
| FR-PMP-03 | Konfirmasi singkat sebelum menyalakan pompa jika alarm gas sedang aktif. ⭐ | Could | A |

### 9.4 Monitoring sensor (SEN)
| ID | Requirement | Prioritas | Fase |
|---|---|---|---|
| FR-SEN-01 | Polling `/sensor` tiap 2 detik saat layar aktif; berhenti saat aplikasi di latar belakang (Fase A). | Must | A |
| FR-SEN-02 | Tampilkan lima sensor sesuai BR-01 sampai BR-05. | Must | A |
| FR-SEN-03 | Jika DHT gagal baca, tampilkan nilai valid terakhir dengan penanda "data lama" (firmware sudah menahan nilai terakhir bila `NaN`). | Must | A |
| FR-SEN-04 | Penanda LIVE/offline + "terakhir diperbarui n detik lalu". | Must | A |

### 9.5 Grafik riwayat (CHT)
| ID | Requirement | Prioritas | Fase |
|---|---|---|---|
| FR-CHT-01 | Backend menyimpan pembacaan ke `sensor_data` tiap ≤ 60 detik (interval bisa diatur). | Should | B |
| FR-CHT-02 | Grafik garis 24 jam dengan tab Gas / Kelembapan / Tanah, garis ambang putus-putus, titik puncak berlabel. | Should | B |
| FR-CHT-03 | Menampilkan angka terkini besar + selisih persen terhadap ambang. | Should | B |
| FR-CHT-04 | Data kosong → tampilan kosong yang ramah (lihat DESAIN.md). | Should | B |

### 9.6 Alarm dan notifikasi (ALM)
| ID | Requirement | Prioritas | Fase |
|---|---|---|---|
| FR-ALM-01 | Gas melewati ambang → status BAHAYA, banner alarm aktif. | Must | A |
| FR-ALM-02 | Kartu darurat gas di layar Notifikasi dengan tombol Matikan Alarm. | Must | A |
| FR-ALM-03 | Matikan alarm mengirim perintah ke hub (matikan buzzer) dan menandai notifikasi ditangani. | Must | 🔧 B |
| FR-ALM-04 | Backend menyimpan setiap peringatan ke `notifications` dan mengirim FCM. | Should | B |
| FR-ALM-05 | Notifikasi lain: hujan terdeteksi, tanah kering, pompa dinyalakan/dimatikan, hub terhubung kembali. | Should | B |
| FR-ALM-06 | Daftar notifikasi dikelompokkan Hari ini / Kemarin, ada indikator belum dibaca, dan "Tandai dibaca". | Should | B |
| FR-ALM-07 | Buzzer pada hub berbunyi langsung di perangkat (tanpa tergantung internet) saat gas > ambang dan sakelar Alarm Buzzer aktif. | Must | 🔧 |

### 9.7 Pengaturan dan profil (SET/PRF)
| ID | Requirement | Prioritas | Fase |
|---|---|---|---|
| FR-SET-01 | Slider ambang gas dengan nilai besar, label "Aman/Ambang/Bahaya", dan keterangan perilaku buzzer. | Must | A |
| FR-SET-02 | Sakelar Alarm Buzzer dan Notifikasi Peringatan. | Must | A |
| FR-SET-03 | Tombol Keluar (logout) dengan konfirmasi. | Should | B |
| FR-PRF-01 | Ubah foto, nama, email, nomor HP; ubah password lewat dialog terpisah. | Should | B |
| FR-PRF-02 | Tombol "Simpan Perubahan" aktif hanya jika ada perubahan. | Should | B |

### 9.8 Autentikasi (AUT)
| ID | Requirement | Prioritas | Fase |
|---|---|---|---|
| FR-AUT-01 | Registrasi dan login email + password; sesi tersimpan aman. | Should | B |
| FR-AUT-02 | Akses data dibatasi per akun (row-level security di Supabase). | Should | B |
| FR-AUT-03 | Splash dan alur login/registrasi dirancang saat implementasi (belum ada di desain proposal; lihat DESAIN.md untuk desain yang disiapkan). | Should | B |

---

## 10. Aturan Bisnis

| ID | Aturan |
|---|---|
| BR-01 | **Suhu & kelembapan udara:** tampil apa adanya dari DHT11 (suhu 1 desimal, kelembapan bulat). DHT11 bersifat kasar (±2 °C, ±5%), tampilkan tanpa klaim presisi. |
| BR-02 | **Hujan:** nilai ADC `< 2500` = "Hujan", selain itu "Tidak hujan". Ambang bisa dikalibrasi. |
| BR-03 | **Gas:** firmware membandingkan **ADC mentah 0–4095** dengan 400 (BAHAYA bila > 400). Proposal/desain menampilkan slider dalam **ppm** (100–600, contoh 300 ppm). Sensor MQ-2 mentah **bukan ppm**. Keputusan sementara: aplikasi menyimpan ambang sebagai nilai ADC (default 400), ditampilkan ke pengguna dengan satuan "ppm (estimasi)" memakai faktor kalibrasi yang ditentukan tim saat pengujian. Lihat Pertanyaan Terbuka Q2. |
| BR-04 | **Kelembapan tanah:** nilai ADC dikategorikan Kering / Normal / Basah dengan batas hasil kalibrasi (nilai batas awal ditetapkan tim setelah pengukuran; sensor tanah resistif umumnya bernilai makin besar saat makin kering). |
| BR-05 | **Kecerahan:** 10–100%; kecerahan 0 tidak dikirim, gunakan toggle mati. Konversi persen → duty 0–255 dilakukan firmware. |
| BR-06 | **Alarm:** setelah "Matikan Alarm", alarm yang sama tidak berbunyi lagi selama kondisi tetap bahaya dan jeda ≥ 5 menit; jika nilai kembali di bawah ambang lalu melewati lagi, alarm baru dibuat. ⭐ (angka 5 menit usulan, bisa diubah) |
| BR-07 | **Relay:** aplikasi menampilkan Aktif/Nonaktif; inversi aktif-LOW hanya urusan firmware. |
| BR-08 | **Polling:** 2 detik (lebih lambat dari pembacaan sensor firmware 1,5 detik untuk menghindari beban berlebih). Timeout request 3 detik, retry 2 kali, setelah itu status Terputus. |
| BR-09 | **Konsistensi status:** status perangkat di aplikasi selalu mengikuti status dari hub (bukan dugaan lokal); setelah koneksi pulih, status disinkronkan ulang. |
| BR-10 | **Peringatan pin boot:** GPIO 0 dan 2 adalah pin strapping; lampu pada kedua pin bisa menggagalkan boot bila beban menahan level pin. Ini catatan hardware, bukan perilaku aplikasi. |

---

## 11. Spesifikasi API

### 11.1 API ESP32 yang sudah ada ✅ (Fase A)

| Method | Endpoint | Parameter | Respons |
|---|---|---|---|
| GET | `/sensor` | – | JSON: `suhu, udara, tanah, hujan, gas, kamar, tengah, dapur, depan, relay` |
| GET | `/lampu` | `ruang` = `kamar` / `tengah` / `dapur` / `depan` / `semua`; `status` = `1`/`0`; `bright` = 10–100 (default 80) | `200 OK` / `400 Bad Request` |
| GET | `/relay` | `status` = `1`/`0` | `200 OK` / `400 Bad Request` |

Contoh `/sensor`:
```json
{"suhu":28.5,"udara":65.0,"tanah":2100,"hujan":3100,"gas":250,
 "kamar":0,"tengah":1,"dapur":0,"depan":1,"relay":0}
```

Catatan teknis dari firmware: CORS terbuka (`*`); tidak ada autentikasi; `/sensor` tidak mengembalikan kecerahan lampu; ruang yang tidak dikenal pada `/lampu` tetap dibalas `200 OK` tanpa efek (perlu validasi di aplikasi).

### 11.2 Usulan perubahan firmware 🔧 (Fase B)
| Usulan | Keterangan |
|---|---|
| `GET /buzzer?status=0|1` atau `/alarm/mute` | Matikan alarm dari aplikasi. |
| Logika buzzer GPIO 19 | Bunyi bila `gas > ambang` dan alarm aktif; ambang dapat diubah lewat `GET /config?gas=...`. |
| Kirim data berkala | `POST` ke backend tiap N detik (HTTP) atau publish MQTT. |
| Tambah field `bright_*` dan `alarm` pada `/sensor` | Agar aplikasi tidak menebak. |
| Pindahkan kredensial Wi-Fi keluar dari kode | Mis. WiFiManager/portal konfigurasi. |

### 11.3 REST API backend (usulan) ⭐ (Fase B)

| Method | Endpoint | Fungsi |
|---|---|---|
| POST | `/auth/register`, `/auth/login` | Akun |
| GET/PUT | `/me` | Profil |
| GET | `/devices` | Daftar perangkat/ruangan milik pengguna |
| PUT | `/devices/:id/settings` | Ambang gas, alarm_buzzer, notifikasi_aktif |
| POST | `/ingest` | ESP32 mengirim pembacaan sensor |
| GET | `/devices/:id/latest` | Data terkini |
| GET | `/devices/:id/history?metric=gas&hours=24` | Data grafik |
| POST | `/devices/:id/actuators/:aid` | Kontrol lampu/pompa/buzzer (`status`, `tingkat`) |
| GET | `/notifications` | Riwayat notifikasi |
| PATCH | `/notifications/:id/read` | Tandai dibaca |
| POST | `/devices/:id/alarm/mute` | Matikan alarm |
| POST | `/push/register` | Simpan token FCM |

---

## 12. Model Data (Supabase / PostgreSQL)

| Tabel | Kolom | Catatan |
|---|---|---|
| `users` | id, nama, email, no_hp, password (hash), foto, role, alarm_buzzer, notifikasi_aktif | role: user/admin |
| `devices` | id, nama_ruangan, lokasi, id_user (FK), status, batas_gas | 1 user → banyak device |
| `sensor_data` | id, id_device (FK), suhu, kelembapan_udara, kelembapan_tanah, hujan, gas, timestamp | Indeks (id_device, timestamp); retensi mis. 30 hari |
| `actuators` | id, id_device (FK), nama, jenis (lampu/relay/buzzer), status, tingkat (PWM) | Satu baris per lampu/relay/buzzer |
| `notifications` | id, id_user (FK), id_device (FK), jenis, pesan, status_baca, created_at | jenis: gas, hujan, tanah, pompa, perangkat |

Relasi: users 1—N devices; devices 1—N sensor_data; devices 1—N actuators; users/devices 1—N notifications.

Usulan tambahan ⭐: kolom `push_tokens` (id_user, token) dan `acknowledged_at` pada `notifications` untuk BR-06.

---

## 13. Persyaratan Non-Fungsional

| Kategori | Requirement |
|---|---|
| Performa | Aplikasi mulai ≤ 3 detik pada HP kelas menengah; render 60 fps pada animasi slider/toggle; polling tidak menyebabkan lag UI. |
| Keandalan | Tidak crash saat hub offline, IP salah, JSON rusak, atau nilai sensor ekstrem; pemulihan otomatis saat koneksi kembali. |
| Keamanan | Password di-hash; HTTPS ke backend; akses data per akun; token disimpan di secure storage. Catatan: API ESP32 lokal tidak terautentikasi, sehingga siapa pun di Wi-Fi yang sama bisa mengontrol; mitigasi minimum: jaringan Wi-Fi pribadi + (Fase B) kontrol hanya lewat backend. |
| Usability | Semua aksi inti ≤ 2 ketukan dari beranda; target sentuh ≥ 48 dp; teks tanpa istilah teknis. |
| Aksesibilitas | Kontras teks memenuhi WCAG AA; status tidak hanya ditandai warna (selalu disertai ikon/teks); dukung ukuran font sistem. |
| Kompatibilitas | Android 8+ (utama), iOS 13+ (menyusul); layar 360–430 dp lebar. |
| Pemeliharaan | Struktur `lib/{screens,models,services,providers}`; kode dikelola di Git/GitHub. |

---

## 14. Layar Aplikasi (ringkas; detail visual di `DESAIN.md`)

| # | Layar | Fungsi |
|---|---|---|
| 1 | Splash | Logo Nekouse (belum didesain di proposal) |
| 2 | Login/Registrasi | Akun (Fase B) |
| 3 | Sambung Hub | Isi IP, tes koneksi |
| 4 | **Kontrol** (beranda) | Sapaan, ringkasan lampu, kartu lampu per ruangan, kartu pompa air |
| 5 | Detail Lampu | Toggle, kecerahan |
| 6 | **Grafik Sensor** | Banner alarm, kartu sensor, grafik 24 jam |
| 7 | Notifikasi | Daftar peringatan, kartu darurat gas |
| 8 | **Pengaturan** | Akun, status hub, ambang gas, sakelar, keluar |
| 9 | Profil | Foto, nama, email, nomor HP, password |

Navigasi: bottom navigation 3 tab (Kontrol, Grafik, Pengaturan); Notifikasi dan Profil dibuka dari ikon di bagian atas.

---

## 15. Penanganan Error dan Edge Case

| Situasi | Perilaku |
|---|---|
| IP salah / hub mati | Pesan "Tidak bisa terhubung ke Smart Space Hub", tombol Coba Lagi, kontrol dinonaktifkan. |
| Respons 400 | Toast "Perintah tidak valid", toggle rollback. |
| Perintah gagal saat jaringan lambat | Rollback + opsi "Coba lagi". |
| DHT mengembalikan NaN | Pertahankan nilai valid terakhir, beri penanda data lama. |
| ESP32 restart | Semua lampu mati (firmware default); aplikasi menyinkronkan ulang status dan menampilkan "Hub baru saja menyala ulang". |
| Banyak ketukan cepat | Debounce 300 ms; hanya perintah terakhir dikirim. |
| Gas bahaya + aplikasi tertutup | Buzzer di perangkat tetap berbunyi; push dikirim (Fase B). |
| Ambang gas diubah ke nilai sangat rendah | Peringatan "Ambang rendah bisa membuat alarm sering berbunyi". |
| Sensor gas baru dinyalakan (MQ-2 butuh pemanasan) | Abaikan alarm 30–60 detik pertama setelah hub menyala. ⭐ |
| Data grafik kosong | Tampilan kosong + keterangan "Data akan muncul setelah sensor mengirim data". |
| Pengguna logout | Hapus token push dan data lokal sensitif. |

---

## 16. Rencana Pengujian

| ID | Skenario | Langkah | Hasil diharapkan |
|---|---|---|---|
| TC-01 | Tes koneksi berhasil | Masukkan IP benar → Tes Koneksi | Status Terhubung |
| TC-02 | IP salah | Masukkan IP tidak ada | Pesan gagal ≤ 5 detik |
| TC-03 | Nyalakan lampu | Ketuk toggle Kamar | LED GPIO 2 menyala ≤ 2 dtk |
| TC-04 | Kecerahan | Geser 10% → 100% | Terang berubah bertahap; di bawah 10 ditolak |
| TC-05 | Semua lampu | Matikan semua | Empat lampu mati, ringkasan "0 dari 4 menyala" |
| TC-06 | Pompa | Toggle pompa | Relay aktif (LOW), status sinkron |
| TC-07 | Sensor real-time | Tiup/panaskan DHT | Suhu/kelembapan berubah ≤ 3 dtk |
| TC-08 | Hujan | Teteskan air pada sensor hujan | Status Hujan saat nilai < 2500 |
| TC-09 | Gas | Dekatkan sumber gas aman (mis. korek tanpa dinyalakan) | Banner alarm ≤ 5 dtk; buzzer berbunyi |
| TC-10 | Matikan alarm | Ketuk Matikan Alarm | Buzzer berhenti, banner tertutup |
| TC-11 | Ubah ambang | Geser ambang, restart aplikasi | Nilai tersimpan |
| TC-12 | Offline | Matikan hub saat aplikasi terbuka | Status Terputus, kontrol nonaktif, tanpa crash |
| TC-13 | Pulih | Nyalakan hub kembali | Aplikasi tersambung otomatis dan sinkron |
| TC-14 | Grafik | Biarkan 24 jam | Titik data terisi, garis ambang tampil |
| TC-15 | Push | Aplikasi ditutup + gas bahaya | Notifikasi diterima |
| TC-16 | Login | Daftar, login, logout | Sesi dan data per akun benar |
| TC-17 | Boot dengan beban | Nyalakan ESP32 dengan semua lampu terpasang | Boot normal (uji pin 0 dan 2) |
| TC-18 | Kontras dan font besar | Ubah ukuran font sistem | Tidak ada teks terpotong |

Pengujian hardware-in-the-loop dilakukan pada purwarupa miniatur rumah tim.

---

## 17. Timeline (15 minggu, mengikuti proposal)

| Minggu | Kegiatan | Keluaran |
|---|---|---|
| 1–2 | Analisis kebutuhan, studi literatur, proposal | Proposal |
| 3–4 | Arsitektur, use case, database, penyempurnaan UI/UX | PRD, DESAIN, ERD |
| 5–9 | Implementasi backend/API, integrasi sensor, aplikasi Flutter (Fase A lalu B) | Aplikasi berjalan |
| 10–12 | Integrasi, pengujian fungsional, perbaikan bug | Laporan uji |
| 13–15 | Penyempurnaan tampilan, dokumentasi akhir, presentasi | Final |

Saran urutan kerja: Fase A selesai paling lambat minggu 7 agar demo dasar aman; Fase B dikerjakan setelahnya.

---

## 18. Risiko dan Mitigasi

| Risiko | Dampak | Kemungkinan | Mitigasi |
|---|---|---|---|
| Wi-Fi/internet tidak stabil | Data terlambat/hilang | Tinggi | Interval kirim wajar, MQTT QoS sesuai, tampilkan "terakhir sinkron" |
| Pembacaan analog berubah mengikuti lingkungan | Ambang tidak akurat | Tinggi | Kalibrasi di kondisi nyata + ambang bisa diatur pengguna |
| Pin strapping GPIO 0/2 mengganggu boot | Perangkat gagal menyala | Sedang | Uji boot dengan beban; pindah lampu ke pin aman bila perlu |
| Status aplikasi ≠ status perangkat | Pengguna salah paham | Sedang | Status selalu dibaca dari hub, sinkron ulang saat tersambung |
| Notifikasi telat saat aplikasi tertutup | Risiko keselamatan | Sedang | Buzzer lokal di perangkat + FCM |
| Keamanan API lokal tanpa autentikasi | Kontrol oleh orang lain di jaringan | Sedang | Wi-Fi pribadi; Fase B lewat backend terautentikasi |
| Kredensial Wi-Fi tertanam di kode | Kebocoran saat kode dibagikan | Sedang | Pisahkan konfigurasi; jangan unggah ke repo publik |
| Waktu 15 minggu, 6 anggota | Fitur tidak selesai | Sedang | Pembagian per komponen; Fase A sebagai pengaman |
| Ketergantungan gas MQ-2 tanpa kalibrasi ppm | Angka ppm menyesatkan | Sedang | Tampilkan "estimasi" atau pakai kategori Aman/Waspada/Bahaya |

---

## 19. Asumsi dan Dependensi

- Satu Smart Space Hub per ruangan/rumah; pengguna dan hub berada di jaringan yang bisa saling menjangkau (Fase A) atau terhubung internet (Fase B).
- Relay dipakai untuk pompa air (sesuai proposal).
- Supabase dipakai sebagai database; pilihan Node.js vs Laravel dan MQTT vs HTTP diputuskan tim di awal implementasi.
- Perangkat dev tersedia: ESP32, sensor, miniatur rumah, HP Android.
- FCM memerlukan akun Firebase.

---

## 20. Pertanyaan Terbuka

1. **Q1.** Fase A (lokal) dianggap cukup untuk demo, atau Fase B (backend + jarak jauh) wajib selesai?
2. **Q2.** Satuan gas: ppm (estimasi) atau kategori saja? Siapa yang mengkalibrasi MQ-2 dan kapan?
3. **Q3.** Backend: Node.js atau Laravel? Transport: MQTT atau HTTP?
4. **Q4.** Apakah buzzer GPIO 19 sudah terpasang dan kodenya akan ditambah ke firmware?
5. **Q5.** Apakah "multi-ruangan" berarti beberapa hub, atau 4 ruangan dalam satu hub (seperti firmware sekarang)? Rancangan ini mengasumsikan 4 ruangan/lampu dalam satu hub di Fase A.
6. **Q6.** Apakah pompa air dipantau levelnya (tandon) atau hanya dinyalakan/dimatikan? Desain proposal menyebut "Tandon Utama".
7. **Q7.** Perlu login pada Fase A atau cukup mulai dari Fase B?

---

## 21. Lampiran

**Glosarium:** ADC (konversi analog-digital, 0–4095 pada ESP32), PWM (modulasi lebar pulsa untuk meredupkan lampu), MQ-2 (sensor gas), FCM (Firebase Cloud Messaging), MQTT (protokol publish-subscribe ringan), Strapping pin (pin yang nilainya dibaca saat boot).

**Ringkasan temuan dari firmware `sketch_oct14a.ino`:**
- Mode Wi-Fi station + `WebServer` port 80, CORS terbuka.
- Sensor dibaca tiap 1500 ms, OLED ikut diperbarui.
- Lampu: `ledcAttach` 5000 Hz 8-bit; kecerahan 10–100% dipetakan ke duty 0–255.
- Relay aktif LOW; saat boot dipaksa HIGH (mati).
- Belum ada: buzzer, autentikasi, pengiriman ke cloud, penyimpanan status, endpoint untuk kecerahan/alarm/konfigurasi.

**Referensi (dari proposal):** Hasib & Akib (2026), Akter dkk. (2024), Ramelan dkk. (2023), Durgekar dkk. (2024), Białkowski & Smołka (2022), Islam dkk. (2022), Sonklin & Sonklin (2024), Hmissi & Ouni (2024).
