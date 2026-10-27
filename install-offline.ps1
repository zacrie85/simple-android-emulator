# =====================================================================
#  Simple Android Emulator - Instalasi OFFLINE (tanpa unduhan Google)
#
#  Paket offline terdiri dari 3 file zip dari halaman rilis GitHub:
#    offline-part1-app-java-cmdline.zip  (aplikasi + Java + tools SDK)
#    offline-part2-emulator-tools.zip    (emulator + platform-tools + AEHD)
#    offline-part3-system-image.zip      (system image Android 11)
#
#  Cara pakai:
#    1. Unduh 3 file tersebut ke satu folder (mis. Downloads)
#    2. Klik kanan part1 -> Extract All -> buka folder hasil extract
#    3. Double-click install-offline.bat
#       (part2 & part3 otomatis dicari, boleh tetap di Downloads)
#    4. Ikuti petunjuk di layar sampai selesai
# =====================================================================

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'scripts\env.ps1')

function Step([string]$m) { Write-Host "`n==> $m" -ForegroundColor Cyan }
function Ok([string]$m)   { Write-Host "    [OK] $m" -ForegroundColor Green }
function Warn([string]$m) { Write-Host "    [!!] $m" -ForegroundColor Yellow }
function Info([string]$m) { Write-Host "     $m" }

Write-Host '================================================='
Write-Host '  Simple Android Emulator - Instalasi OFFLINE'
Write-Host '  Nonton & upload video TikTok / SnackVideo'
Write-Host '================================================='
Write-Host ''
Write-Host '  Semua komponen sudah ada di 3 file zip - TIDAK ada'
Write-Host '  unduhan besar lagi. Satu-satunya langkah online'
Write-Host '  tersisa: unduh APK TikTok/SnackVideo (opsional, akhir).'

# -------------------------------------------------------------------
Step '1/6  Pemeriksaan singkat'
# -------------------------------------------------------------------
$repoDrive = (Split-Path -Qualifier $env:RepoRoot).TrimEnd(':')
$freeGb = [math]::Round((Get-PSDrive -Name $repoDrive).Free / 1GB, 1)
Info "Folder aplikasi      : $env:RepoRoot"
Info "Ruang kosong ${repoDrive}:    : $freeGb GB"
if ($freeGb -lt 5) {
  Warn 'Ruang kosong di bawah 5 GB. Ekstraksi system image bisa gagal.'
} else {
  Ok "Ruang disk cukup ($freeGb GB bebas, butuh sekitar 4 GB)."
}

# -------------------------------------------------------------------
Step '2/6  Mencari paket offline (part 2 & part 3)'
# -------------------------------------------------------------------
$searchDirs = @(
  $env:RepoRoot,
  (Split-Path -Parent $env:RepoRoot),
  (Join-Path $env:USERPROFILE 'Downloads'),
  (Join-Path $env:USERPROFILE 'Desktop')
) | Select-Object -Unique

function Find-Part([string]$pattern) {
  foreach ($d in $searchDirs) {
    if (-not (Test-Path $d)) { continue }
    $hit = Get-ChildItem -Path $d -Filter $pattern -File -ErrorAction SilentlyContinue |
      Sort-Object Name | Select-Object -First 1
    if ($hit) { return $hit.FullName }
  }
  return $null
}

$part2 = Find-Part 'offline-part2-*.zip'
$part3 = Find-Part 'offline-part3-*.zip'
if (-not $part2 -or -not $part3) {
  Write-Host ''
  Warn 'Paket offline part 2 / part 3 tidak ditemukan!'
  Info 'Letakkan offline-part2-*.zip dan offline-part3-*.zip di:'
  Info "  - folder ini ($env:RepoRoot), ATAU"
  Info '  - folder Downloads / Desktop kamu'
  Info 'lalu jalankan lagi install-offline.bat.'
  Write-Host ''
  Read-Host '     Tekan Enter untuk menutup'
  throw 'Paket offline belum lengkap.'
}
Info "Part 2 : $(Split-Path -Leaf $part2)"
Info "Part 3 : $(Split-Path -Leaf $part3)"

# -------------------------------------------------------------------
Step '3/6  Mengekstrak emulator & system image (5-15 menit, sabar ya)'
# -------------------------------------------------------------------
function Expand-Fast([string]$zip) {
  $tar = Get-Command tar.exe -ErrorAction SilentlyContinue
  if ($tar) {
    Info "Ekstrak (tar cepat): $(Split-Path -Leaf $zip) ..."
    & $tar -xf $zip -C $env:RepoRoot
    if ($LASTEXITCODE -ne 0) { throw "Gagal mengekstrak $zip" }
  } else {
    Info "Ekstrak (mode lambat): $(Split-Path -Leaf $zip) ..."
    $ProgressPreference = 'SilentlyContinue'
    Expand-Archive -Path $zip -DestinationPath $env:RepoRoot -Force
    $ProgressPreference = 'Continue'
  }
}

$imgDir = Join-Path $env:SdkDir 'system-images\android-30\google_apis\x86_64'

if ((Test-Path $env:EmulatorExe) -and (Test-Path $env:AdbExe)) {
  Ok 'Emulator & platform-tools sudah ada, dilewati.'
} else {
  Expand-Fast $part2
  Ok 'Part 2 selesai diekstrak (emulator + platform-tools + AEHD).'
}

if (Test-Path (Join-Path $imgDir 'source.properties')) {
  Ok 'System image Android 11 sudah ada, dilewati.'
} else {
  Expand-Fast $part3
  Ok 'Part 3 selesai diekstrak (system image Android 11).'
}

if (-not (Test-Path $env:EmulatorExe)) { throw "File emulator tidak ditemukan: $env:EmulatorExe" }
if (-not (Test-Path $env:AdbExe))      { throw "ADB tidak ditemukan: $env:AdbExe" }
if (-not (Test-Path (Join-Path $imgDir 'source.properties'))) { throw "System image tidak ditemukan: $imgDir" }
Ok 'Semua komponen terverifikasi.'

# -------------------------------------------------------------------
Step '4/6  Membuat perangkat virtual "SimpleAVD" (Android 11)'
# -------------------------------------------------------------------
# Lisensi SDK (sudah ikut di paket; ditulis ulang sekalian jaga-jaga)
$licDir = Join-Path $env:SdkDir 'licenses'
if (-not (Test-Path (Join-Path $licDir 'android-sdk-license'))) {
  New-Item -ItemType Directory -Path $licDir -Force | Out-Null
  Set-Content -Path (Join-Path $licDir 'android-sdk-license') -Encoding Ascii -Value @(
    '24333f8a63b6825ea9c5514f83c2829b004d1fee'
    'd56f5187479451eabf01fb78af6dfcb131a6481e'
    '8933bad161af4178b1185d1a37fbf41ea5269c55'
  )
  Set-Content -Path (Join-Path $licDir 'android-sdk-preview-license') -Encoding Ascii -Value '84831b9409646a918e30573bab4c9c91346d8abd'
}

$avdCfg = Join-Path $env:AvdHome "$($env:AvdName).avd\config.ini"
if (Test-Path $avdCfg) {
  Ok 'AVD sudah ada, dilewati.'
} else {
  if (-not (Test-Path $env:AvdManager)) { throw "avdmanager tidak ditemukan: $env:AvdManager (part1 terekstrak dengan benar?)" }
  $oldEap = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  $avdLog = Join-Path $env:ToolsDir 'setup-avd.log'
  Info 'Membuat AVD offline (tanpa internet) ...'
  'no' | & $env:AvdManager create avd -n $env:AvdName -k 'system-images;android-30;google_apis;x86_64' -d pixel_4 --force 2>&1 | Out-File $avdLog -Encoding UTF8
  if ($LASTEXITCODE -ne 0) {
    Warn '----- 10 baris terakhir log pembuatan AVD -----'
    Get-Content $avdLog -Tail 10 | ForEach-Object { Info $_ }
    Warn '-----------------------------------------------'
    $ErrorActionPreference = $oldEap
    throw "Gagal membuat AVD. Kirim isi $avdLog ke asisten untuk dianalisis."
  }
  $ErrorActionPreference = $oldEap
  Add-Content -Path $avdCfg -Value 'hw.ramSize=2048'
  Add-Content -Path $avdCfg -Value 'hw.keyboard=yes'
  Add-Content -Path $avdCfg -Value 'disk.dataPartition.size=8192M'
  Add-Content -Path $avdCfg -Value 'hw.gpu.enabled=yes'
  Add-Content -Path $avdCfg -Value 'hw.gpu.mode=auto'
  Ok 'AVD dibuat: SimpleAVD (Android 11, RAM 2 GB, disk 8 GB)'
}

# -------------------------------------------------------------------
Step '5/6  Driver akselerasi AEHD (opsional, izin admin 1x)'
# -------------------------------------------------------------------
$aehdSilent = Join-Path $env:SdkDir 'extras\google\Android_Emulator_Hypervisor_Driver\silent_install.bat'
if (Test-Path $aehdSilent) {
  try {
    Info 'Akan muncul jendela UAC (izin admin). Klik Yes.'
    Start-Process -FilePath $aehdSilent -Verb RunAs -Wait
    Ok 'Driver AEHD terpasang. Emulator akan berjalan cepat.'
  } catch {
    Warn 'Pemasangan AEHD dibatalkan/gagal.'
    $ans = Read-Host '     Aktifkan alternatif WHPX (fitur Windows) sekarang? [Y/n]'
    if ($ans -notmatch '^(n|N)') {
      Start-Process powershell -Verb RunAs -Wait -ArgumentList '-NoProfile', '-Command', 'dism /online /enable-feature /featurename:HypervisorPlatform /norestart; dism /online /enable-feature /featurename:VirtualMachinePlatform /norestart'
      Warn 'Fitur WHPX diminta. Jika diminta restart, restart PC lalu jalankan lagi start-emulator.bat.'
    }
  }
} else {
  Warn 'Paket AEHD tidak ditemukan. Emulator akan mencoba WHPX bawaan Windows.'
}

# -------------------------------------------------------------------
Step '6/6  Integrasi Windows Explorer & aplikasi'
# -------------------------------------------------------------------
$ans = Read-Host '     Tambah menu klik-kanan "Kirim ke Emulator" di Explorer? [Y/n]'
if ($ans -notmatch '^(n|N)') {
  & (Join-Path $env:RepoRoot 'add-explorer-menu.ps1')
  Ok 'Menu klik-kanan aktif.'
}

$apkCount = @(Get-ChildItem -Path $env:ApksDir -Filter '*.apk' -ErrorAction SilentlyContinue).Count
$installApks = $false
if ($apkCount -gt 0) {
  Info "$apkCount file APK sudah ada di folder apks\."
  $ans = Read-Host '     Pasang APK ke emulator setelah menyala? [Y/n]'
  if ($ans -notmatch '^(n|N)') { $installApks = $true }
} else {
  Info 'Folder apks\ masih kosong.'
  Info 'Catatan: APK TikTok/SnackVideo tidak ikut di paket (hak cipta).'
  $ans = Read-Host '     Buka halaman unduh resmi TikTok & SnackVideo sekarang? [Y/n]'
  if ($ans -notmatch '^(n|N)') {
    & (Join-Path $env:RepoRoot 'download-apks.ps1')
    Info 'Setelah APK tersimpan di folder apks\, jalankan install-apks.bat.'
  }
}

$ans = Read-Host '     Nyalakan emulator sekarang? [Y/n]'
if ($ans -notmatch '^(n|N)') {
  & (Join-Path $env:RepoRoot 'start-emulator.ps1')
  if ($installApks) { & (Join-Path $env:RepoRoot 'install-apks.ps1') }
}

# -------------------------------------------------------------------
Write-Host ''
Write-Host '=================================================' -ForegroundColor Green
Write-Host '  Instalasi OFFLINE selesai!' -ForegroundColor Green
Write-Host '=================================================' -ForegroundColor Green
Write-Host ''
Write-Host '  Ringkasan perintah (double-click file .bat):'
Write-Host '   start-emulator.bat      -> menyalakan Android'
Write-Host '   helper-upload.bat       -> bantu upload: deskripsi + hashtag'
Write-Host '   install-apks.bat        -> pasang APK dari folder apks\'
Write-Host '   add-explorer-menu.bat   -> klik kanan video = upload'
Write-Host '   watch-uploads.bat       -> mode folder upload otomatis'
Write-Host '   uninstall.bat           -> bersih-bersih total'
Write-Host ''
Write-Host '  Selamat nonton & upload! Baca README.md untuk detail.' -ForegroundColor Cyan
