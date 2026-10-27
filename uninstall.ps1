# =====================================================================
#  uninstall.ps1 - Menghapus SEMUA komponen yang dipasang:
#   - Emulator yang sedang berjalan dimatikan
#   - Menu klik-kanan Explorer
#   - AVD SimpleAVD (data aplikasi & video di emulator ikut hilang)
#   - Folder tools\ (JDK + Android SDK, sekitar 6-10 GB)
#
#  TIDAK dihapus: folder proyek, apks\, uploads\
# =====================================================================

$ErrorActionPreference = 'Continue'
. (Join-Path $PSScriptRoot 'scripts\env.ps1')

Write-Host '==> Mematikan emulator bila sedang berjalan ...'
Get-Process -Name 'emulator', 'qemu-system-x86_64' -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

Write-Host '==> Menghapus menu klik-kanan Explorer ...'
& (Join-Path $env:RepoRoot 'remove-explorer-menu.ps1') | Out-Null

if (Test-Path $env:AvdHome) {
  Write-Host '==> Menghapus AVD (data emulator) ...'
  Remove-Item $env:AvdHome -Recurse -Force -ErrorAction SilentlyContinue
}

if (Test-Path $env:ToolsDir) {
  Write-Host "==> Menghapus tools (JDK + Android SDK): $env:ToolsDir ..."
  Remove-Item $env:ToolsDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ''
Write-Host '[OK] Semua komponen sudah dihapus.' -ForegroundColor Green
Write-Host '     Folder proyek, apks\, dan uploads\ tetap ada.'
Write-Host '     Hapus folder proyek ini manual bila ingin bersih total.'
