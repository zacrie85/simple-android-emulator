# Panduan Lengkap & Troubleshooting

Dokumen ini menjawab masalah-masalah yang paling sering muncul saat menjalankan
Simple Android Emulator di Windows 10/11. Baca bagian yang sesuai dengan kendalamu.
Urutan baca yang disarankan untuk pemula: Persyaratan -> Setup -> Masalah umum.

## 1. Persyaratan & Persiapan

### 1.1 Cek virtualisasi (VT-x / AMD-V)
Emulator butuh akselerasi hardware agar video tidak patah-patah.

Cara cek tanpa buka BIOS:
1. Tekan `Ctrl + Shift + Esc` (Task Manager) -> tab **Performance** -> **CPU**
2. Lihat baris **Virtualization**: harus **Enabled**
3. Kalau Disabled: aktifkan lewat BIOS:
   - Intel: masuk BIOS (biasanya tombol F2/Del saat menyala) -> cari **Intel VT-x** / **Intel Virtualization Technology** -> Enabled
   - AMD: cari **SVM Mode** -> Enabled
4. Simpan (F10), restart, cek lagi di Task Manager

### 1.2 Konflik dengan Hyper-V / Memory Integrity
Beberapa fitur keamanan Windows bisa "memegang" virtualisasi. Kalau emulator
gagal menyala dengan pesan `x86 emulation currently requires hardware acceleration`:
1. Buka **Windows Security** -> **Device security** -> **Core isolation details**
2. Matikan **Memory integrity**, restart
3. Alternatif: jalankan CMD sebagai admin:
   `bcdedit /set hypervisorlaunchtype off` lalu restart
   (catatan: ini menonaktifkan WSL2/Docker yang pakai Hyper-V; bisa dikembalikan
   dengan `bcdedit /set hypervisorlaunchtype auto`)

Catatan: driver AEHD yang dipasang `setup.bat` bisa berdampingan dengan Hyper-V
di versi emulator terbaru, jadi langkah di atas hanya bila memang gagal menyala.

## 2. Masalah Saat Setup

### 2.1 Unduhan gagal / lemot
- Jalankan ulang `setup.bat` - semua langkah yang sudah selesai DILEWATI otomatis
- Unduhan SDK dari `dl.google.com` biasanya stabil; kalau jaringan tidak stabil,
  jalankan setup di jam sepi
- Cek log di `tools\setup-sdk.log` bila langkah 4 gagal

### 2.2 UAC (izin admin) muncul - ini normal?
Ya. Satu-satunya langkah yang butuh admin adalah memasang **driver AEHD**
(driver akselerasi resmi Google). Kalau kamu klik No / batal:
- setup menawarkan alternatif fitur Windows **WHPX** (juga butuh admin)
- Tanpa keduanya emulator jalan TANPA akselerasi = sangat lambat.
  Jalankan ulang `setup.bat` untuk mencoba lagi.

### 2.3 PowerShell memblokir script (ExecutionPolicy)
Wrapper .bat sudah membawa flag `-ExecutionPolicy Bypass`, jadi double-click
file .bat selalu aman dijalankan. Kamu tidak perlu mengubah pengaturan apa pun.

## 3. Masalah Saat Menjalankan Emulator

### 3.1 Emulator gagal menyala
1. Jalankan `start-emulator.bat` dan BACA pesan errornya (jangan langsung ditutup)
2. `emulator -accel-check` otomatis dijalankan - hasilnya menunjukkan masalahnya:
   - `AEHD is not installed` -> jalankan ulang `setup.bat` (langkah 5)
   - `VT-x disabled in BIOS` -> lihat bagian 1.1
   - `Hyper-V conflict` -> lihat bagian 1.2
3. PC RAM 4 GB? Emulator butuh minimal 8 GB total RAM

### 3.2 Boot lambat / layar hitam
- Boot pertama memang paling lama (2-5 menit), boot berikutnya cepat
- Layar hitam lebih dari 5 menit: tutup emulator, jalankan lagi `start-emulator.bat`
- Pastikan GPU driver terbaru terpasang (NVIDIA/AMD/Intel)
- Coba mode GPU lain: edit `tools\avd\SimpleAVD.avd\config.ini`, ubah
  `hw.gpu.mode=auto` menjadi `hw.gpu.mode=swiftshader_indirect`

### 3.3 Cara reset emulator ke kondisi pabrik
Tutup emulator, lalu hapus folder `tools\avd\SimpleAVD.avd\` dan
jalankan ulang `setup.bat` (AVD dibuat ulang otomatis, unduhan tidak diulang).

## 4. Masalah Aplikasi (TikTok / SnackVideo)

### 4.1 APK gagal dipasang
- **Play Protect menolak**: di emulator buka **Play Store -> ikon profil ->
  Play Protect -> ikon roda gigi -> matikan "Scan apps with Play Protect"**,
  lalu jalankan lagi `install-apks.bat`. (Matikan hanya jika kamu percaya
  sumber APK-nya.)
- **INSTALL_PARSE_FAILED**: file APK korup / setengah terunduh. Unduh ulang.
- **INSTALL_FAILED_NO_MATCHING_ABIS**: APK-nya hanya untuk ARM tua. Pakai
  versi universal / armeabi-v7a / x86_64 dari halaman resmi.

### 4.2 TikTok gagal login
- Gunakan login **email / nomor HP** (lebih stabil di emulator daripada login SNS)
- Kalau muncul verifikasi captcha, selesaikan seperti biasa
- Jangan login banyak akun berbeda bergantian cepat-cepatan dari satu emulator;
  platform bisa menandai aktivitas itu sebagai tidak wajar

### 4.3 Video upload tidak muncul di galeri
- Cek `uploads\sent-log.txt` - apakah file tercatat terkirim?
- Buka aplikasi **Gallery** di emulator, video ada di album **SimpleUploads**
- Di TikTok/SnackVideo saat memilih video, buka album/folder tersebut
- Media scanner kadang butuh beberapa detik; tarik-untuk-refresh di galeri

### 4.4 Upload video TikTok terasa beda dari HP asli
Fitur tertentu (misal LIVE, beberapa efek, atau fitur khusus wilayah) bisa
dibatasi platform ketika diakses dari emulator. Untuk nonton & upload video
standar, fungsionalnya sama seperti di HP.

## 5. Membersihkan

### 5.1 Hapus menu klik-kanan saja
`remove-explorer-menu.bat` - hanya menghapus satu kunci registry HKCU.

### 5.2 Hapus semua (uninstall total)
1. `uninstall.bat` - mematikan emulator, hapus menu klik-kanan, hapus AVD,
   hapus tools\ (JDK + SDK, sekitar 6-10 GB)
2. Hapus folder proyek secara manual bila ingin bersih total

### 5.3 Memindahkan proyek ke folder / PC lain
Semua komponen PORTABLE di folder `tools\`. Untuk pindah:
1. Tutup emulator
2. Copy seluruh folder proyek ke lokasi/PC baru
3. Jalankan `add-explorer-menu.bat` sekali lagi (menu klik-kanan menyimpan
   path lama)

## 6. Pertanyaan Keamanan

- **Apakah token/kredensial saya dikirim ke mana-mana?** Tidak. Semua script
  di repo ini berjalan lokal, tidak ada data yang dikirim ke server mana pun.
  Komunikasi hanya ke: dl.google.com (unduh SDK), adoptium.net (unduh JDK),
  tiktok.com & snackvideo.com (dibuka di browser oleh kamu sendiri).
- **Menu klik-kanan membuka jendela hitam?** Tidak - script dijalankan hidden.
- **Bagaimana menghapus jejak sepenuhnya?** `uninstall.bat` + hapus folder
  proyek. Registry yang diubah hanya dua kunci HKCU yang ikut dihapus.
