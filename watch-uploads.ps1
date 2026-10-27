# =====================================================================
#  watch-uploads.ps1 - Mode upload otomatis via folder
#
#  Cara pakai:
#   1. Jalankan watch-uploads.bat (jendela ini biarkan terbuka)
#   2. Copy/paste video (.mp4/.mov/.mkv/.avi/.webm) ke folder uploads\
#   3. Dalam 5 detik video otomatis dikirim ke galeri emulator,
#      lalu dipindah ke uploads\terkirim\
#
#  Tekan Ctrl+C untuk berhenti.
# =====================================================================

$ErrorActionPreference = 'Continue'
. (Join-Path $PSScriptRoot 'scripts\env.ps1')
. (Join-Path $PSScriptRoot 'scripts\ensure-device.ps1')

$send = Join-Path $env:RepoRoot 'send-to-emulator.ps1'
$exts = @('.mp4', '.mov', '.mkv', '.avi', '.webm', '.3gp', '.m4v')
$doneDir = Join-Path $env:UploadsDir 'terkirim'
New-Item -ItemType Directory -Path $doneDir -Force | Out-Null

Write-Host '=============================================='
Write-Host '  Mode Upload Otomatis (folder uploads\)'
Write-Host '=============================================='
Write-Host "Folder dipantau : $env:UploadsDir"
Write-Host 'Tujuan          : galeri emulator SimpleAVD'
Write-Host 'Berhenti        : Ctrl+C'
Write-Host ''

Ensure-EmulatorRunning

Write-Host '==> Memantau folder uploads ...' -ForegroundColor Cyan

while ($true) {
  $files = @(Get-ChildItem -Path $env:UploadsDir -File -ErrorAction SilentlyContinue |
    Where-Object { $exts -contains $_.Extension.ToLower() })

  foreach ($f in $files) {
    Write-Host "==> Mengirim $($f.Name) ..."
    & $send -FilePath $f.FullName -Quiet
    if ($LASTEXITCODE -eq 0) {
      Move-Item $f.FullName (Join-Path $doneDir $f.Name) -Force
      Write-Host "    [OK] $($f.Name) terkirim ke emulator." -ForegroundColor Green
    } else {
      Write-Host "    [!!] Gagal mengirim $($f.Name); akan dicoba ulang otomatis." -ForegroundColor Yellow
      Start-Sleep -Seconds 10
    }
  }
  Start-Sleep -Seconds 5
}
