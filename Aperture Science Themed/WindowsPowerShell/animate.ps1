# =============================================================================
#  GLaDOS Terminal Animation
#  - ASCII logo: glyphs randomize every 0.5s   (@  M  X  H  %  $  #)
#  - Progress bars: | glides across slash region every 0.2s
#  - Side text beside every row is never touched
# =============================================================================

# ---------------------------------------------------------------------------
# Window height  -  30 rows for PowerShell terminal, 31 rows for CMD
# Detect parent process using .NET System.Diagnostics.Process — no WMI/CIM,
# resolves instantly compared to Get-CimInstance Win32_Process.
# ---------------------------------------------------------------------------
try {
    $parentName   = [System.Diagnostics.Process]::GetProcessById($PID).Parent.ProcessName
    $targetHeight = if ($parentName -like '*cmd*') { 31 } else { 30 }
} catch {
    $targetHeight = 30
}

try {
    if ([System.Console]::WindowHeight -ne $targetHeight) {
        if ([System.Console]::BufferHeight -lt $targetHeight) {
            [System.Console]::BufferHeight = $targetHeight
        }
        [System.Console]::WindowHeight = $targetHeight
    }
} catch {}

# ---------------------------------------------------------------------------
# Layout constants  -  derived dynamically from buffer scan
# ---------------------------------------------------------------------------
$logoStartCol = 0

# The top line of the logo starts with exactly this string.
# We scan the buffer for it to find $logoStartRow at runtime,
# so the script works regardless of how many header lines appear above it.
$logoTopSignature = '             ,-:;//;:=,'

# Offsets from logoStartRow (0-indexed within the logo block):
#   Row +8  = Memory Allocation bar
#   Row +9  = Storage Capacity bar
#   Row +10 = Power Core bar
#   Row +22 = "The Cake Is A Lie" / Press any key line
$barOffsets = @(8, 9, 10)
$cakeOffset = 22

# ---------------------------------------------------------------------------
# Logo data
# ---------------------------------------------------------------------------
$glyphChars = [char[]]('@','M','X','H','%','$','#')
$glyphSet   = [System.Collections.Generic.HashSet[char]]($glyphChars)

$logo = @(
    '             ,-:;//;:=,',
    '         . :@XH%%HXX#$/.,+M;,',
    '      ,/X+ +%H%M#$#%=,-%@#@HMX/,',
    '     -+$%H; #@%X#%+-,;XX@%$XM$MMH+-',
    '    ;XHXM$- %X%H;. -+$H@@$MH@$@%%MH/.',
    '  ,%@$$$%@ ,#X=            .---=-=:=,.',
    '  -#X#M@X@ .,              -@$$$##%M+;',
    ' =-./@#HMM                  .;X#MX#%XX:',
    ' MM/ -#M%/                    .+H#XMXM@',
    ',X$%%: :X:                    . -$%HM@#-',
    ',$XXHM$, .                    /#- ;HHHM=',
    '.X#H$%$X+,                    M$M+..%%H.',
    ' /H##XXH#M/.                  HM##M; -;',
    '  /@+M%HX%M@=              , .XM@#H$#,',
    '   .=--------.           -M#.,%#%X%@#,',
    '   .#H$H@#$HMMMX$@@+- .:XMX@ -HXH%M@.',
    '     =M@%%#@%X@@M@;,-+M$@$@+ /H#X#=',
    '       =MM@@X%%M-.=%@%XH@M%; $%M=',
    '         ,:+@+-,/M%MXHH$XH$- -,',
    '               =++XM#%+/:-.'
)

# ---------------------------------------------------------------------------
# Read console buffer via kernel32 ReadConsoleOutputCharacter (P/Invoke)
# Used both for bar slash detection and logo anchor scanning.
# ---------------------------------------------------------------------------

# Try to read from actual console buffer via kernel32 ReadConsoleOutputCharacter
$sig = @'
using System;
using System.Runtime.InteropServices;
public class ConsoleReader {
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode)]
    public static extern bool ReadConsoleOutputCharacter(
        IntPtr hConsoleOutput,
        [Out] char[] lpCharacter,
        uint nLength,
        uint dwReadCoord,   // low=X high=Y packed as uint
        out uint lpNumberOfCharsRead);

    public static string ReadLine(int row, int col, int length) {
        IntPtr h = GetStdHandle(-11);
        char[] buf = new char[length];
        uint read;
        uint coord = (uint)((row << 16) | (col & 0xFFFF));
        ReadConsoleOutputCharacter(h, buf, (uint)length, coord, out read);
        return new string(buf, 0, (int)read);
    }

    [DllImport("kernel32.dll")]
    static extern IntPtr GetStdHandle(int nStdHandle);
}
'@
Add-Type -TypeDefinition $sig -ErrorAction SilentlyContinue

# Read each bar row from the live buffer so slash positions are always dynamic
function Get-BarInfo {
    param([int]$ScreenRow)
    $width = [System.Console]::WindowWidth
    try {
        $line = [ConsoleReader]::ReadLine($ScreenRow, 0, $width)
    } catch {
        $line = ''
    }

    # Find the progress bar bracket region  [ ... ]
    $open  = $line.IndexOf('[')
    $close = $line.IndexOf(']', $open + 1)
    if ($open -lt 0 -or $close -lt 0) { return $null }

    # Collect absolute column indices of every '/' inside the brackets
    $slashCols = [System.Collections.Generic.List[int]]::new()
    for ($c = $open + 1; $c -lt $close; $c++) {
        if ($line[$c] -eq '/') { $slashCols.Add($c) }
    }
    if ($slashCols.Count -eq 0) { return $null }

    return [PSCustomObject]@{
        Row       = $ScreenRow
        SlashCols = $slashCols.ToArray()
        PrevIdx   = -1          # index of column currently showing '|'
    }
}

# ---------------------------------------------------------------------------
# Hide cursor
# ---------------------------------------------------------------------------
[System.Console]::CursorVisible = $false

# ---------------------------------------------------------------------------
# Detect logoStartRow by scanning buffer for the logo's top-line signature.
# The first ',' in '             ,-:;//;:=,' sits at column 13.
# We read each row from the buffer and look for that exact string.
# Falls back to row 4 if not found.
# ---------------------------------------------------------------------------
Start-Sleep -Milliseconds 200   # let the caller finish drawing first

$logoStartRow = 4   # fallback default
$bufHeight    = [System.Console]::BufferHeight
$sigLen       = $logoTopSignature.Length

for ($scanRow = 0; $scanRow -lt $bufHeight; $scanRow++) {
    try {
        $line = [ConsoleReader]::ReadLine($scanRow, 0, $sigLen)
        if ($line -eq $logoTopSignature) {
            $logoStartRow = $scanRow
            break
        }
    } catch { break }
}

# Derive all other row positions from the detected anchor
$barScreenRows = $barOffsets | ForEach-Object { $logoStartRow + $_ }
$cakeRow       = $logoStartRow + $cakeOffset

# ---------------------------------------------------------------------------
# Initialise bar state
# ---------------------------------------------------------------------------
$bars = @()
foreach ($r in $barScreenRows) {
    $info = Get-BarInfo -ScreenRow $r
    if ($info) { $bars += $info }
}

# Per-bar independent tick index
$barIdx = @(0) * $bars.Count

# ---------------------------------------------------------------------------
# Cake blink  -  "The Cake Is A Lie"  at detected $cakeRow, col 67
# Sequence per cycle (each unit = 1 tick = 0.2 s):
#   ON*10  OFF*1  ON*1  OFF*1  ON*1  OFF*1  ON*1  OFF*25
#   = 42 ticks total  (8.4 s cycle)
# ---------------------------------------------------------------------------
# $cakeRow is already set above from dynamic detection ($logoStartRow + $cakeOffset)
$cakeCol    = 67
$cakeText   = 'The Cake Is A Lie'
$cakeBlank  = ' ' * $cakeText.Length

# State table: Visible = 1 show / 0 hide, Ticks = how many 0.2s ticks to hold
$cakeStates = @(
    [PSCustomObject]@{ Visible = 1; Ticks = 10 }
    [PSCustomObject]@{ Visible = 0; Ticks = 1  }
    [PSCustomObject]@{ Visible = 1; Ticks = 1  }
    [PSCustomObject]@{ Visible = 0; Ticks = 1  }
    [PSCustomObject]@{ Visible = 1; Ticks = 1  }
    [PSCustomObject]@{ Visible = 0; Ticks = 1  }
    [PSCustomObject]@{ Visible = 1; Ticks = 1  }
    [PSCustomObject]@{ Visible = 0; Ticks = 25 }
)
$cakeStateIdx  = 0
$cakeTicksLeft = $cakeStates[0].Ticks

function Write-Cake {
    param([bool]$Show)
    [System.Console]::SetCursorPosition($cakeCol, $cakeRow)
    if ($Show) { [System.Console]::Write($cakeText)  }
    else       { [System.Console]::Write($cakeBlank) }
}

# ---------------------------------------------------------------------------
# Interruptible sleep  - polls every 20 ms for a keypress.
# Returns $true if a key was pressed (caller should break the loop),
# $false if the full duration elapsed with no input.
# Consumes the key from the buffer so it doesn't bleed into the shell.
# ---------------------------------------------------------------------------
function Wait-OrKey {
    param([int]$Milliseconds)
    $elapsed = 0
    while ($elapsed -lt $Milliseconds) {
        if ([System.Console]::KeyAvailable) {
            [System.Console]::ReadKey($true) | Out-Null   # consume key silently
            return $true
        }
        Start-Sleep -Milliseconds 20
        $elapsed += 20
    }
    return $false
}

# ---------------------------------------------------------------------------
# Timing  - master tick = 0.2 s  (bar + cake speed)
#           logo updates every 3 ticks  (3 x 0.2 s = 0.6 s)
# ---------------------------------------------------------------------------
$logoToggle   = 0
$logoInterval = 3
$exitRequested = $false

try {
    while (-not $exitRequested) {

        # ---- Logo frame (every $logoInterval ticks) -------------------------
        if ($logoToggle % $logoInterval -eq 0) {
            $frame = foreach ($line in $logo) {
                $chars = $line.ToCharArray()
                for ($i = 0; $i -lt $chars.Length; $i++) {
                    if ($glyphSet.Contains($chars[$i])) {
                        $chars[$i] = $glyphChars[(Get-Random -Maximum $glyphChars.Length)]
                    }
                }
                -join $chars
            }
            for ($r = 0; $r -lt $frame.Count; $r++) {
                [System.Console]::SetCursorPosition($logoStartCol, $logoStartRow + $r)
                [System.Console]::Write($frame[$r])
            }
        }
        $logoToggle++

        # ---- Bar cursor glide (every tick = 0.2 s) -------------------------
        for ($b = 0; $b -lt $bars.Count; $b++) {
            $bar      = $bars[$b]
            $cols     = $bar.SlashCols
            $count    = $cols.Count
            $curIdx   = $barIdx[$b]
            $prevIdx  = $bar.PrevIdx

            if ($prevIdx -ge 0 -and $prevIdx -lt $count) {
                [System.Console]::SetCursorPosition($cols[$prevIdx], $bar.Row)
                [System.Console]::Write('/')
            }

            [System.Console]::SetCursorPosition($cols[$curIdx], $bar.Row)
            [System.Console]::Write('>')

            $bar.PrevIdx = $curIdx
            $barIdx[$b]  = ($curIdx + 1) % $count
        }

        # ---- Cake blink (every tick = 0.2 s) --------------------------------
        $curState = $cakeStates[$cakeStateIdx]
        Write-Cake -Show ([bool]$curState.Visible)

        $cakeTicksLeft--
        if ($cakeTicksLeft -le 0) {
            $cakeStateIdx  = ($cakeStateIdx + 1) % $cakeStates.Count
            $cakeTicksLeft = $cakeStates[$cakeStateIdx].Ticks
        }

        # ---- Sleep 0.2 s, break immediately if any key is pressed -----------
        if (Wait-OrKey -Milliseconds 200) {
            $exitRequested = $true
        }
    }
}
finally {
    # Restore all '|' back to '/', hide cake, restore cursor, move to safe row
    for ($b = 0; $b -lt $bars.Count; $b++) {
        $bar  = $bars[$b]
        $prev = $bar.PrevIdx
        if ($prev -ge 0) {
            [System.Console]::SetCursorPosition($bar.SlashCols[$prev], $bar.Row)
            [System.Console]::Write('/')
        }
    }
    Write-Cake -Show $false
    [System.Console]::CursorVisible = $true
    # Move cursor below the entire display so the next prompt appears cleanly
    # Clamp to BufferHeight-1 to avoid ArgumentOutOfRangeException
    $bottomRow = [Math]::Min($cakeRow + 2, [System.Console]::BufferHeight - 1)
    [System.Console]::SetCursorPosition(0, $bottomRow)
    Write-Host ""
}