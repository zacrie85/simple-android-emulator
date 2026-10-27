# =====================================================================
#  start-emulator.ps1 - Menyalakan emulator Android SimpleAVD
#  Dipanggil lewat start-emulator.bat
# =====================================================================

$ErrorActionPreference = 'Continue'
. (Join-Path $PSScriptRoot 'scripts\env.ps1')

if (-not (Test-Path $env:EmulatorExe)) {
  Write-Host '[!!] Emulator belum di-setup. Jalankan setup.bat terlebih dahulu.' -ForegroundColor Red
  exit 1
}

Write-Host '==> Memeriksa akselerasi hardware ...'
& $env:EmulatorExe -accel-check
Write-Host ''

Write-Host "==> Menyalakan emulator $($env:AvdName) ..."
Write-Host '    Boot pertama: 2-5 menit. Boot berikutnya jauh lebih cepat.'
Start-Process -FilePath $env:EmulatorExe -ArgumentList "-avd $($env:AvdName)" | Out-Null

& $env:AdbExe start-server 2>$null | Out-Null
& $env:AdbExe wait-for-device

$tries = 0
while ($tries -lt 150) {
  $boot = ''
  try { $boot = (& $env:AdbExe shell getprop sys.boot_completed 2>$null) } catch { $boot = '' }
  if ("$boot".Trim() -eq '1') { break }
  Start-Sleep -Seconds 2
  $tries++
  Write-Host -NoNewline '.'
}
Write-Host ''

if ($tries -ge 150) {
  Write-Host '[!!] Boot tidak selesai dalam 5 menit.' -ForegroundColor Red
  Write-Host '     Baca docs\panduan-lengkap.md bagian "Emulator gagal menyala".' -ForegroundColor Red
  exit 1
}

Write-Host ''
Write-Host '[OK] Android siap dipakai!' -ForegroundColor Green
Write-Host '     - Login TikTok / SnackVideo langsung dari aplikasinya.'
Write-Host '     - Upload video dari PC:'
Write-Host '         klik kanan video di Explorer -> "Kirim ke Emulator"'
Write-Host '         (atau jalankan watch-uploads.bat lalu taruh video di uploads\)'
