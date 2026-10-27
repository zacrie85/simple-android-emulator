# =====================================================================
#  send-to-emulator.ps1 - Menyalin file video ke galeri emulator
#  Dipanggil otomatis dari menu klik-kanan Explorer
#  "Kirim ke Emulator Android", atau dipanggil manual:
#      powershell -File send-to-emulator.ps1 -FilePath "video.mp4"
#
#  Alur: pastikan emulator menyala -> adb push ke /sdcard/DCIM/
#  -> pemicu media scanner -> video muncul di galeri TikTok/SnackVideo
# =====================================================================
param(
  [Parameter(Mandatory = $true)]
  [string]$FilePath,
  [switch]$Quiet
)

$ErrorActionPreference = 'Continue'
. (Join-Path $PSScriptRoot 'scripts\env.ps1')
. (Join-Path $PSScriptRoot 'scripts\ensure-device.ps1')

Add-Type -AssemblyName System.Windows.Forms | Out-Null

function Show-Result([string]$msg, [string]$type) {
  if ($Quiet) { return }
  [System.Windows.Forms.MessageBox]::Show($msg, 'Kirim ke Emulator', 'OK', $type) | Out-Null
}

if (-not (Test-Path $FilePath)) {
  Show-Result "File tidak ditemukan:`n$FilePath" 'Error'
  exit 1
}

Ensure-EmulatorRunning

$remoteDir = '/sdcard/DCIM/SimpleUploads'
& $env:AdbExe shell mkdir -p $remoteDir | Out-Null

$name = Split-Path -Leaf $FilePath
Write-Host "==> Mengirim $name ..."
& $env:AdbExe push $FilePath "$remoteDir/$name" | Out-Null

if ($LASTEXITCODE -ne 0) {
  Show-Result "Gagal menyalin file ke emulator:`n$name`n`nPastikan emulator berjalan dan coba lagi." 'Error'
  exit 1
}

# Agar video langsung terlihat di galeri (Gallery / TikTok / SnackVideo)
& $env:AdbExe shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d "file://$remoteDir/$name" | Out-Null

$log = Join-Path $env:UploadsDir 'sent-log.txt'
Add-Content -Path $log -Value ("{0}  {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm'), $FilePath)

Write-Host "[OK] $name sudah masuk galeri emulator." -ForegroundColor Green
Show-Result "Video sudah masuk galeri emulator:`n$name`n`nBuka TikTok/SnackVideo lalu pilih upload." 'Information'
exit 0
