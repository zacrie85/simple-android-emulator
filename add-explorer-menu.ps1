# =====================================================================
#  add-explorer-menu.ps1 - Menambah menu klik-kanan di Windows Explorer:
#      "Kirim ke Emulator Android"
#  Memakai registry HKCU (HANYA untuk user ini, tidak perlu admin).
#  Aman: tidak mengubah apa pun selain satu kunci menu.
# =====================================================================

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'scripts\env.ps1')

$send = Join-Path $env:RepoRoot 'send-to-emulator.ps1'
$base = 'HKCU:\Software\Classes\*\shell\KirimKeEmulator'

# Hapus sisa instalasi lama (kalau ada) supaya idempoten
if (Test-Path $base) { Remove-Item $base -Recurse -Force }

New-Item -Path $base -Force | Out-Null
New-ItemProperty -Path $base -Name 'MUIVerb' -Value 'Kirim ke Emulator Android' -PropertyType String -Force | Out-Null

New-Item -Path "$base\command" -Force | Out-Null
$cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$send`" -FilePath `"%1`""
New-ItemProperty -Path "$base\command" -Name '(Default)' -Value $cmd -PropertyType String -Force | Out-Null

# Simpan lokasi instalasi untuk uninstall
New-Item -Path 'HKCU:\Software\SimpleAndroidEmulator' -Force | Out-Null
New-ItemProperty -Path 'HKCU:\Software\SimpleAndroidEmulator' -Name 'InstallPath' -Value $env:RepoRoot -PropertyType String -Force | Out-Null

Write-Host '[OK] Menu klik-kanan "Kirim ke Emulator" sudah aktif.' -ForegroundColor Green
Write-Host '     Coba: klik kanan file video (.mp4) di Windows Explorer.'
