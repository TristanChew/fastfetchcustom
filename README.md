```
             ,-:;//;:=,
         . :@XH%%HXX#$/.,+M;,
      ,/X+ +%H%M#$#%=,-%@#@HMX/,
     -+$%H; #@%X#%+-,;XX@%$XM$MMH+-
    ;XHXM$- %X%H;. -+$H@@$MH@$@%%MH/.
  ,%@$$$%@ ,#X=            .---=-=:=,.
  -#X#M@X@ .,              -@$$$##%M+;
 =-./@#HMM                  .;X#MX#%XX:
 MM/ -#M%/                    .+H#XMXM@
,X$%%: :X:                    . -$%HM@#-
,$XXHM$, .                    /#- ;HHHM=
.X#H$%$X+,                    M$M+..%%H.
 /H##XXH#M/.                  HM##M; -;
  /@+M%HX%M@=              , .XM@#H$#,
   .=--------.           -M#.,%#%X%@#,
   .#H$H@#$HMMMX$@@+- .:XMX@ -HXH%M@.
     =M@%%#@%X@@M@;,-+M$@$@+ /H#X#=
       =MM@@X%%M-.=%@%XH@M%; $%M=
         ,:+@+-,/M%MXHH$XH$- -,
               =++XM#%+/:-.
```

<div align="center">

# GLaDOS Terminal — Aperture Science Interface v1.09

**A fully animated, lore-accurate GLaDOS-themed system fetch display for Windows PowerShell and Command Prompt.**

*"The Enrichment Center reminds you that the Weighted Companion Cube cannot speak."*

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?style=flat-square&logo=powershell)
![CMD](https://img.shields.io/badge/CMD-Windows%2010%2F11-lightgrey?style=flat-square&logo=windows)
![Fastfetch](https://img.shields.io/badge/Fastfetch-required-orange?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

</div>

---

## Overview

This project transforms your Windows terminal into an Aperture Science testing facility readout. On every shell launch — PowerShell or CMD — you are greeted by a full GLaDOS boot sequence, a live system info display powered by [Fastfetch](https://github.com/fastfetch-cli/fastfetch), and a hand-crafted animation layer that runs entirely through direct console buffer manipulation, with no external dependencies.

Every character on screen is alive. The ASCII logo glyphs shimmer. The progress bars have a scanning cursor gliding through them. A secret message blinks in and out. Press any key and it all stops cleanly, handing control back to you.

---

## Features

### Boot Sequence
A staged diagnostic printout appears on every launch, timed to match a real system boot cadence:

```
Initiating 'Genetic Lifeform and Disk Operating System'
GLaDOS v1.09 (C) 1982 Aperture Science, Inc.

Running diagnostic sequence...
[OK] Core systems online
[OK] Memory allocation stable
[OK] Neural interface calibrated
[WARN] Morality core: DISABLED
```

### Fastfetch System Display
System info is rendered by Fastfetch using a custom `config.jsonc` with full GLaDOS lore theming. Every label is renamed to fit the Aperture Science universe:

| Fastfetch Module | GLaDOS Label |
|---|---|
| OS | GLaDOS |
| Kernel | Core Protocol |
| Host | Facility |
| Uptime | Operational Since |
| CPU | Processing Unit |
| Memory | Memory Allocation |
| Disk | Storage Capacity |
| Battery | Power Core |
| Local IP | Network Interface |
| Shell | Terminal Interface |

Progress bars use `/` for filled and `-` for empty, rendered in amber (`#9F6E13`).

### Animation Layer (`animate.ps1`)

The animation script runs after Fastfetch renders and operates entirely through Win32 console buffer P/Invoke — no flicker, no full redraws, no touching text it doesn't own.

**ASCII Logo Glyph Shimmer**
The logo contains characters from the set `@ M X H % $ #`. Every 0.6 seconds, each of those characters is replaced with a random character from the same set, creating a living, shifting effect. All surrounding punctuation (`/ - . , : ; = +`) stays fixed, preserving the logo's silhouette.

**Progress Bar Scanner**
The three progress bars (Memory, Storage, Power) each have a `|` cursor that glides across their filled `/` region one position every 0.2 seconds. Slash positions are detected dynamically by reading the live console buffer — so it works correctly regardless of your actual usage percentages at the time.

**"The Cake Is A Lie" Blink**
A hidden message appears beside the `[ Press any key to continue testing... ]` prompt. It follows a precise blink sequence then goes dark for 5 seconds before looping:

```
Solid 2.0s → off 0.2s → on 0.2s → off 0.2s → on 0.2s → off 0.2s → on 0.2s → dark 5.0s → repeat
```

**Any-Key Exit**
The animation polls for keypresses every 20ms inside the sleep interval — so it responds within one poll cycle (≤20ms) rather than waiting for the next 200ms tick. On exit, all modified characters are restored, the cursor is shown, and control returns to the shell cleanly.

**Dynamic Layout Detection**
The script does not hardcode row numbers. Instead it scans the live console buffer for the logo's top-line signature (`             ,-:;//;:=,`) using `ReadConsoleOutputCharacter` via kernel32 P/Invoke. All other positions — bar rows, cake row — are calculated as offsets from that anchor. This means it works whether launched from PowerShell or CMD regardless of how many header lines appear above the logo.

---

## File Structure

```
WindowsPowerShell/
├── profile.ps1        # PowerShell profile — auto-runs on every PS session
├── animate.ps1        # Animation engine — called by both profile.ps1 and autorun.cmd
└── autorun.cmd        # CMD AutoRun script — auto-runs on every CMD session

.config/fastfetch/
├── config.jsonc       # Fastfetch layout and module configuration
└── ascii.txt          # Custom ASCII logo source file
```

---

## How It Works

### PowerShell (`profile.ps1`)
PowerShell automatically executes `$PROFILE` on every session start. The profile runs the boot sequence, calls Fastfetch, prints the prompt, then calls `animate.ps1` directly. The animation script consumes the keypress itself, so no second `ReadKey` is needed.

### Command Prompt (`autorun.cmd`)
CMD has no native profile system, but supports an `AutoRun` registry key that points to a `.cmd` file executed on every new CMD window:

```
HKCU\Software\Microsoft\Command Processor\AutoRun
```

Set it with:
```bat
reg add "HKCU\Software\Microsoft\Command Processor" /v AutoRun /t REG_SZ /d "C:\path\to\autorun.cmd" /f
```

`autorun.cmd` runs the boot sequence via a single `-EncodedCommand` PowerShell call (UTF-16LE base64), then calls Fastfetch, then launches `animate.ps1` in the same console window via `powershell.exe -NoProfile -NonInteractive`.

### Why `-EncodedCommand` for the Boot Sequence?
CMD's `^` line continuation character breaks inside `powershell -Command "..."` strings because CMD processes it before PowerShell sees the command. `-EncodedCommand` accepts a base64-encoded UTF-16LE script as a single unbroken token — CMD passes it through untouched, and five separate `powershell.exe` process launches (one per sleep) are collapsed into one.

### Why `.NET` Instead of `Get-CimInstance` for Parent Detection?
The script detects whether it was launched from CMD or PowerShell to set the correct window height (31 rows for CMD, 30 for PowerShell). The first implementation used `Get-CimInstance Win32_Process` — a WMI query that takes 500ms–2s on a cold `powershell.exe` process with no warm WMI session. The replacement uses `[System.Diagnostics.Process]::GetProcessById($PID).Parent.ProcessName` — a direct OS process table read that resolves in under a millisecond.

---

## Installation

### Prerequisites
- Windows 10 or 11
- PowerShell 5.1 or later
- [Fastfetch](https://github.com/fastfetch-cli/fastfetch/releases) installed and on PATH

### Steps

**1. Clone the repository**
```bash
git clone https://github.com/yourusername/glados-terminal.git
```

**2. Copy files to their locations**
```
profile.ps1   →  C:\Users\<you>\Documents\WindowsPowerShell\profile.ps1
animate.ps1   →  C:\Users\<you>\Documents\WindowsPowerShell\animate.ps1
autorun.cmd   →  C:\Users\<you>\Documents\WindowsPowerShell\autorun.cmd
config.jsonc  →  C:\Users\<you>\OneDrive\Documents\.config\fastfetch\config.jsonc
ascii.txt     →  C:\Users\<you>\OneDrive\Documents\.config\fastfetch\ascii.txt
```

> Update the hardcoded paths in `profile.ps1`, `autorun.cmd`, and `config.jsonc` to match your username and directory structure.

**3. Allow PowerShell scripts to run**
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

**4. Register CMD AutoRun**
```bat
reg add "HKCU\Software\Microsoft\Command Processor" /v AutoRun /t REG_SZ /d "C:\Users\<you>\Documents\WindowsPowerShell\autorun.cmd" /f
```

**5. Open a new terminal window** — PowerShell or CMD — and the sequence will run automatically.

---

## Customisation

| What | Where | How |
|---|---|---|
| Subject name & number | `config.jsonc` → title format | Change the format string |
| Accent colour | `config.jsonc` → all `"color"` fields | Replace `#9F6E13` with any hex |
| ASCII logo | `ascii.txt` | Replace with any ASCII art |
| Glyph shimmer characters | `animate.ps1` → `$glyphChars` | Add or remove characters |
| Shimmer speed | `animate.ps1` → `$logoInterval` | Ticks × 0.2s = interval |
| Bar scanner speed | `animate.ps1` → `Wait-OrKey -Milliseconds 200` | Lower = faster |
| Cake blink text | `animate.ps1` → `$cakeText` | Any string |
| Cake blink column | `animate.ps1` → `$cakeCol` | 0-indexed column number |
| Window heights | `animate.ps1` → `$targetHeight` conditions | Adjust 30 / 31 |

---

## Technical Notes

- All console writes use `[System.Console]::SetCursorPosition` + `[System.Console]::Write` directly — bypassing PowerShell's output pipeline to avoid flicker and newline insertion.
- Bar slash positions are read from the live screen buffer each time the script initialises, so they always match the actual rendered Fastfetch output regardless of live usage values.
- The logo anchor scan reads exactly `$logoTopSignature.Length` characters per row using `ReadConsoleOutputCharacter` (kernel32), comparing against the known first line of the logo. This makes the layout fully position-independent.
- The cursor is hidden via `[System.Console]::CursorVisible = $false` at the start of the animation and restored in a `finally` block that also fires on `Ctrl+C`.

---

## Dependencies

- [Fastfetch](https://github.com/fastfetch-cli/fastfetch) — system info fetcher
- Windows PowerShell 5.1+ (built into Windows 10/11)
- No NuGet packages, no modules, no installs beyond the above

---

<div align="center">

*GLaDOS v1.09 © 1982 Aperture Science, Inc. All rights reserved.*

*The Cake Is A Lie.*

</div>
