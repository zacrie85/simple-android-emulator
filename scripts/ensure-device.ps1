# =====================================================================
#  ensure-device.ps1 - Pastikan emulator berjalan & boot selesai.
#  Cara pakai : . (Join-Path $PSScriptRoot 'scripts\ensure-device.ps1')
#               lalu panggil fungsi Ensure-EmulatorRunning
#  Jika emulator belum menyala, script akan MENYALAKANNYA OTOMATIS
#  dan menunggu sampai boot selesai (maksimal 5 menit).
# =====================================================================

function Ensure-EmulatorRunning {
  $ErrorActionPreference = 'Continue'

  if (-not (Test-Path $env:AdbExe)) {
    Write-Host '[!!] ADB tidak ditemukan. Jalankan setup.bat terlebih dahulu.' -ForegroundColor Red
    exit 1
  }

  # Nyalakan server ADB (dibuat otomatis bila belum ada)
  & $env:AdbExe start-server 2>$null | Out-Null

  $state = ''
  try { $state = (& $env:AdbExe get-state 2>$null) } catch { $state = '' }

  if ("$state".Trim() -ne 'device') {
    Write-Host "==> Emulator belum berjalan. Menyalakan $($env:AvdName) ..." -ForegroundColor Cyan

    if (-not (Test-Path $env:EmulatorExe)) {
      Write-Host '[!!] emulator.exe tidak ditemukan. Jalankan setup.bat dulu.' -ForegroundColor Red
      exit 1
    }

    Start-Process -FilePath $env:EmulatorExe -ArgumentList "-avd $($env:AvdName)" | Out-Null
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
      Write-Host '[!!] Emulator tidak selesai boot dalam 5 menit.' -ForegroundColor Red
      Write-Host '     Jalankan start-emulator.bat untuk melihat pesan error,' -ForegroundColor Red
      Write-Host '     atau baca docs\panduan-lengkap.md untuk troubleshooting.' -ForegroundColor Red
      exit 1
    }
    Write-Host '    [OK] Emulator siap.' -ForegroundColor Green
  }
}
