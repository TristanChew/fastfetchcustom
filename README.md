<div align="center">

# GLaDOS Terminal — Aperture Science Interface v1.09

**A fully animated, lore-accurate GLaDOS-themed terminal experience for Windows PowerShell and Command Prompt.**

*"The Enrichment Center reminds you that the Weighted Companion Cube cannot speak."*

![Windows](https://img.shields.io/badge/Platform-Windows%2010%2F11-blue?style=flat-square&logo=windows)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?style=flat-square&logo=powershell)
![CMD](https://img.shields.io/badge/CMD-Supported-lightgrey?style=flat-square)
![Fastfetch](https://img.shields.io/badge/Fastfetch-Required-orange?style=flat-square)

</div>

---

## Overview

This project turns your Windows terminal into an Aperture Science testing facility readout. Every time you open **PowerShell** or **Command Prompt**, you are greeted by a GLaDOS boot sequence, a live system info panel powered by [Fastfetch](https://github.com/fastfetch-cli/fastfetch), and a hand-crafted animation layer that runs entirely through direct console buffer manipulation — no external dependencies, no blinking redraws, no leftover artifacts.

The ASCII logo glyphs shimmer and shift. The progress bars have a scanning `>` cursor gliding across the filled region. A secret message blinks beside the prompt. Press any key and everything stops cleanly, handing the shell back to you.

> **⚠️ Window Size Requirement**
> This setup is designed for a terminal window of **120 columns × 30 rows**.
> The display is laid out exactly for this size on boot. You may freely resize after the animation is dismissed — but for the initial screen to render correctly, your terminal must default to **120×30**. See [Appearance Setup](#appearance-setup) for how to set this.

---

## Preview

![GLaDOS Terminal Preview](https://raw.githubusercontent.com/TristanChew/fastfetchcustom/refs/heads/main/Terminal.png)

*Logo glyphs shimmer every 0.6s · `>` scans across each bar every 0.2s · "The Cake Is A Lie" blinks then fades on an 8.4s cycle · Press any key to proceed*

---

## File Structure

```
WindowsPowerShell/
├── profile.ps1        ← PowerShell profile — auto-runs on every PS session
├── animate.ps1        ← Animation engine — shared by both PS and CMD
└── autorun.cmd        ← CMD AutoRun script — auto-runs on every CMD session

.config/fastfetch/
├── config.jsonc       ← Fastfetch layout and lore-themed module config
└── ascii.txt          ← Custom ASCII logo source
```

---

## Prerequisites

- **Windows 10 or 11**
- **PowerShell 5.1+** — built into Windows, no install needed
- **[Fastfetch](https://github.com/fastfetch-cli/fastfetch/releases)** — download the latest release `.zip`, extract, and add the folder to your system PATH
- **[Windows Terminal](https://aka.ms/terminal)** — recommended for the retro amber CRT appearance

---

## Installation

### 1. Clone or download this repository

```bash
git clone https://github.com/yourusername/glados-terminal.git
```

### 2. Copy the files

Place each file at the path below, replacing `<user>` with your Windows username:

| File | Destination |
|---|---|
| `profile.ps1` | `C:\Users\<user>\Documents\WindowsPowerShell\profile.ps1` |
| `animate.ps1` | `C:\Users\<user>\Documents\WindowsPowerShell\animate.ps1` |
| `autorun.cmd` | `C:\Users\<user>\Documents\WindowsPowerShell\autorun.cmd` |
| `config.jsonc` | `C:\Users\<user>\Documents\.config\fastfetch\config.jsonc` |
| `ascii.txt` | `C:\Users\<user>\Documents\.config\fastfetch\ascii.txt` |

### 3. Update the paths inside the files

Open `profile.ps1`, `autorun.cmd`, and `config.jsonc` in a text editor and replace every instance of the placeholder username with your own, so the paths point to where you placed the files.

### 4. Allow PowerShell scripts to run

Open PowerShell and run:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### 5. Register the CMD AutoRun

This makes `autorun.cmd` execute automatically on every new Command Prompt window:

```bat
reg add "HKCU\Software\Microsoft\Command Processor" /v AutoRun /t REG_SZ /d "C:\Users\<user>\Documents\WindowsPowerShell\autorun.cmd" /f
```

### 6. Apply the appearance settings

See [Appearance Setup](#appearance-setup) below to configure the retro amber look and 120×30 window size in Windows Terminal.

### 7. Open a new terminal

Open a new **PowerShell** or **CMD** window — the full boot sequence will run automatically.

---

## Appearance Setup

To get the retro amber CRT look with 90% opacity and the correct window size, apply the following to your Windows Terminal `settings.json`.

Open it via: **Windows Terminal → Settings (bottom-left gear) → Open JSON file**

#### Step 1 — Add the colour scheme

Paste this into the `"schemes"` array:

```jsonc
{
        "name": "Black Mesa Terminal",
        "background": "#472B08",
        "black": "#2A1904",
        "blue": "#B87A1A",
        "brightBlack": "#593808",
        "brightBlue": "#D69322",
        "brightCyan": "#EAA336",
        "brightGreen": "#C8841E",
        "brightPurple": "#AB7117",
        "brightRed": "#BF7A16",
        "brightWhite": "#F5B54A",
        "brightYellow": "#E89A2A",
        "cursorColor": "#9F6E13",
        "cyan": "#D48D26",
        "foreground": "#9F6E13",
        "green": "#B47718",
        "purple": "#A56D15",
        "red": "#A86F14",
        "selectionBackground": "#9F6E13",
        "white": "#E29E32",
        "yellow": "#D1851F"
},
```

#### Step 2 — Update your profile entry

Find your PowerShell (and/or CMD) entry inside `"profiles"` → `"list"` and add or merge these keys:

```jsonc
{
    "colorScheme": "Black Mesa Terminal",
    "commandline": "%SystemRoot%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
    "experimental.retroTerminalEffect": true,
    "guid": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}",
    "hidden": false,
    "name": "Windows PowerShell",
    "opacity": 90
},
```

| Setting | Effect |
|---|---|
| `"colorScheme": "Black Mesa Terminal"` | Applies the amber-on-black Aperture colour palette |
| `"opacity": 90` | 90% opacity — subtle transparency behind the terminal |
| `"experimental.retroTerminalEffect": true` | CRT scanline and phosphor glow overlay |

> **Note:** `experimental.retroTerminalEffect` is a Windows Terminal feature. It may not be available in all versions — if your terminal shows an error on this line, remove it and the display will still work correctly without the CRT effect.

---

## How It Works

### PowerShell (`profile.ps1`)

PowerShell executes the file at `$PROFILE` automatically on every new session. The profile sets UTF-8 encoding, runs the GLaDOS boot sequence, calls Fastfetch with the custom config, prints the `[ Press any key... ]` prompt, then calls `animate.ps1`. The animation script consumes the keypress internally so no second read is needed after it returns.

If Fastfetch is not installed, a built-in PowerShell fallback (`Show-ApertureInfo`) collects and renders the same system information using CIM/WMI queries.

### Command Prompt (`autorun.cmd`)

CMD has no native profile, but the registry key `HKCU\Software\Microsoft\Command Processor\AutoRun` points CMD to a `.cmd` file that runs on every new session. The file runs the boot sequence through a single `powershell -EncodedCommand` call (UTF-16LE base64 encoded), then calls Fastfetch, then launches `animate.ps1` in the same console window. Using `-EncodedCommand` avoids CMD's `^` line-continuation issues and collapses what would be five separate `powershell.exe` process launches into one.

### Animation Engine (`animate.ps1`)

**Logo Anchor Detection**
Rather than hardcoding row numbers, the script reads the live console buffer using `ReadConsoleOutputCharacter` (kernel32 P/Invoke) and scans for the logo's known first line (`             ,-:;//;:=,`). Once found, all other positions — the three bar rows, the cake text row — are offsets from that anchor. This makes the layout work identically whether launched from PowerShell (30-row window) or CMD (31-row window).

**Glyph Shimmer**
Characters in the set `@ M X H % $ #` are swapped for a random character from the same set every 0.6 seconds. Punctuation stays fixed, preserving the logo outline.

**Progress Bar Scanner**
Slash positions inside each `[ ////--- ]` bar are found dynamically from the live buffer — always matching your actual usage values at the time. A `>` cursor advances one position every 0.2 seconds and loops.

**"The Cake Is A Lie" Blink**
Appears beside the press-any-key prompt on a precise 8.4-second cycle:

```
Solid 2.0s → off 0.2s → on 0.2s → off 0.2s → on 0.2s → off 0.2s → on 0.2s → dark 5.0s → repeat
```

**Any-Key Exit**
The script polls `[System.Console]::KeyAvailable` every 20ms inside the sleep window. The key is consumed silently with `ReadKey($true)` — it never echoes to the terminal and never bleeds into the shell after exit. The `finally` block restores all modified characters, restores the cursor, and positions it cleanly below the display.

**Fast Parent Process Detection**
Window height is set to 30 for PowerShell and 31 for CMD. Detection uses `[System.Diagnostics.Process]::GetProcessById($PID).Parent.ProcessName` — a direct OS process table read, resolving in under a millisecond. The earlier approach used `Get-CimInstance Win32_Process` (WMI), which caused 500ms–2s startup delays on CMD's cold-start PowerShell process.

---

## Fastfetch Label Reference

| Fastfetch Module | Displayed As |
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

Progress bars use `/` for elapsed and `-` for total, 16 characters wide, all in amber `#9F6E13`.

---

## Customisation Reference

| What | File | Variable / Field |
|---|---|---|
| Your name | `config.jsonc` | `"format"` in the title module |
| Accent colour | `config.jsonc` | All `"color"` fields — replace `#9F6E13` |
| ASCII logo | `ascii.txt` | Replace with any ASCII art |
| Shimmer characters | `animate.ps1` | `$glyphChars` |
| Shimmer speed | `animate.ps1` | `$logoInterval` (ticks × 0.2s) |
| Bar scanner speed | `animate.ps1` | `Wait-OrKey -Milliseconds 200` |
| Cake blink text | `animate.ps1` | `$cakeText` |
| Cake blink column | `animate.ps1` | `$cakeCol` (0-indexed) |
| Window heights | `animate.ps1` | `$targetHeight` conditions (PS=30, CMD=31) |

---

## Dependencies

- [Fastfetch](https://github.com/fastfetch-cli/fastfetch) — system info renderer
- [Windows Terminal](https://aka.ms/terminal) — required for retro CRT appearance settings
- PowerShell 5.1+ — pre-installed on Windows 10/11
- No NuGet packages, no extra modules, no admin rights beyond the one-time `ExecutionPolicy` change

---

<div align="center">

*GLaDOS v1.09 © 1982 Aperture Science, Inc. All rights reserved.*

*The Cake Is A Lie.*

</div>
