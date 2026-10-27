# =====================================================================
#  remove-explorer-menu.ps1 - Menghapus menu klik-kanan
#  "Kirim ke Emulator Android" dari Windows Explorer
# =====================================================================

$ErrorActionPreference = 'Continue'

$base = 'HKCU:\Software\Classes\*\shell\KirimKeEmulator'
if (Test-Path $base) {
  Remove-Item $base -Recurse -Force
  Write-Host '[OK] Menu klik-kanan "Kirim ke Emulator" dihapus.' -ForegroundColor Green
} else {
  Write-Host 'Menu klik-kanan tidak ditemukan (memang sudah bersih).'
}

$key = 'HKCU:\Software\SimpleAndroidEmulator'
if (Test-Path $key) { Remove-Item $key -Recurse -Force }
