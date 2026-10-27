# =====================================================================
#  helper-upload.ps1 - Helper Upload SnackVideo & TikTok
#
#  Jendela kecil di Windows berisi kolom Deskripsi & Hashtag.
#  Alur:
#   1. Pilih video -> klik "Kirim Video ke Emulator"
#   2. Di emulator: buka SnackVideo/TikTok -> Upload -> pilih video
#   3. Tap kolom deskripsi di aplikasi (kursor berkedip)
#   4. Klik "Ketik Deskripsi + Hashtag" -> teks muncul otomatis
#      (termasuk emoji, via keyboard helper open source ADBKeyboard)
#
#  Jalankan lewat helper-upload.bat
# =====================================================================

$ErrorActionPreference = 'Continue'
. (Join-Path $PSScriptRoot 'scripts\env.ps1')
. (Join-Path $PSScriptRoot 'scripts\ensure-device.ps1')

Add-Type -AssemblyName System.Windows.Forms | Out-Null
Add-Type -AssemblyName System.Drawing | Out-Null
[System.Windows.Forms.Application]::EnableVisualStyles()

# ---------------- log status ----------------
$script:txtStatus = $null
function Write-Status([string]$m) {
  if ($null -ne $script:txtStatus) {
    $stamp = Get-Date -Format 'HH:mm'
    $script:txtStatus.AppendText("[$stamp] $m`r`n")
    $script:txtStatus.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
  }
}

# ---------------- keyboard helper (ADBKeyboard, MIT, 18 KB) ----------------
function Ensure-AdbKeyboard {
  $imeList = ''
  try { $imeList = (& $env:AdbExe shell ime list -s 2>$null) -join ' ' } catch { $imeList = '' }
  if ("$imeList" -match 'com\.android\.adbkeyboard') {
    & $env:AdbExe shell ime set com.android.adbkeyboard/.AdbIME | Out-Null
    return $true
  }

  $apk = Join-Path $env:ToolsDir 'ADBKeyboard.apk'
  if (-not (Test-Path $apk)) {
    try {
      Write-Status 'Mengunduh keyboard helper (18 KB, sekali saja) ...'
      $ProgressPreference = 'SilentlyContinue'
      Invoke-WebRequest -Uri 'https://github.com/senzhk/ADBKeyBoard/raw/master/ADBKeyboard.apk' -OutFile $apk -UseBasicParsing
      $ProgressPreference = 'Continue'
    } catch {
      $ProgressPreference = 'Continue'
      return $false
    }
  }

  Write-Status 'Memasang keyboard helper di emulator ...'
  & $env:AdbExe install -r $apk | Out-Null
  & $env:AdbExe shell ime enable com.android.adbkeyboard/.AdbIME | Out-Null
  & $env:AdbExe shell ime set com.android.adbkeyboard/.AdbIME | Out-Null

  $chk = ''
  try { $chk = (& $env:AdbExe shell ime list -s 2>$null) -join ' ' } catch { $chk = '' }
  return ("$chk" -match 'com\.android\.adbkeyboard')
}

# Mode cadangan tanpa keyboard helper (karakter khusus dibuang)
function Send-TextFallback([string]$text) {
  $i = 0
  foreach ($line in ($text -split "`n")) {
    if ($i -gt 0) { & $env:AdbExe shell input keyevent 66 | Out-Null }
    $esc = $line -replace '\r', ''
    $esc = $esc -replace '[^\w#@.,!?\-\s]', ''
    $esc = $esc -replace ' ', '%s'
    if ($esc -ne '') { & $env:AdbExe shell input text $esc | Out-Null }
    $i++
  }
}

# Gabungkan deskripsi + hashtag (tanda # ditambah otomatis)
function Compose-Caption {
  $desc = $script:txtDesc.Text.Trim()
  $tags = @()
  foreach ($t in ($script:txtTags.Text -split '\s+')) {
    $t = $t.Trim()
    if ($t -eq '') { continue }
    if (-not $t.StartsWith('#')) { $t = '#' + $t }
    $tags += $t
  }
  $full = $desc
  if ($tags.Count -gt 0) {
    if ($full -ne '') { $full += "`n" }
    $full += ($tags -join ' ')
  }
  return $full
}

# ---------------- bangun jendela ----------------
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Helper Upload - SnackVideo & TikTok'
$form.Size = New-Object System.Drawing.Size(620, 665)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedSingle'
$form.MaximizeBox = $false

$font = New-Object System.Drawing.Font('Segoe UI', 10)

function Add-Label([string]$text, [int]$x, [int]$y) {
  $l = New-Object System.Windows.Forms.Label
  $l.Text = $text
  $l.Location = New-Object System.Drawing.Point($x, $y)
  $l.AutoSize = $true
  $l.Font = $font
  $form.Controls.Add($l)
  return $l
}

function Add-Button([string]$text, [int]$x, [int]$y, [int]$w) {
  $b = New-Object System.Windows.Forms.Button
  $b.Text = $text
  $b.Location = New-Object System.Drawing.Point($x, $y)
  $b.Size = New-Object System.Drawing.Size($w, 34)
  $b.Font = $font
  $form.Controls.Add($b)
  return $b
}

Add-Label 'Video yang mau diupload:' 15 15 | Out-Null
$script:txtVideo = New-Object System.Windows.Forms.TextBox
$script:txtVideo.Location = New-Object System.Drawing.Point(15, 35)
$script:txtVideo.Size = New-Object System.Drawing.Size(475, 26)
$script:txtVideo.ReadOnly = $true
$script:txtVideo.Font = $font
$form.Controls.Add($script:txtVideo)

$btnPilih = Add-Button 'Pilih...' 500 34 85
$btnKirim = Add-Button '1. Kirim Video ke Emulator' 15 72 570

Add-Label 'Deskripsi (caption):' 15 118 | Out-Null
$script:txtDesc = New-Object System.Windows.Forms.TextBox
$script:txtDesc.Location = New-Object System.Drawing.Point(15, 138)
$script:txtDesc.Size = New-Object System.Drawing.Size(570, 110)
$script:txtDesc.Multiline = $true
$script:txtDesc.ScrollBars = 'Vertical'
$script:txtDesc.Font = $font
$form.Controls.Add($script:txtDesc)

Add-Label 'Hashtag (pisahkan dengan spasi, tanda # ditambah otomatis):' 15 258 | Out-Null
$script:txtTags = New-Object System.Windows.Forms.TextBox
$script:txtTags.Location = New-Object System.Drawing.Point(15, 278)
$script:txtTags.Size = New-Object System.Drawing.Size(570, 26)
$script:txtTags.Font = $font
$form.Controls.Add($script:txtTags)

$btnKetik = Add-Button '2. Ketik Deskripsi + Hashtag ke Aplikasi di Emulator' 15 316 570

$lblPanduan = New-Object System.Windows.Forms.Label
$lblPanduan.Location = New-Object System.Drawing.Point(15, 362)
$lblPanduan.Size = New-Object System.Drawing.Size(570, 60)
$lblPanduan.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$lblPanduan.ForeColor = [System.Drawing.Color]::DimGray
$lblPanduan.Text = 'Cara pakai: 1) Kirim video  2) Di emulator buka SnackVideo/TikTok -> tombol Upload (+) -> pilih videonya  3) Tap kolom deskripsi sampai kursor berkedip  4) Klik tombol nomor 2 di atas  5) Cek teksnya, lalu klik Post/Upload.'
$form.Controls.Add($lblPanduan)

$btnSalin = Add-Button 'Salin teks ke Clipboard PC (cadangan)' 15 428 570

$script:txtStatus = New-Object System.Windows.Forms.RichTextBox
$script:txtStatus.Location = New-Object System.Drawing.Point(15, 472)
$script:txtStatus.Size = New-Object System.Drawing.Size(570, 135)
$script:txtStatus.ReadOnly = $true
$script:txtStatus.BackColor = [System.Drawing.Color]::White
$script:txtStatus.Font = New-Object System.Drawing.Font('Consolas', 9)
$form.Controls.Add($script:txtStatus)

# ---------------- aksi tombol ----------------
$btnPilih.Add_Click({
  $dlg = New-Object System.Windows.Forms.OpenFileDialog
  $dlg.Filter = 'Video|*.mp4;*.mov;*.mkv;*.avi;*.webm;*.m4v|Semua file|*.*'
  if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    $script:txtVideo.Text = $dlg.FileName
  }
})

$btnKirim.Add_Click({
  $v = $script:txtVideo.Text
  if ($v -eq '' -or -not (Test-Path $v)) {
    Write-Status '[!!] Pilih file video dulu.'
    return
  }
  Write-Status "Mengirim $(Split-Path -Leaf $v) ke emulator (tunggu sampai selesai) ..."
  & (Join-Path $env:RepoRoot 'send-to-emulator.ps1') -FilePath $v -Quiet | Out-Null
  if ($LASTEXITCODE -eq 0) {
    Write-Status '[OK] Video masuk galeri emulator. Lanjut: buka SnackVideo/TikTok -> Upload -> pilih video.'
  } else {
    Write-Status '[!!] Gagal. Pastikan setup.bat sudah selesai & emulator bisa menyala (start-emulator.bat).'
  }
})

$btnKetik.Add_Click({
  $full = Compose-Caption
  if ($full -eq '') {
    Write-Status '[!!] Isi deskripsi dan/atau hashtag dulu.'
    return
  }
  $full = $full -replace '\r', ''

  if (-not (Test-Path $env:AdbExe)) {
    Write-Status '[!!] ADB tidak ditemukan. Jalankan setup.bat dulu.'
    return
  }
  Write-Status 'Menyambung ke emulator (menyalakan bila perlu) ...'
  Ensure-EmulatorRunning

  $prev = ''
  try { $prev = ("$(& $env:AdbExe shell settings get secure default_input_method 2>$null)").Trim() } catch { $prev = '' }

  $ok = Ensure-AdbKeyboard
  if ($ok) {
    Write-Status 'Mengetik ke kolom yang sedang aktif di emulator ...'
    $b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($full))
    & $env:AdbExe shell am broadcast -a ADB_INPUT_B64 --es msg $b64 | Out-Null
    Start-Sleep -Seconds 1
    if ($prev -and $prev -ne 'com.android.adbkeyboard/.AdbIME') {
      & $env:AdbExe shell ime set $prev | Out-Null
    }
    Write-Status '[OK] Teks sudah diketik! Cek kolom deskripsi, sesuaikan bila perlu, lalu Post/Upload.'
  } else {
    Write-Status 'Keyboard helper tidak tersedia (offline?) -> mode cadangan tanpa emoji ...'
    Send-TextFallback $full
    Write-Status '[OK] Mode cadangan selesai (emoji & karakter khusus dibuang).'
  }
})

$btnSalin.Add_Click({
  $full = Compose-Caption
  if ($full -eq '') { Write-Status '[!!] Belum ada teks untuk disalin.'; return }
  try {
    [System.Windows.Forms.Clipboard]::SetText($full)
    Write-Status '[OK] Teks tersalin ke clipboard PC (untuk ditempel manual).'
  } catch {
    Write-Status '[!!] Gagal menyalin ke clipboard.'
  }
})

Write-Status 'Selamat datang! Pilih video, kirim, lalu ikuti langkah panduan di atas.'
$form.ShowDialog() | Out-Null
