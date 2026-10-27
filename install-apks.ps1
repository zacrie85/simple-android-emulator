# =====================================================================
#  install-apks.ps1 - Memasang semua file .apk di folder apks\
#  ke emulator Android (misal: TikTok, SnackVideo).
#  Otomatis menyalakan emulator bila belum menyala.
# =====================================================================

$ErrorActionPreference = 'Continue'
. (Join-Path $PSScriptRoot 'scripts\env.ps1')
. (Join-Path $PSScriptRoot 'scripts\ensure-device.ps1')

if (-not (Test-Path $env:AdbExe)) {
  Write-Host '[!!] ADB tidak ditemukan. Jalankan setup.bat terlebih dahulu.' -ForegroundColor Red
  exit 1
}

$apks = @(Get-ChildItem -Path $env:ApksDir -Filter '*.apk' -ErrorAction SilentlyContinue)
if ($apks.Count -eq 0) {
  Write-Host '[!!] Folder apks\ masih kosong.' -ForegroundColor Yellow
  Write-Host '     1. Jalankan download-apks.bat (membuka halaman resmi)'
  Write-Host '     2. Simpan file .apk ke folder apks\'
  Write-Host '     3. Jalankan lagi install-apks.bat'
  exit 1
}

Ensure-EmulatorRunning

$okCount = 0
foreach ($apk in $apks) {
  Write-Host "==> Memasang $($apk.Name) ..."
  & $env:AdbExe install -r $apk.FullName
  if ($LASTEXITCODE -eq 0) {
    Write-Host "    [OK] $($apk.Name) terpasang." -ForegroundColor Green
    $okCount++
  } else {
    Write-Host "    [!!] Gagal memasang $($apk.Name) (kode $LASTEXITCODE)." -ForegroundColor Yellow
    Write-Host '     - Kalau muncul Play Protect: buka Play Protect -> Detail -> Tetap install.'
    Write-Host '     - Pastikan file .apk utuh (tidak setengah terunduh).'
    Write-Host '     - Lihat docs\panduan-lengkap.md bagian "APK gagal dipasang".'
  }
}

Write-Host ''
if ($okCount -gt 0) {
  Write-Host "[OK] $okCount aplikasi terpasang. Buka di emulator dan login!" -ForegroundColor Green
}
