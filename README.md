# Simple Android Emulator

Emulator Android "sangat sederhana" untuk Windows 10/11, dirancang khusus untuk dua hal saja:

1. **Nonton video** TikTok & SnackVideo di PC
2. **Upload video** dari PC ke TikTok & SnackVideo dengan **klik kanan di Windows Explorer**

Bukan emulator baru yang ditulis dari nol - ini paket otomatisasi yang merangkai
**Android SDK Emulator resmi dari Google** menjadi installer satu-klik lengkap dengan
integrasi Windows Explorer. Semua komponen terpasang di folder proyek (portable),
tanpa menginstal Android Studio.

---

## 🪶 Mode Tanpa Emulator (PALING RINGAN — 60 KB)

> Emulator terasa berat / tidak mau ribet? Coba ini dulu.

Buka **`nonton-upload-web.html`** (double-click, jalan di Chrome/Edge):

- **TikTok**: login (QR), nonton, dan **upload video langsung dari PC** lewat
  TikTok Studio resmi (tiktok.com/tiktokstudio/upload) — tanpa emulator sama sekali
- **SnackVideo**: nonton via web snackvideo.com (upload tetap butuh aplikasi —
  paling ringan dari HP)
- **Studio Caption**: kolom Deskripsi + Hashtag (auto #), draft tersimpan otomatis,
  satu klik salin ke mana pun
- Ukuran **± 60 KB**, tanpa install, tanpa unduhan besar

Kenapa bisa? Karena untuk *login, nonton, dan upload*, kamu hampir tidak butuh APK:
TikTok menyediakan semuanya di web resmi. APK Android (program ARM) memang tidak
bisa jalan di PC x86 tanpa emulator — tapi fungsinya bisa digantikan web.
Emulator di repo ini tersedia bila tetap diperlukan (mis. upload SnackVideo dari PC).

---

## Fitur

| File | Fungsi |
|---|---|
| `nonton-upload-web.html` | **Mode tanpa emulator**: nonton/login/upload TikTok via web + Studio Caption (60 KB) |
| `setup.bat` | Installer satu klik (ONLINE): unduh JDK + Android SDK + buat emulator + driver akselerasi |
| `install-offline.bat` | Installer **OFFLINE**: dari 3 file zip rilis GitHub, TANPA unduhan ke server Google |
| `start-emulator.bat` | Menyalakan Android (jendela emulator muncul seperti HP biasa) |
| `helper-upload.bat` | Jendela bantu upload: kolom **Deskripsi & Hashtag** diketik otomatis ke aplikasi |
| `download-apks.bat` | Membuka halaman unduh **resmi** TikTok & SnackVideo |
| `install-apks.bat` | Memasang semua APK dari folder `apks\` ke emulator |
| `add-explorer-menu.bat` | Aktifkan klik kanan **"Kirim ke Emulator"** di Windows Explorer |
| `watch-uploads.bat` | Mode folder: video di `uploads\` otomatis masuk galeri emulator |
| `remove-explorer-menu.bat` | Matikan menu klik-kanan |
| `uninstall.bat` | Bersih-bersih total (emulator, SDK, menu klik-kanan) |

## Persyaratan

| Komponen | Minimal |
|---|---|
| OS | Windows 10 / 11 64-bit |
| RAM | 8 GB (disarankan 16 GB) |
| Ruang disk | 10 GB kosong |
| Virtualisasi | VT-x / AMD-V aktif di BIOS (umumnya sudah aktif bawaan) |
| Internet | Ya untuk unduh APK TikTok/SnackVideo. Komponen emulator bisa diunduh sekali lewat rilis GitHub (mode offline, lihat di bawah) |

## Cara Pakai - Mode OFFLINE (disarankan kalau unduhan dari Google lambat/error)

Semua komponen besar (Java, emulator, system image Android 11, total ± 2,4 GB)
sudah dipaketkan di halaman **[Releases](../../releases)** dalam 3 file zip.

1. Unduh 3 file dari rilis terbaru ke satu folder (mis. `Downloads`):
   - `offline-part1-app-java-cmdline.zip`
   - `offline-part2-emulator-tools.zip`
   - `offline-part3-system-image.zip`
2. Klik kanan **part 1** → *Extract All* → buka folder hasil extract
3. Double-click **`install-offline.bat`**
   (part 2 & 3 otomatis dicari - boleh tetap di folder Downloads)
4. Ikuti petunjuk di layar sampai muncul "Instalasi OFFLINE selesai!"
5. Pasang aplikasi: `download-apks.bat` → simpan APK ke `apks\` → `install-apks.bat`
   (ini satu-satunya langkah yang masih butuh internet)

Cocok untuk koneksi yang sering putus: unduhan bisa dilakukan bertahap,
di-retry, atau pakai download manager, lalu pemasangan 100% offline.

## Cara Pakai - 3 Langkah

### Langkah 1: Setup (sekali saja)
Double-click **`setup.bat`**, tunggu 5-20 menit (unduhan total ± 2 GB).
Muncul pertanyaan Y/n? Tekan Enter saja (jawaban default = Ya).

> Koneksi ke dl.google.com lambat/sering error? Pakai **mode OFFLINE** di atas -
> unduh 3 file dari halaman Releases lalu jalankan `install-offline.bat`.

### Langkah 2: Pasang TikTok & SnackVideo
1. Jalankan **`download-apks.bat`** - browser membuka halaman resmi TikTok & SnackVideo
2. Unduh versi Android (.apk) dari halaman resmi tersebut
3. Simpan / geser file .apk ke folder **`apks\`**
4. Jalankan **`install-apks.bat`**

### Langkah 3: Nonton & Upload!
- Jalankan **`start-emulator.bat`** - Android menyala, login TikTok/SnackVideo seperti di HP
- **Upload dari PC**: klik kanan file video di Explorer -> **"Kirim ke Emulator"**
  (aktifkan dulu lewat `add-explorer-menu.bat`, satu kali saja)
- Video langsung muncul di galeri Android, siap dipilih saat upload di TikTok/SnackVideo

> Alternatif upload tanpa klik kanan: jalankan `watch-uploads.bat`, lalu
> copy/paste video apa saja ke folder `uploads\` - otomatis masuk galeri emulator.

**Caption instan (deskripsi + hashtag):** jalankan **`helper-upload.bat`** -
muncul jendela kecil berisi kolom **Deskripsi** dan **Hashtag** (tanda #
ditambah otomatis). Kirim video dari situ, lalu saat kolom deskripsi di
aplikasi aktif, klik "Ketik" - teks termasuk emoji muncul otomatis.

## Alur Upload (Bagaimana Ini Bekerja?)

```
[Windows Explorer]                     [Emulator Android]
 video.mp4
    |
    | klik kanan -> Kirim ke Emulator
    v
 send-to-emulator.ps1
    |  (emulator off? otomatis dinyalakan)
    |  adb push video.mp4  ------------>  /sdcard/DCIM/SimpleUploads/
    |  media scanner broadcast --------->  video terindeks galeri
    v
 popup "Video sudah masuk galeri!"     TikTok/SnackVideo -> Upload -> pilih video
```

Teknisnya: `adb push` + broadcast `MEDIA_SCANNER_SCAN_FILE`, standar resmi Android.
Menu klik-kanan disimpan via registry `HKCU` (tanpa admin, aman, mudah dihapus).

## Struktur Folder

```
simple-android-emulator/
|-- setup.bat / setup.ps1          installer satu klik
|-- start-emulator.bat / .ps1      peluncur Android
|-- helper-upload.bat / .ps1       jendela bantu upload (deskripsi + hashtag)
|-- install-apks.bat / .ps1        pasang APK dari apks\
|-- download-apks.bat / .ps1       buka halaman unduh resmi
|-- add-explorer-menu.bat / .ps1   pasang menu klik-kanan
|-- remove-explorer-menu.bat / .ps1 hapus menu klik-kanan
|-- watch-uploads.bat / .ps1       mode folder otomatis
|-- send-to-emulator.ps1           inti pengiriman video
|-- uninstall.bat / .ps1           bersih-bersih
|-- scripts/                       konfigurasi bersama (env, ensure-device)
|-- apks/                          <- taruh file .apk di sini
|-- uploads/                       <- folder upload otomatis
|-- docs/panduan-lengkap.md        troubleshooting lengkap
`-- tools/                         (dibuat saat setup, 6-10 GB, di-gitignore)
```

## FAQ Singkat

**Q: Ini emulator apa?**
Android SDK Emulator resmi dari Google (QEMU), image Android 11 (API 30), x86_64.
Image API 30 dipakai karena punya terjemahan ARM bawaan - APK TikTok/SnackVideo
hanya tersedia untuk prosesor ARM, jadi hanya bisa jalan di image Android 11+
(di image lebih lama muncul error `INSTALL_FAILED_NO_MATCHING_ABIS`).
Yang kita buat hanyalah "kemasan" supaya setup & upload-nya sangat sederhana.

**Q: Kenapa setup lama?**
Mengunduh ± 2 GB (Java + Android SDK + image Android 11). Cukup SEKALI saja,
`setup.bat` bisa dijalankan ulang dan langsung lanjut ke langkah yang belum selesai.
Kalau unduhannya lambat/error terus, pakai **mode OFFLINE** (3 file zip dari
halaman Releases + `install-offline.bat`).

**Q: TikTok/SnackVideo-nya mana? Kenapa tidak sekalian?**
File APK dilindungi hak cipta, jadi tidak boleh disebar lewat repo ini.
`download-apks.bat` mengarahkan ke halaman unduh resmi masing-masing.

**Q: Berat nggak?**
Dengan akselerasi AEHD/WHPX, emulator ini jalan mulus untuk video. RAM dipakai ~2 GB.

**Q: Aman?**
Semua komponen resmi Google/Adoptium. Menu klik-kanan cukup satu kunci registry
`HKCU` yang bisa dilepas kapan saja dengan `remove-explorer-menu.bat`.
`uninstall.bat` menghapus semuanya tanpa jejak.

Troubleshooting lengkap (emulator gagal menyala, APK ditolak Play Protect, dll):
lihat **[docs/panduan-lengkap.md](docs/panduan-lengkap.md)**.

## Riwayat Versi

- **v1.3.0** - **Mode Tanpa Emulator**: `nonton-upload-web.html` (± 60 KB) -
  nonton & login TikTok + upload via TikTok Studio resmi, nonton SnackVideo di
  web, dan Studio Caption (Deskripsi + Hashtag, salin 1 klik). Solusi untuk PC
  yang tidak kuat menjalankan emulator
- **v1.2.0** - **Offline Installer**: semua komponen dipaketkan jadi 3 file zip di
  halaman Releases (masing-masing < 2 GB) - pasang tanpa unduhan ke server Google
  via `install-offline.bat`. Keyboard helper ADBKeyboard ikut di paket (helper
  upload benar-benar offline). Image system kembali ke **Android 11 (API 30)**
  karena APK TikTok/SnackVideo ber-ARM hanya bisa jalan di image API 30+
- **v1.1.0** - Setup lebih ringan (± 1,5 GB: JRE 17 + image Android 9 API 28) dan
  Helper Upload: jendela kolom Deskripsi + Hashtag yang diketik otomatis ke
  aplikasi di emulator (dukungan emoji via ADBKeyboard open source, MIT)
- **v1.0.1** - Fix gagal di langkah 4/7 (lisensi SDK via metode CI/CD + retry per paket)
- **v1.0.0** - Rilis pertama

## Disclaimer

Proyek ini tidak berafiliasi dengan TikTok, ByteDance, SnackVideo, Kuaishou,
Google, maupun Android. Tidak ada file APK aplikasi pihak ketiga yang disertakan
atau didistribusikan di repo ini - setiap pengguna memasang aplikasi sendiri dari
sumber resmi. Gunakan sesuai Ketentuan Layanan masing-masing platform. Lisensi kode: [MIT](LICENSE).
