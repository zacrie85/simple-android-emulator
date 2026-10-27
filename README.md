# Simple Android Emulator

Emulator Android "sangat sederhana" untuk Windows 10/11, dirancang khusus untuk dua hal saja:

1. **Nonton video** TikTok & SnackVideo di PC
2. **Upload video** dari PC ke TikTok & SnackVideo dengan **klik kanan di Windows Explorer**

Bukan emulator baru yang ditulis dari nol - ini paket otomatisasi yang merangkai
**Android SDK Emulator resmi dari Google** menjadi installer satu-klik lengkap dengan
integrasi Windows Explorer. Semua komponen terpasang di folder proyek (portable),
tanpa menginstal Android Studio.

---

## Fitur

| File | Fungsi |
|---|---|
| `setup.bat` | Installer satu klik: unduh JDK + Android SDK + buat emulator + driver akselerasi |
| `start-emulator.bat` | Menyalakan Android (jendela emulator muncul seperti HP biasa) |
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
| Ruang disk | 15 GB kosong |
| Virtualisasi | VT-x / AMD-V aktif di BIOS (umumnya sudah aktif bawaan) |
| Internet | Ya, hanya saat setup (unduh 2-3 GB, sekali saja) |

## Cara Pakai - 3 Langkah

### Langkah 1: Setup (sekali saja)
Double-click **`setup.bat`**, tunggu 10-30 menit (tergantung internet).
Muncul pertanyaan Y/n? Tekan Enter saja (jawaban default = Ya).

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
Yang kita buat hanyalah "kemasan" supaya setup & upload-nya sangat sederhana.

**Q: Kenapa setup lama?**
Mengunduh ~3 GB (JDK + Android SDK + image Android 11). Cukup SEKALI saja,
`setup.bat` bisa dijalankan ulang dan langsung lanjut ke langkah yang belum selesai.

**Q: TikTok/SnackVideo-nya mana? Kenapa tidak sekalian?**
File APK dilindungi hak cipta, jadi tidak boleh disebar lewat repo ini.
`download-apks.bat` mengarahkan ke halaman unduh resmi masing-masing.

**Q: Berat nggak?**
Dengan akselerasi AEHD/WHPX, emulator ini jalan mulus untuk video. RAM dipakai ~3 GB.

**Q: Aman?**
Semua komponen resmi Google/Adoptium. Menu klik-kanan cukup satu kunci registry
`HKCU` yang bisa dilepas kapan saja dengan `remove-explorer-menu.bat`.
`uninstall.bat` menghapus semuanya tanpa jejak.

Troubleshooting lengkap (emulator gagal menyala, APK ditolak Play Protect, dll):
lihat **[docs/panduan-lengkap.md](docs/panduan-lengkap.md)**.

## Disclaimer

Proyek ini tidak berafiliasi dengan TikTok, ByteDance, SnackVideo, Kuaishou,
Google, maupun Android. Tidak ada file APK aplikasi pihak ketiga yang disertakan
atau didistribusikan di repo ini - setiap pengguna memasang aplikasi sendiri dari
sumber resmi. Gunakan sesuai Ketentuan Layanan masing-masing platform. Lisensi kode: [MIT](LICENSE).
