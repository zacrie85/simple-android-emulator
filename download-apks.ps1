# =====================================================================
#  download-apks.ps1 - Membuka halaman unduh RESMI TikTok & SnackVideo
#
#  Catatan: proyek ini TIDAK menyertakan file APK (hak cipta milik
#  masing-masing developer). Pengguna mengunduh sendiri dari sumber
#  resmi, lalu menyimpannya ke folder apks\.
# =====================================================================

$ErrorActionPreference = 'Continue'
. (Join-Path $PSScriptRoot 'scripts\env.ps1')

Write-Host '==> Membuka halaman unduh resmi di browser ...'
Start-Process 'https://www.tiktok.com/download'
Start-Process 'https://www.snackvideo.com'

Write-Host @'

LANGKAH MEMASANG APLIKASI
-------------------------
1. TikTok    : di halaman yang terbuka, unduh versi Android (file .apk).
2. SnackVideo: unduh aplikasi Android dari situs resminya.
3. Simpan / geser kedua file .apk ke folder berikut:

       $env:ApksDir

4. Jalankan install-apks.bat untuk memasangnya ke emulator.

Tips: boleh juga memakai APK dari sumber tepercaya lain yang kamu
kenal, dengan risiko masing-masing. Pilih versi armeabi-v7a atau
universal (emulator ini x86_64, Android 11 - APK modern umumnya
kompatibel lewat lapisan penerjemahan bawaan).
'@
