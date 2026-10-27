# =====================================================================
#  Simple Android Emulator - Setup Satu Klik (Windows 10/11 64-bit)
#
#  Yang dilakukan script ini:
#   1. Memeriksa RAM, disk, dan virtualisasi
#   2. Mengunduh & memasang JRE 17 (Temurin, hanya 50 MB) ke tools\jdk
#   3. Mengunduh Android cmdline-tools resmi dari dl.google.com
#   4. Mengunduh Android SDK Emulator + system image Android 9
#      (API 28, google_apis, x86_64) + driver akselerasi AEHD
#      Total unduhan hanya sekitar 1,5 GB
#   5. Memasang driver akselerasi (butuh izin admin sekali)
#   6. Membuat perangkat virtual (AVD) bernama "SimpleAVD"
#   7. Menawarkan menu klik-kanan Explorer & menyalakan emulator
#
#  Total unduhan sekitar 2-3 GB, cukup SEKALI saja.
#  Jalankan ulang setup.bat kapan saja untuk melanjutkan langkah
#  yang belum selesai (yang sudah selesai akan dilewati).
# =====================================================================

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'scripts\env.ps1')

function Step([string]$m) { Write-Host "`n==> $m" -ForegroundColor Cyan }
function Ok([string]$m)   { Write-Host "    [OK] $m" -ForegroundColor Green }
function Warn([string]$m) { Write-Host "    [!!] $m" -ForegroundColor Yellow }
function Info([string]$m) { Write-Host "     $m" }

function Download-File([string]$Url, [string]$Out) {
  $ProgressPreference = 'SilentlyContinue'
  Invoke-WebRequest -Uri $Url -OutFile $Out -UseBasicParsing
  $ProgressPreference = 'Continue'
}

Write-Host '================================================='
Write-Host '  Simple Android Emulator - Setup Satu Klik'
Write-Host '  Nonton & upload video TikTok / SnackVideo'
Write-Host '================================================='

# -------------------------------------------------------------------
Step '1/7  Memeriksa sistem'
# -------------------------------------------------------------------
$cs = Get-CimInstance Win32_ComputerSystem
$ramGb = [math]::Round($cs.TotalPhysicalMemory / 1GB, 1)
Info "RAM terdeteksi           : $ramGb GB"
if ($ramGb -lt 7.5) { Warn 'RAM di bawah 8 GB. Emulator mungkin terasa berat.' }

$driveLetter = $env:SystemDrive.TrimEnd(':')
$freeGb = [math]::Round((Get-PSDrive -Name $driveLetter).Free / 1GB, 1)
Info "Ruang kosong $($env:SystemDrive)      : $freeGb GB"
if ($freeGb -lt 10) { Warn 'Ruang kosong di bawah 10 GB. Unduhan bisa gagal.' }

$cpu = Get-CimInstance Win32_Processor
Info "Prosesor                 : $($cpu.Name)"
$virtOn = $cs.HypervisorPresent
Info "Virtualisasi terdeteksi  : $virtOn"
if (-not $virtOn) {
  Warn 'Virtualisasi belum aktif. Jika nanti emulator gagal menyala:'
  Info ' - Aktifkan VT-x / AMD-V (SVM) di BIOS/UEFI'
  Info ' - Cek docs\panduan-lengkap.md bagian "Emulator gagal menyala"'
}

# -------------------------------------------------------------------
Step '2/7  Menyiapkan Java (JRE 17 Temurin)'
# -------------------------------------------------------------------
if (Test-Path (Join-Path $env:JdkDir 'bin\java.exe')) {
  Ok 'Java sudah terpasang, dilewati.'
} else {
  New-Item -ItemType Directory -Path $env:ToolsDir -Force | Out-Null
  $jdkZip = Join-Path $env:ToolsDir 'jre17.zip'
  Info 'Mengunduh JRE 17 (~50 MB) dari adoptium.net ...'
  Download-File 'https://api.adoptium.net/v3/binary/latest/17/ga/windows/x64/jre/hotspot/normal/eclipse?project=jdk' $jdkZip
  $tmp = Join-Path $env:ToolsDir '_jdk'
  Expand-Archive -Path $jdkZip -DestinationPath $tmp -Force
  $inner = Get-ChildItem -Path $tmp | Select-Object -First 1
  Move-Item $inner.FullName $env:JdkDir
  Remove-Item $tmp -Recurse -Force
  Remove-Item $jdkZip -Force
  Ok "Java terpasang di $env:JdkDir"
}

# -------------------------------------------------------------------
Step '3/7  Menyiapkan Android cmdline-tools'
# -------------------------------------------------------------------
if (Test-Path $env:SdkManager) {
  Ok 'cmdline-tools sudah ada, dilewati.'
} else {
  $ctZip = Join-Path $env:ToolsDir 'cmdline-tools.zip'
  $urls = @(
    'https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip',
    'https://dl.google.com/android/repository/commandlinetools-win-13114758_latest.zip'
  )
  $done = $false
  foreach ($u in $urls) {
    try {
      Info 'Mengunduh cmdline-tools dari dl.google.com ...'
      Download-File $u $ctZip
      $done = $true
      break
    } catch {
      Warn "Gagal mengunduh dari $u"
    }
  }
  if (-not $done) { throw 'Gagal mengunduh cmdline-tools. Periksa koneksi internet lalu jalankan ulang setup.bat.' }

  $ctTmp = Join-Path $env:ToolsDir '_ct'
  Expand-Archive -Path $ctZip -DestinationPath $ctTmp -Force
  $dest = Join-Path $env:SdkDir 'cmdline-tools'
  New-Item -ItemType Directory -Path $dest -Force | Out-Null
  Move-Item (Join-Path $ctTmp 'cmdline-tools') (Join-Path $dest 'latest')
  Remove-Item $ctTmp -Recurse -Force
  Remove-Item $ctZip -Force
  Ok 'cmdline-tools terpasang.'
}

# -------------------------------------------------------------------
Step '4/7  Mengunduh komponen Android SDK (sekitar 1,5 GB, mohon sabar)'
# -------------------------------------------------------------------
if (-not (Test-Path (Join-Path $env:SdkDir 'emulator\emulator.exe'))) {
  $oldEap = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'

  # Terima lisensi SDK secara DETERMINISTIK lewat file lisensi
  # (metode yang sama dengan CI/CD resmi - tidak tergantung stdin
  #  yang kadang gagal dibaca sdkmanager di PowerShell 5.1)
  Info 'Menerima lisensi SDK (file lisensi otomatis) ...'
  $licDir = Join-Path $env:SdkDir 'licenses'
  New-Item -ItemType Directory -Path $licDir -Force | Out-Null
  Set-Content -Path (Join-Path $licDir 'android-sdk-license') -Encoding Ascii -Value @(
    '24333f8a63b6825ea9c5514f83c2829b004d1fee'
    'd56f5187479451eabf01fb78af6dfcb131a6481e'
    '8933bad161af4178b1185d1a37fbf41ea5269c55'
  )
  Set-Content -Path (Join-Path $licDir 'android-sdk-preview-license') -Encoding Ascii -Value '84831b9409646a918e30573bab4c9c91346d8abd'
  Ok 'Lisensi SDK diterima.'

  $logPath = Join-Path $env:ToolsDir 'setup-sdk.log'
  $pkgs = @(
    'platform-tools',
    'emulator',
    'system-images;android-28;google_apis;x86_64',
    'extras;google;Android_Emulator_Hypervisor_Driver'
  )
  Info "Mengunduh: $($pkgs -join ', ')"
  Info 'Ini butuh 5-20 menit tergantung kecepatan internet. Tunggu sampai selesai.'

  & $env:SdkManager --install $pkgs 2>&1 | Out-File $logPath -Encoding UTF8

  if ($LASTEXITCODE -ne 0) {
    Warn 'Instalasi gabungan gagal; mencoba satu per satu biar ketahuan paket bermasalahnya ...'
    $failed = @()
    foreach ($p in $pkgs) {
      Info "Memasang $p ..."
      & $env:SdkManager --install $p 2>&1 | Out-File $logPath -Append -Encoding UTF8
      if ($LASTEXITCODE -ne 0) {
        if ($p -eq 'extras;google;Android_Emulator_Hypervisor_Driver') {
          Warn 'AEHD gagal (opsional; emulator tetap bisa jalan via WHPX). Melanjutkan ...'
        } else {
          $failed += $p
        }
      }
    }
    if ($failed.Count -gt 0) {
      Warn "Paket yang gagal: $($failed -join ', ')"
      Warn '----- 10 baris terakhir log -----'
      Get-Content $logPath -Tail 10 | ForEach-Object { Info $_ }
      Warn '---------------------------------'
      $ErrorActionPreference = $oldEap
      throw "Instalasi SDK gagal. Buka $logPath lalu kirim 10 baris terakhirnya ke asisten untuk dianalisis."
    }
  }
  $ErrorActionPreference = $oldEap
  Ok 'Komponen Android SDK terpasang.'
} else {
  Ok 'Komponen SDK sudah ada, dilewati.'
}

# -------------------------------------------------------------------
Step '5/7  Memasang driver akselerasi AEHD (izin admin 1x)'
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
Step '6/7  Membuat perangkat virtual "SimpleAVD" (Android 9)'
# -------------------------------------------------------------------
$avdCfg = Join-Path $env:AvdHome "$($env:AvdName).avd\config.ini"
if (Test-Path $avdCfg) {
  Ok 'AVD sudah ada, dilewati.'
} else {
  $oldEap = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  $avdLog = Join-Path $env:ToolsDir 'setup-avd.log'
  'no' | & $env:AvdManager create avd -n $env:AvdName -k 'system-images;android-28;google_apis;x86_64' -d pixel_4 --force 2>&1 | Out-File $avdLog -Encoding UTF8
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
  Ok 'AVD dibuat: SimpleAVD (Android 9, RAM 2 GB, disk 8 GB)'
}

# -------------------------------------------------------------------
Step '7/7  Integrasi Windows Explorer & aplikasi'
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
Write-Host '  Setup selesai!' -ForegroundColor Green
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
