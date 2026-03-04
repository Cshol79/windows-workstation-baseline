# Windows Workstation Baseline Script
# Author: Christopher B. Sholmire
# Purpose: Apply foundational security and configuration settings
# Target: Windows 10/11 Workstations

param(
    [switch]$RemoveBloat,
    [switch]$VerboseMode,
    [switch]$AuditOnly
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

function Invoke-Action {
    param(
        [string]$Message,
        [scriptblock]$Action
    )

    if ($AuditOnly) {
        Write-Output "[AUDIT MODE] $Message"
    }
    else {
        Write-Output $Message
        & $Action
    }
}

Write-Output "Starting Windows Workstation Baseline Configuration..."

if (-not $AuditOnly) {
    Start-Transcript -Path ".\baseline-log.txt" -Append
}

# --------------------------------------------------
# 1. Firewall Configuration
# --------------------------------------------------
Invoke-Action "Enabling Windows Firewall profiles..." {
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
}

# --------------------------------------------------
# 2. Windows Update Service Configuration
# --------------------------------------------------
Invoke-Action "Configuring Windows Update service..." {
    Set-Service -Name wuauserv -StartupType Automatic
    Start-Service -Name wuauserv
}

# --------------------------------------------------
# 3. Power & Lock Screen Configuration
# --------------------------------------------------
Invoke-Action "Configuring power timeouts..." {
    powercfg -change -monitor-timeout-ac 15
    powercfg -change -monitor-timeout-dc 10
}

# --------------------------------------------------
# 4. Optional Consumer Bloatware Removal
# --------------------------------------------------
if ($RemoveBloat) {
    Invoke-Action "Removing common consumer applications..." {
        Get-AppxPackage *Xbox* | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxPackage *ZuneMusic* | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxPackage *BingWeather* | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxPackage *SkypeApp* | Remove-AppxPackage -ErrorAction SilentlyContinue
    }
}

# --------------------------------------------------
# 5. BitLocker Status Check (Read-Only)
# --------------------------------------------------
Write-Output "Checking BitLocker status..."
Get-BitLockerVolume

Write-Output "Baseline configuration complete."

if (-not $AuditOnly) {
    Stop-Transcript
}
