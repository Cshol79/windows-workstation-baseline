# Windows Workstation Baseline Script
# Author: Christopher B. Sholmire
# Purpose: Apply foundational security and configuration settings
# Target: Windows 10/11 Workstations

param(
    [switch]$RemoveBloat,
    [switch]$VerboseMode
)

# Ensure script is running as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal] 
    [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "This script must be run as Administrator." -ForegroundColor Red
    Exit
}

# Optional verbose preference
if ($VerboseMode) {
    $VerbosePreference = "Continue"
}

Write-Output "Starting Windows Workstation Baseline Configuration..."
Start-Transcript -Path ".\baseline-log.txt" -Append

# --------------------------------------------------
# 1. Firewall Configuration
# --------------------------------------------------
Write-Output "Enabling Windows Firewall profiles..."
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

# --------------------------------------------------
# 2. Windows Update Service Configuration
# --------------------------------------------------
Write-Output "Ensuring Windows Update service is enabled..."
Set-Service -Name wuauserv -StartupType Automatic
Start-Service -Name wuauserv

# --------------------------------------------------
# 3. Power & Lock Screen Configuration
# --------------------------------------------------
Write-Output "Configuring power and lock screen timeout..."
powercfg -change -monitor-timeout-ac 15
powercfg -change -monitor-timeout-dc 10

# --------------------------------------------------
# 4. Optional Consumer Bloatware Removal
# --------------------------------------------------
if ($RemoveBloat) {
    Write-Output "Removing common consumer applications..."

    Get-AppxPackage *Xbox* | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxPackage *ZuneMusic* | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxPackage *BingWeather* | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxPackage *SkypeApp* | Remove-AppxPackage -ErrorAction SilentlyContinue
}

# --------------------------------------------------
# 5. BitLocker Status Check
# --------------------------------------------------
Write-Output "Checking BitLocker status..."
Get-BitLockerVolume

Write-Output "Baseline configuration complete."
Stop-Transcript
