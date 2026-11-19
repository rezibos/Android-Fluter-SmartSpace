# DESAIN.md: Smart Space Apps ("Nekouse")

Dokumen desain UI/UX untuk aplikasi Smart Space. Gaya visual mengacu pada **dua gambar referensi smart home** yang diberikan di awal: satu bertema **monokrom hitam-putih** dan satu bertema **aksen oranye**. Fungsi dan isi layar mengikuti `PRD.md` (Kontrol, Grafik Sensor, Notifikasi, Pengaturan, Profil).

> Aturan penting: referensi hanya untuk **gaya**. Jangan menyalin merek atau produk dari gambar (Amazon Echo, Apple HomePod, thermostat, router). Semua ilustrasi diganti perangkat milik Smart Space: lampu, sensor, pompa air, hub.

---

## 1. Prinsip Desain

1. **Minimalis dan lega:** banyak ruang kosong, satu hal penting per kartu.
2. **Kartu besar dan membulat:** sudut sangat membulat, bayangan lembut, terasa "empuk".
3. **Satu ketukan = satu hasil:** toggle berbentuk pil, selalu terlihat on/off dari jauh.
4. **Angka besar untuk hal penting:** persen kecerahan, suhu, kadar gas ditampilkan besar dan tebal.
5. **Bahaya harus langsung terlihat:** satu-satunya warna keras di aplikasi adalah merah untuk bahaya.
6. **Satu tangan:** kontrol utama di setengah bawah layar, target sentuh ≥ 48 dp.
7. **Hangat dan ramah:** sapaan personal dan bahasa sehari-hari (maskot Nekouse sebagai penjaga rumah).

---

## 2. Tema

Dua tema memakai struktur token yang sama; yang berbeda hanya nilainya. **Default: Tema A (Monokrom).** Tema B (Oranye) adalah pilihan di Pengaturan. Dark mode adalah tema turunan (Could Have), tokennya sudah disiapkan di bawah.

### 2.1 Tema A: Monokrom (default)

Terinspirasi gambar referensi pertama: putih bersih, hitam pekat untuk elemen aktif.

| Token | Hex | Pemakaian |
|---|---|---|
| `bg` | `#F4F4F5` | Latar halaman |
| `surface` | `#FFFFFF` | Kartu, sheet, kolom input |
| `surfaceMuted` | `#EDEDEF` | Kartu nonaktif, track slider |
| `border` | `#E5E5E7` | Garis tipis kartu/input |
| `ink` | `#111111` | Teks utama, ikon, elemen aktif |
| `inkMuted` | `#6B6B70` | Teks pendukung (kontras ≥ 4.5:1 di atas `surface`) |
| `inkOnDark` | `#FFFFFF` | Teks di atas kartu hitam |
| `active` | `#111111` | Toggle on, kartu perangkat aktif, chip terpilih |
| `activeOn` | `#FFFFFF` | Ikon/teks di atas `active` |
| `track` | `#E5E5E7` | Jalur slider kosong |
| `shadow` | `rgba(17,17,17,0.08)` | Bayangan kartu |

### 2.2 Tema B: Aksen Oranye

Terinspirasi gambar referensi kedua: krem hangat, kartu abu kehijauan, aksen oranye.

| Token | Hex | Pemakaian |
|---|---|---|
| `bg` | `#F3F1EC` | Latar halaman |
| `surface` | `#FFFFFF` | Kartu utama |
| `surfaceMuted` | `#E9E9E1` | Kartu sekunder (kartu abu kehijauan) |
| `border` | `#DEDCD3` | Garis tipis |
| `ink` | `#1B1B1B` | Teks utama |
| `inkMuted` | `#6F6F66` | Teks pendukung |
| `inkOnDark` | `#FFFFFF` | Teks di atas aksen/gelap |
| `active` | `#FF6A1A` | Toggle on, slider terisi, tombol utama, chip terpilih |
| `activeOn` | `#FFFFFF` | Ikon di atas oranye (gunakan teks tebal; untuk teks kecil di atas oranye pakai `#1B1B1B`) |
| `track` | `#E3E0D6` | Jalur slider kosong |
| `shadow` | `rgba(60,40,20,0.10)` | Bayangan kartu |

### 2.3 Warna Status (sama di kedua tema)

| Token | Hex | Arti | Wajib disertai |
|---|---|---|---|
| `safe` | `#2FB36B` | Aman, cerah, terhubung | ikon centang / teks "Aman" |
| `warn` | `#F2B01E` | Waspada, tanah kering, sinyal lemah | ikon peringatan |
| `danger` | `#E5484D` | **Bahaya gas, alarm aktif**, gagal | ikon + teks "BAHAYA" |
| `dangerBg` | `#FDECEC` | Latar lembut kartu bahaya | |
| `info` | `#3B82F6` | Hujan, informasi netral | ikon tetes air |

Catatan: di Tema B, oranye `active` dan merah `danger` cukup mirip. Karena itu **alarm selalu memakai kartu penuh berwarna `danger` + ikon bunyi + teks**, bukan hanya warna, dan tidak pernah memakai oranye.

### 2.4 Token Dark Mode (Could Have)

| Token | Monokrom Gelap | Oranye Gelap |
|---|---|---|
| `bg` | `#0E0E10` | `#16130F` |
| `surface` | `#1A1A1D` | `#221E18` |
| `surfaceMuted` | `#242428` | `#2C2720` |
| `ink` | `#F5F5F6` | `#F5F1EA` |
| `inkMuted` | `#9A9AA0` | `#A59F93` |
| `active` | `#FFFFFF` | `#FF7A33` |
| `activeOn` | `#111111` | `#1B1B1B` |

---

## 3. Tipografi

| Peran | Font | Ukuran / berat | Catatan |
|---|---|---|---|
| Display angka (persen, suhu, ppm) | **DM Sans** | 56 / 700 (maks 72 untuk hero) | Angka tabular (`fontFeatures: tabularFigures`) agar tidak "bergoyang" saat berubah |
| Judul layar | DM Sans | 28 / 700 | Contoh: "Smart Light", "Grafik Sensor" |
| Judul kartu | DM Sans | 16 / 600 | |
| Isi | DM Sans | 14 / 400 | |
| Label kecil / satuan | DM Sans | 12 / 500, huruf kapital opsional, letter-spacing 0.4 | Contoh: "BRIGHTNESS" |
| Tombol | DM Sans | 14 / 600 | |

Alasan: sans-serif geometris modern seperti di referensi, tersedia lewat paket `google_fonts` di Flutter, dan satu keluarga font menyederhanakan aplikasi. Judul tebal besar, teks pendukung abu.

Skala spasi dan teks mengikuti ukuran font sistem (jangan mengunci tinggi kartu; pakai `minHeight`).

---

## 4. Bentuk, Jarak, Bayangan, Ikon

| Aspek | Nilai |
|---|---|
| Radius kartu besar | 28 dp |
| Radius kartu perangkat | 24 dp |
| Radius chip, tombol | 16 dp (chip ruangan: kotak membulat 16, bukan pil penuh) |
| Radius toggle | pil penuh (tinggi 32, lebar 56) |
| Radius foto/avatar | lingkaran |
| Grid spasi | kelipatan 4: 4, 8, 12, 16, 24, 32 |
| Margin layar | 20 dp kiri-kanan |
| Jarak antar kartu | 12 dp |
| Padding kartu | 16–20 dp |
| Bayangan | `0 8 24 shadow`, tanpa border tebal; border 1 dp hanya pada kartu nonaktif |
| Ikon | Gaya **outline** (garis 1.75 dp), 24 dp; paket disarankan: Phosphor / Lucide. Ikon aktif tidak diisi, perubahan ditunjukkan oleh latar `active`. |
| Ilustrasi perangkat | Gambar produk lampu gantung hitam (seperti gambar 1), lampu kuningan (gambar 2) untuk lampu; ilustrasi vektor/foto sendiri, bukan hasil salinan |

---

## 5. Komponen

### 5.1 Toggle Pil
- Ukuran 56 x 32 dp, knob lingkaran 24 dp.
- Off: latar `surfaceMuted`, knob `surface` dengan bayangan tipis. On: latar `active`, knob `activeOn`.
- Animasi 180 ms ease-out; getar ringan (haptic light) saat ditekan.
- Saat menunggu respons hub: knob menampilkan indikator kecil berputar; jika gagal kembali ke posisi awal + toast.

### 5.2 Chip Ruangan (kategori)
- Kotak membulat 64 x 64 dp berisi ikon + label di bawahnya (seperti "Living room, Bedroom, Kitchen" di gambar 1).
- Terpilih: latar `active`, ikon `activeOn`. Tidak terpilih: `surface` dengan border `border`.
- Deretan bisa digeser horizontal. Isi: **Semua, Ruang Tengah, Kamar, Dapur, Depan**.

### 5.3 Kartu Perangkat (grid 2 kolom)
- Tinggi minimal 156 dp. Isi: ilustrasi/ikon di atas, nama (16/600), status kecil di bawah ("70%", "Mati"), toggle di pojok kanan bawah.
- Aktif: latar `active` (hitam atau oranye), teks `activeOn`. Nonaktif: `surface` + border.
- Ketuk kartu → buka Detail; ketuk toggle → langsung nyalakan/matikan.

### 5.4 Slider Kecerahan Melengkung (arc)
Khusus layar Detail Lampu (mengacu gambar 1, kiri).
- Busur setengah lingkaran di tepi kiri layar, label "High" di atas dan "Low" di bawah, knob hitam bulat di jalurnya.
- Di sebelah kanan busur: angka persen **besar** (72/700) dengan label "Kecerahan" abu di bawahnya.
- Rentang 10–100%; di bawah 10% knob berhenti (tidak bisa ke 0, mati lewat toggle).
- Pembaruan angka real-time saat digeser; perintah dikirim setelah berhenti 250 ms.

### 5.5 Slider Vertikal Besar
Alternatif untuk Tema B (mengacu gambar 2, kanan) dan untuk volume/level lain: batang tebal berisi warna `active` dari bawah, handle bulat putih.

### 5.6 Slider Intensitas Horizontal dengan Skala
- Track 4 dp, knob 20 dp, skala "Off | | | | | 100%" di bawahnya (seperti "Intensity 70%" di gambar 1).
- Dipakai sebagai kontrol kedua yang sinkron dengan slider arc (kedua kontrol mengubah nilai yang sama).

### 5.7 Kartu Sensor
- Kotak kecil 2 kolom: ikon, judul kecil ("HUJAN", "GAS", "KELEMBAPAN", "TANAH"), nilai (20/700), titik status 8 dp (`safe`/`warn`/`danger`).
- Kartu Gas berubah penuh menjadi `dangerBg` dengan border `danger` saat bahaya.

### 5.14 Kartu Hero Suhu (dari kartu AC pada gambar 2)
- Kartu lebar: angka suhu 56/700 dengan simbol °, kelembapan kecil di atasnya (tetes air + "65%"), dan 3–4 tombol kecil ikon di bawah (Hujan, Tanah, Gas, Hub) sebagai pintas ke detail.

### 5.8 Banner Alarm
- Kartu penuh `danger`, ikon lonceng bergetar, judul "Alarm aktif: Gas terdeteksi", keterangan "Tingkat gas 480 melewati ambang 400", tombol putih "Matikan Alarm".
- Muncul di atas layar Grafik dan layar Kontrol; tidak bisa digeser hilang (hanya hilang lewat tombol atau saat kondisi aman).

### 5.9 Kartu Notifikasi
- Baris kartu dengan ikon bulat, judul, jam kecil di kanan, satu baris keterangan, titik biru/merah untuk belum dibaca.
- **Kartu darurat gas:** penuh `danger`, label "DARURAT", jam, judul "Gas bocor terdeteksi", keterangan, tombol "Matikan Alarm".
- Pengelompokan "HARI INI / KEMARIN" dengan jumlah baru di sebelah kanan judul grup.

### 5.10 Bottom Navigation
- Tiga tab dalam kapsul mengambang: Kontrol, Grafik, Pengaturan. Tab aktif berlatar `active` dengan label; yang lain hanya ikon.
- Notifikasi (lonceng) dan Profil (avatar) ada di header kanan atas beranda.

### 5.11 Tombol
| Jenis | Tampilan |
|---|---|
| Utama | Latar `active`, teks `activeOn`, tinggi 52, radius 16 |
| Sekunder | `surface` + border, teks `ink` |
| Bahaya | `danger` penuh, teks putih (Matikan Alarm, Keluar akun) |
| Teks | Tanpa latar, `ink` bergaris bawah tipis |

### 5.12 Kolom Input
Latar `surface`, border `border`, radius 16, label kecil di atas ("NAMA LENGKAP"), ikon di kiri, error: border `danger` + pesan merah kecil di bawah.

### 5.13 Toast / Snackbar
Pil gelap di bawah di atas bottom nav, 3 detik, contoh: "Gagal mengirim perintah. Coba lagi".

---

## 6. Peta Layar

```
Splash → (belum login?) Login / Registrasi → Sambung Hub (pertama kali)
                                                  │
                                                  ▼
         ┌────────────── Bottom Nav ───────────────┐
         │   Kontrol   │   Grafik Sensor   │  Pengaturan │
         └──────┬──────┴─────────┬─────────┴──────┬──────┘
                │                │                │
       Detail Lampu         Detail Sensor       Profil
       Detail Pompa Air     (tap kartu)         Sambung Hub / Tema
   ┌── lonceng → Notifikasi (dari header)
   └── avatar  → Profil
```

---

## 7. Desain Per Layar

> Wireframe di bawah adalah panduan tata letak (bukan piksel final). Tinggi layar acuan 800 dp, lebar 390 dp.

### 7.1 Splash
- Latar `bg`, logo Nekouse di tengah (kepala kucing, mata besar), nama "Smart Space" di bawahnya, tagline "Rumah kamu, satu sentuhan."
- Logo memakai warna merah aslinya di kedua tema (satu-satunya pengecualian warna merek). Durasi ≤ 1,5 detik atau sampai data awal siap.

### 7.2 Login / Registrasi
```
        [logo Nekouse]
  Selamat datang
  Masuk untuk menjaga rumahmu
  ┌ EMAIL ───────────────────┐
  └──────────────────────────┘
  ┌ PASSWORD ─────────── 👁 ─┐
  └──────────────────────────┘
  [        Masuk        ]   ← tombol utama
  Belum punya akun? Daftar
```
- Registrasi menambah: Nama, Nomor HP, Konfirmasi password. Validasi inline; tombol nonaktif sampai semua valid.
- State: loading di tombol, error di bawah kolom, "Email atau password salah".

### 7.3 Sambung Hub (pertama kali)
```
  ←  Sambungkan Hub
  Nyalakan Smart Space Hub, lalu masukkan alamat IP
  yang tampil di layar OLED-nya.
  ┌ ALAMAT IP ───────────────┐
  │ 192.168.1.xx             │
  └──────────────────────────┘
  [   Tes Koneksi   ]
  ● Terhubung • Sinyal kuat        ← hasil
  [   Lanjut   ]
```
- Ilustrasi kecil hub dengan layar OLED menampilkan "IP: ..." sebagai petunjuk.
- State: menguji (spinner), berhasil (`safe`), gagal (`danger` + saran: "Pastikan HP dan hub di Wi-Fi yang sama").

### 7.4 Kontrol (beranda)
```
 ≡                                     🔔•  (avatar)
 Selamat sore,
 Rumah Willy
 3 dari 4 lampu menyala
 [Semua][Tengah][Kamar][Dapur][Depan]      ← chip ruangan

 Perangkat                                  ⋯
 ┌─────────────┐ ┌─────────────┐
 │ 🛋          ◉│ │ 🛏          ○│
 │ Ruang       │ │ Kamar       │
 │ Tengah      │ │ Mati        │
 │ Aktif • 100%│ │             │
 └─────────────┘ └─────────────┘
 ┌─────────────┐ ┌─────────────┐
 │ Dapur       │ │ Lampu Depan │
 │ Aktif • 70% │ │ Mati        │
 └─────────────┘ └─────────────┘

 Pompa Air
 ┌───────────────────────────────┐
 │ 💧 Pompa Air          [ ◉ ]   │
 │ Nonaktif • Tandon Utama       │
 └───────────────────────────────┘
 [Matikan semua lampu]
        ( Kontrol ) Grafik  Pengaturan
```
- Sapaan menyesuaikan waktu: Selamat pagi / siang / sore / malam.
- Titik merah di lonceng bila ada notifikasi belum dibaca.
- Kartu aktif berwarna `active` (hitam di Tema A, oranye di Tema B).
- Bila alarm aktif: banner alarm (5.8) muncul di bawah sapaan.
- State: memuat (kerangka kartu abu berkedip/skeleton), hub terputus (kartu abu + banner "Hub tidak terhubung" + Coba Lagi), kosong (belum ada hub: ajakan "Sambungkan hub").

### 7.5 Detail Lampu (mengacu gambar 1, kiri)
```
 ←
 Lampu Kamar                      [ilustrasi lampu
 [ ◉ ]                             menggantung dari
                                   atas kanan]
 High
  ╭─╮
  │ ●                          47%
  ╰─╯                       Kecerahan
 Low

 Intensitas                              70%
 ───────────────●──────────
 Off  |  |  |  |  |  |  100%
```
- Ilustrasi lampu di kanan atas menyala/redup mengikuti nilai kecerahan.
- Toggle di bawah judul; saat dimatikan, busur dan angka menjadi abu dan slider nonaktif.
- (Fase C) Bagian "Jadwal: Dari 12:00 AM → 18:00 PM" bisa ditambahkan di bawah slider seperti di gambar 1; **tidak ada di rilis ini**.
- Tersedia aksi "Matikan lampu ini" dan, untuk Ruang Tengah/Kamar/Dapur/Depan, nama ruangan sebagai judul.

### 7.6 Detail Pompa Air (mengacu gambar 1, kanan)
```
 ←
 Pompa Air
 [ ◉ ]
 ⚡ Aktif                 [ilustrasi pompa/tandon]
 Terakhir dinyalakan 12.40
 ┌─────────┐ ┌─────────┐ ┌─────────┐
 │  Aktif  │ │ Riwayat │ │ Info    │
 └─────────┘ └─────────┘ └─────────┘
```
- Toggle besar, status jelas ON/OFF.
- Bila alarm gas aktif, muncul peringatan sebelum menyalakan pompa (FR-PMP-03).
- Tiga tombol kotak di bawah seperti baris ikon pada gambar 1 (Wi-Fi/Mic/Alarm): untuk pompa berisi Aktif, Riwayat, Info.

### 7.7 Grafik Sensor (mengacu kartu AC gambar 2 + grafik proposal)
```
 PANTAUAN                              ⟳ LIVE
 Grafik Sensor

 ┌─────────────────────────────────────┐
 │ 🔔 Alarm aktif: Gas terdeteksi      │  ← banner (hanya saat bahaya)
 │ Tingkat gas melewati ambang 400     │
 │                    [Matikan Alarm]  │
 └─────────────────────────────────────┘

 ┌────────────┐ ┌────────────┐
 │ 💧 HUJAN   │ │ ⚠ GAS      │
 │ Tidak hujan│ │ BAHAYA     │
 └────────────┘ └────────────┘
 ┌────────────┐ ┌────────────┐
 │ KELEMBAPAN │ │ TANAH      │
 │ 60%        │ │ Kering     │
 └────────────┘ └────────────┘
 ┌─ hero ──────────────────────────────┐
 │ Suhu                                │
 │ 28.5°          💧 65%               │
 └─────────────────────────────────────┘

 GRAFIK 24 JAM
 [Gas] [Kelembapan] [Tanah]
 480 ppm   ↗ +12% dari ambang
        ╱‾╲      ← garis ambang putus-putus
   ___╱     ╲___╱‾
 06 10 14 18 Sekarang
        ( Kontrol  Grafik  Pengaturan )
```
- Titik puncak pada grafik berlabel (mis. "480 ppm • 14.30 Puncak") dan bisa diketuk.
- Grafik tanpa data (Fase A): tampilkan nilai terkini saja + keterangan "Riwayat tersedia setelah data tersimpan".
- Kartu hujan memakai `info` biru saat Hujan; kartu tanah `warn` saat Kering.

### 7.8 Notifikasi
```
 ←  Notifikasi                    Tandai dibaca
 HARI INI                                3 Baru
 ┌─ DARURAT ───────────── 14.22 ───────┐
 │ Gas bocor terdeteksi                │
 │ Kadar gas 480 melewati batas aman.  │
 │ [ 🔇 MATIKAN ALARM ]               │
 └─────────────────────────────────────┘
 ● Hujan terdeteksi                13.40
   Sensor mendeteksi hujan di luar.
 ● Tanah kering                    11.16
   Kelembapan tanah di bawah normal.
   Pompa air dinyalakan             11.05
 KEMARIN                          3 Peristiwa
   Lampu Depan menyala              18.00
   Perangkat terhubung kembali      09.12
```
- Ikon bulat per jenis: gas, hujan, tanah, pompa, lampu, hub.
- Titik di samping judul menunjukkan belum dibaca; hilang saat ditandai dibaca.
- Kosong: ilustrasi Nekouse tidur + "Belum ada peringatan. Rumahmu aman."

### 7.9 Pengaturan
```
 AKUN
 Pengaturan
 ┌─────────────────────────────────────┐
 │ (avatar) Willy                [Ubah]│
 │ willy@email.com                     │
 └─────────────────────────────────────┘
 ┌─────────────────────────────────────┐
 │ PERANGKAT UTAMA                     │
 │ Smart Space Hub          ● Terhubung│
 │ 📶 Sinyal kuat    Terakhir sinkron: 5 detik lalu │
 └─────────────────────────────────────┘
 ┌─ KEAMANAN SENSOR ───────────────────┐
 │ Alarm Gas Bocor                     │
 │ Batas Gas                      400  │
 │ ───────────●──────────              │
 │ 100    Ambang   600                 │
 │ Buzzer berbunyi jika kadar gas      │
 │ melewati batas ini                  │
 │ 🔊 Alarm Buzzer              [ ◉ ]  │
 │ 🔔 Notifikasi Peringatan     [ ◉ ]  │
 └─────────────────────────────────────┘
 Tema            (Monokrom ◉)(Oranye ○)
 [   ⇥ Keluar   ]
        ( Kontrol  Grafik  Pengaturan )
```
- Slider ambang: nilai besar di kanan atas judul; label di bawah "Aman | Ambang | Bahaya".
- Pemilih tema menampilkan dua swatch yang bisa diketuk; perubahan langsung diterapkan.
- Keluar → dialog konfirmasi "Keluar dari akun?".

### 7.10 Profil
```
 ←  Profil
        (foto bulat 96)  📷
        Ubah foto
        Willy
        willy@email.com
 ┌ NAMA LENGKAP ─────────┐
 ┌ EMAIL ────────────────┐
 ┌ NOMOR HP ─────────────┐
 ┌ PASSWORD ••••••• [Ubah]┐
 [   Simpan Perubahan   ]   ← aktif hanya jika ada perubahan
 [   ⇥ Keluar   ]
```

---

## 8. State Standar (berlaku untuk semua layar)

| State | Tampilan |
|---|---|
| Memuat | Skeleton kartu abu berkedip lembut; angka diganti "—" |
| Kosong | Ilustrasi sederhana Nekouse + satu kalimat + satu tombol |
| Error | Kartu `dangerBg` kecil + tombol "Coba lagi"; tidak pernah layar kosong tanpa penjelasan |
| Offline hub | Banner abu "Hub tidak terhubung" di atas layar, kontrol nonaktif, data lama diberi cap waktu |
| Berhasil | Toast singkat atau perubahan visual langsung (tanpa dialog) |
| Disabled | Opasitas 40%, tanpa bayangan |

---

## 9. Pergerakan dan Umpan Balik

- Durasi: 150–250 ms, kurva ease-out; tanpa animasi dekoratif yang berat.
- Toggle: knob bergeser + haptic ringan.
- Angka sensor berubah dengan transisi hitung singkat (tween 300 ms).
- Alarm: lonceng bergoyang pelan; kartu darurat berdenyut halus (maks 2 kali, lalu diam) agar tidak mengganggu aksesibilitas.
- Pergantian tab: fade 150 ms.
- Hormati pengaturan "kurangi animasi" dari sistem.

---

## 10. Aksesibilitas

- Kontras teks ≥ 4.5:1 (`ink` di atas `surface`/`bg`, `inkOnDark` di atas `active` hitam; untuk oranye, teks kecil memakai `#1B1B1B`).
- Status tidak hanya warna: ikon + teks ("Aman", "BAHAYA", "Hujan").
- Target sentuh ≥ 48 x 48 dp; jarak antar target ≥ 8 dp.
- Semantik label untuk pembaca layar: "Lampu Kamar, mati, ketuk dua kali untuk menyalakan".
- Slider bisa diatur lewat tombol aksesibilitas (naik/turun 10%).
- Mendukung font besar sistem sampai 200% tanpa teks terpotong.

---

## 10b. Microcopy (nada: ramah, singkat, sehari-hari)

| Konteks | Teks |
|---|---|
| Sapaan | "Selamat sore, Rumah Willy" |
| Ringkasan | "3 dari 4 lampu menyala" |
| Hub putus | "Hub tidak terhubung. Pastikan HP dan hub di Wi-Fi yang sama." |
| Perintah gagal | "Gagal mengirim perintah. Coba lagi." |
| Gas bahaya | "Gas bocor terdeteksi! Buka jendela dan jauhi sumber api." |
| Alarm dimatikan | "Alarm dimatikan." |
| Kosong notifikasi | "Belum ada peringatan. Rumahmu aman." |
| Tanah kering | "Tanah di tanaman terlalu kering." |
| Hujan | "Hujan terdeteksi di luar." |
| Keluar | "Keluar dari akun?" |

---

## 11. Panduan Implementasi Flutter

- **Tema:** satu `ThemeExtension` bernama `SpaceColors` berisi seluruh token di Bagian 2; dua instance (`monokrom`, `oranye`) + varian gelap. Pilihan tema disimpan di `shared_preferences`.
- **Font:** `google_fonts` → `DM Sans`; gunakan `FontFeature.tabularFigures()` untuk angka sensor.
- **Struktur widget bersama (`lib/widgets/`):** `SpaceToggle`, `RoomChip`, `DeviceCard`, `ArcBrightnessSlider` (pakai `CustomPainter`), `VerticalLevelSlider`, `TickSlider`, `SensorCard`, `HeroTempCard`, `AlarmBanner`, `NotifCard`, `SpaceBottomNav`, `SpaceButton`, `SpaceTextField`.
- **State:** Provider/Riverpod: `HubProvider` (koneksi, polling 2 detik), `DevicesProvider` (lampu/pompa dengan pembaruan optimistik), `SensorProvider`, `AlarmProvider`, `SettingsProvider`, `ThemeProvider`.
- **Grafik:** `fl_chart` (garis ambang putus-putus dengan `ExtraLinesData`, tooltip pada titik puncak).
- **Pemisahan layar:** `lib/screens/{splash,login,connect_hub,kontrol,detail_lampu,detail_pompa,grafik_sensor,notifikasi,pengaturan,profil}`.
- **Aset:** `assets/logo/nekouse.svg`, `assets/illustrations/` (lampu, pompa, hub, Nekouse kosong/tidur), ikon outline dari satu paket saja.
- **Responsif:** lebar kartu = (lebar layar − 40 − 12) / 2; tinggi mengikuti isi dengan `minHeight`.

---

## 12. Daftar Aset yang Perlu Disiapkan

1. Logo Nekouse (SVG) + ikon aplikasi (adaptive icon).
2. Ilustrasi lampu gantung (hitam, nyala/redup), ilustrasi lampu untuk tiap ruangan (opsional).
3. Ilustrasi pompa air/tandon, ilustrasi hub dengan OLED.
4. Ilustrasi kosong: Nekouse tidur (notifikasi kosong), Nekouse siaga (gas bahaya).
5. Set ikon outline: ruang tamu, kamar, dapur, teras/depan, hujan, gas, tanah, suhu, kelembapan, pompa, lonceng, pengaturan, grafik, sinyal.
6. Suara alarm in-app (opsional) dan suara notifikasi push.

---

## 13. Catatan Perbedaan dengan Desain di Proposal

Proposal memuat mockup dengan palet krem-cokelat-merah tua dan font serif untuk judul (Playfair Display). **DESAIN.md ini menggantinya** dengan gaya referensi (monokrom + oranye, sans-serif), tetapi **mempertahankan isi dan alur layarnya**: tiga tab bawah, banner alarm, kartu darurat gas, slider ambang gas, status hub, profil. Merah tua proposal digantikan oleh warna `danger` (#E5484D) khusus untuk bahaya, dan merah logo Nekouse tetap dipakai pada logo.

Jika dosen/tim ingin tetap memakai desain proposal, cukup ganti nilai token di Bagian 2 menjadi palet krem-cokelat-merah; struktur komponen tidak berubah.
