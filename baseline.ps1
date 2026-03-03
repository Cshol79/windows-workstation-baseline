# Windows Workstation Baseline Script
# Author: Christopher B. Sholmire
# Purpose: Apply foundational security and configuration settings

Write-Output "Starting baseline configuration..."

# --- Enable Windows Firewall Profiles ---
Write-Output "Enabling Windows Firewall profiles..."
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

# --- Ensure Windows Update Service is Enabled ---
Write-Output "Ensuring Windows Update service is set to Automatic..."
Set-Service -Name wuauserv -StartupType Automatic

Write-Output "Baseline configuration complete."
