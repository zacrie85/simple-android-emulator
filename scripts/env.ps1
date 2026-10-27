# =====================================================================
#  env.ps1 - Konfigurasi lingkungan bersama untuk semua script
#  Cara pakai : . (Join-Path $PSScriptRoot 'scripts\env.ps1')
#  Semua komponen diinstal ke folder tools\ agar PORTABLE
#  (bisa dipindah-pindah, tidak menyebar ke C:\Program Files)
# =====================================================================

$env:RepoRoot      = Split-Path -Parent $PSScriptRoot
$env:ToolsDir      = Join-Path $env:RepoRoot 'tools'
$env:JdkDir        = Join-Path $env:ToolsDir 'jdk'
$env:SdkDir        = Join-Path $env:ToolsDir 'android-sdk'
$env:AvdHome       = Join-Path $env:ToolsDir 'avd'
$env:PlatformTools = Join-Path $env:SdkDir 'platform-tools'
$env:EmulatorExe   = Join-Path $env:SdkDir 'emulator\emulator.exe'
$env:AdbExe        = Join-Path $env:PlatformTools 'adb.exe'
$env:SdkManager    = Join-Path $env:SdkDir 'cmdline-tools\latest\bin\sdkmanager.bat'
$env:AvdManager    = Join-Path $env:SdkDir 'cmdline-tools\latest\bin\avdmanager.bat'
$env:ApksDir       = Join-Path $env:RepoRoot 'apks'
$env:UploadsDir    = Join-Path $env:RepoRoot 'uploads'
$env:AvdName       = 'SimpleAVD'

# Java lokal (dipasang oleh setup.ps1)
if (Test-Path (Join-Path $env:JdkDir 'bin\java.exe')) {
  $env:JAVA_HOME = $env:JdkDir
}

# Android SDK lokal
$env:ANDROID_SDK_ROOT  = $env:SdkDir
$env:ANDROID_AVD_HOME  = $env:AvdHome
$env:ANDROID_USER_HOME = Join-Path $env:ToolsDir 'android-user'

if (-not (Test-Path $env:AvdHome)) {
  New-Item -ItemType Directory -Path $env:AvdHome -Force | Out-Null
}
if (-not (Test-Path $env:UploadsDir)) {
  New-Item -ItemType Directory -Path $env:UploadsDir -Force | Out-Null
}
