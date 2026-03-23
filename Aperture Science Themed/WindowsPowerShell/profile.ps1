# Aperture Science GLaDOS Terminal
# Test Subject #742: Tristan Chew Zun Yan
# Set custom colors for Fastfetch
$env:FASTFETCH_COLORS = "brightYellow=#E79A2B"

# Or set the specific color you want
# You can also set environment variables for specific colors
# Set UTF-8 encoding
try {
    [Console]::InputEncoding = [System.Text.Encoding]::UTF8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.UTF8Encoding]::new($false)
    chcp 65001 > $null
} catch {}

Clear-Host

# GLaDOS Boot Message
function Show-GLaDOSBoot {
    Write-Host ""
    Write-Host "Initiating 'Genetic Lifeform and Disk Operating System'" -ForegroundColor DarkYellow
    Write-Host "GLaDOS v1.09 (C) 1982 Aperture Science, Inc." -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "Running diagnostic sequence..." -ForegroundColor DarkYellow
    Start-Sleep -Milliseconds 500
    Write-Host "[OK] Core systems online" -ForegroundColor DarkYellow
    Start-Sleep -Milliseconds 300
    Write-Host "[OK] Memory allocation stable" -ForegroundColor DarkYellow
    Start-Sleep -Milliseconds 300
    Write-Host "[OK] Neural interface calibrated" -ForegroundColor DarkYellow
    Start-Sleep -Milliseconds 300
    Write-Host "[WARN] Morality core: DISABLED" -ForegroundColor DarkYellow
    Write-Host ""
    Start-Sleep -Milliseconds 500
}

# System Info Function (Fallback if Fastfetch not installed)
function Show-ApertureInfo {
    $os = (Get-CimInstance Win32_OperatingSystem).Caption
    $kernel = (Get-CimInstance Win32_OperatingSystem).Version
    $hostname = $env:COMPUTERNAME
    $uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    $uptimeStr = "{0}d {1}h {2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes
    
    $cpuRaw = (Get-CimInstance Win32_Processor).Name
    $cpu = $cpuRaw -replace "AMD ", "" -replace "Ryzen ", "" -replace "Intel\(R\) ", "" -replace "Core\(TM\) ", ""
    $cpuLoad = (Get-CimInstance Win32_Processor).LoadPercentage
    $totalRAM = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
    $freeRAM = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 0)
    $usedRAM = [math]::Round(($totalRAM * 1024 - $freeRAM) / 1024, 0)
    
    $disk = Get-PSDrive C | Select-Object Used, Free
    $diskUsed = [math]::Round($disk.Used / 1GB, 0)
    $diskTotal = [math]::Round(($disk.Used + $disk.Free) / 1GB, 0)
    
    $battery = Get-WmiObject Win32_Battery -ErrorAction SilentlyContinue
    if ($battery) {
        $batteryPercent = $battery.EstimatedChargeRemaining
        $batteryStatus = switch ($battery.BatteryStatus) {
            2 { "Discharging" }
            3 { "Charging" }
            default { "Idle" }
        }
        $batteryRemaining = [math]::Round($battery.EstimatedRunTime / 60, 1)
        $batteryStr = "$batteryPercent% ($batteryStatus) - $batteryRemaining hours remaining"
    } else {
        $batteryStr = "AC Power - Unlimited"
    }
    
    Write-Host ""
    Write-Host "================================================================================" -ForegroundColor DarkYellow
    Write-Host "TEST SUBJECT #742: TRISTAN CHEW ZUN YAN" -ForegroundColor Black -BackgroundColor DarkYellow
    Write-Host "================================================================================" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "GLaDOS:        $os" -ForegroundColor DarkYellow
    Write-Host "Core Protocol: $kernel" -ForegroundColor DarkYellow
    Write-Host "Facility:      $hostname" -ForegroundColor DarkYellow
    Write-Host "Operational:   $uptimeStr" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "Processing Unit:   $cpu" -ForegroundColor DarkYellow
    Write-Host "Processing Load:   $cpuLoad%" -ForegroundColor DarkYellow
    Write-Host "Memory Allocation: ${usedRAM}MiB / ${totalRAM}GiB" -ForegroundColor DarkYellow
    Write-Host "Storage Capacity:  ${diskUsed}GiB / ${diskTotal}GiB" -ForegroundColor DarkYellow
    Write-Host "Power Core:        $batteryStr" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "================================================================================" -ForegroundColor DarkYellow
    Write-Host "The cake is a lie." -ForegroundColor DarkYellow
    Write-Host "================================================================================" -ForegroundColor DarkYellow
    Write-Host ""
}

# Main Execution
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    # Show GLaDOS boot sequence
    Show-GLaDOSBoot
    
    # Run Fastfetch with Aperture config
    fastfetch -c "C:/Users/trist/OneDrive/Documents/.config/fastfetch/config.jsonc"
} else {
    # Fallback to PowerShell version
    Show-GLaDOSBoot
    Show-ApertureInfo
}

Write-Host ""
Write-Host "[ Press any key to continue testing... ]" -ForegroundColor DarkYellow

& "C:\Users\trist\OneDrive\Documents\WindowsPowerShell\animate.ps1"
Clear-Host

Write-Host "Hello, Test Subject #742. Ready for testing?" -ForegroundColor DarkYellow
Write-Host ""