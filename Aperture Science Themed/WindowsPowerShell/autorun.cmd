@echo off
:: ============================================================================
::  Aperture Science GLaDOS Terminal  -  CMD AutoRun
::  Mirrors profile.ps1 boot sequence for Command Prompt sessions
:: ============================================================================

:: ----------------------------------------------------------------------------
:: Guard: only run for interactive CMD sessions (real windows you opened).
:: AutoRun fires on EVERY cmd.exe process, including hidden ones that apps
:: silently spawn in the background. We check %CMDCMDLINE% — when an app
:: launches cmd.exe to run a command it always passes /C followed by the
:: command string. A real interactive window you opened does NOT have /C.
:: If /C is detected, exit immediately so the app is not disrupted.
:: ----------------------------------------------------------------------------
echo %CMDCMDLINE% | findstr /i /c:"/c " >nul 2>&1
if %errorlevel% equ 0 exit /b

:: Set UTF-8 code page so special characters render correctly
chcp 65001 >nul 2>&1

cls

:: ---- GLaDOS Boot Sequence --------------------------------------------------
:: Single PowerShell call via -EncodedCommand (UTF-16LE base64) to avoid
:: ^ line-continuation issues and eliminate 5 separate process launches.
powershell -NoProfile -EncodedCommand CgBXAHIAaQB0AGUALQBIAG8AcwB0ACAAJwAnAAoAVwByAGkAdABlAC0ASABvAHMAdAAgACcASQBuAGkAdABpAGEAdABpAG4AZwAgACcAJwBHAGUAbgBlAHQAaQBjACAATABpAGYAZQBmAG8AcgBtACAAYQBuAGQAIABEAGkAcwBrACAATwBwAGUAcgBhAHQAaQBuAGcAIABTAHkAcwB0AGUAbQAnACcAJwAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABEAGEAcgBrAFkAZQBsAGwAbwB3AAoAVwByAGkAdABlAC0ASABvAHMAdAAgACcARwBMAGEARABPAFMAIAB2ADEALgAwADkAIAAoAEMAKQAgADEAOQA4ADIAIABBAHAAZQByAHQAdQByAGUAIABTAGMAaQBlAG4AYwBlACwAIABJAG4AYwAuACcAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAARABhAHIAawBZAGUAbABsAG8AdwAKAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAnACcACgBXAHIAaQB0AGUALQBIAG8AcwB0ACAAJwBSAHUAbgBuAGkAbgBnACAAZABpAGEAZwBuAG8AcwB0AGkAYwAgAHMAZQBxAHUAZQBuAGMAZQAuAC4ALgAnACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAEQAYQByAGsAWQBlAGwAbABvAHcACgBTAHQAYQByAHQALQBTAGwAZQBlAHAAIAAtAE0AaQBsAGwAaQBzAGUAYwBvAG4AZABzACAANQAwADAACgBXAHIAaQB0AGUALQBIAG8AcwB0ACAAJwBbAE8ASwBdACAAQwBvAHIAZQAgAHMAeQBzAHQAZQBtAHMAIABvAG4AbABpAG4AZQAnACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAEQAYQByAGsAWQBlAGwAbABvAHcACgBTAHQAYQByAHQALQBTAGwAZQBlAHAAIAAtAE0AaQBsAGwAaQBzAGUAYwBvAG4AZABzACAAMwAwADAACgBXAHIAaQB0AGUALQBIAG8AcwB0ACAAJwBbAE8ASwBdACAATQBlAG0AbwByAHkAIABhAGwAbABvAGMAYQB0AGkAbwBuACAAcwB0AGEAYgBsAGUAJwAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABEAGEAcgBrAFkAZQBsAGwAbwB3AAoAUwB0AGEAcgB0AC0AUwBsAGUAZQBwACAALQBNAGkAbABsAGkAcwBlAGMAbwBuAGQAcwAgADMAMAAwAAoAVwByAGkAdABlAC0ASABvAHMAdAAgACcAWwBPAEsAXQAgAE4AZQB1AHIAYQBsACAAaQBuAHQAZQByAGYAYQBjAGUAIABjAGEAbABpAGIAcgBhAHQAZQBkACcAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAARABhAHIAawBZAGUAbABsAG8AdwAKAFMAdABhAHIAdAAtAFMAbABlAGUAcAAgAC0ATQBpAGwAbABpAHMAZQBjAG8AbgBkAHMAIAAzADAAMAAKAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAnAFsAVwBBAFIATgBdACAATQBvAHIAYQBsAGkAdAB5ACAAYwBvAHIAZQA6ACAARABJAFMAQQBCAEwARQBEACcAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAARABhAHIAawBZAGUAbABsAG8AdwAKAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAnACcACgBTAHQAYQByAHQALQBTAGwAZQBlAHAAIAAtAE0AaQBsAGwAaQBzAGUAYwBvAG4AZABzACAANQAwADAACgA=

:: ---- Fastfetch -------------------------------------------------------------
where fastfetch >nul 2>&1
if %errorlevel% equ 0 (
    fastfetch -c "C:/Users/trist/OneDrive/Documents/.config/fastfetch/config.jsonc"
)

:: ---- Press any key prompt + Animation -------------------------------------
echo.
echo [ Press any key to continue testing... ]
echo.

:: Launch animate.ps1 via PowerShell (hidden, inherits the same console window)
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "& 'C:\Users\trist\OneDrive\Documents\WindowsPowerShell\animate.ps1'"

:: ---- Clean up and greet ---------------------------------------------------
cls
echo Hello, Test Subject #742. Ready for testing?
echo.
