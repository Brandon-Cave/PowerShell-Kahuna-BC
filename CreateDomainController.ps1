# Ensure the script is run with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
{
    Write-Error "This script must be run as an administrator."
    exit
}

# Import necessary modules from Windows PowerShell session for compatibility.
# The ServerManager module provides Install-WindowsFeature, and ADDSDeployment module contains Install-ADDSForest.
Import-Module ServerManager -UseWindowsPowerShell
Import-Module ADDSDeployment -UseWindowsPowerShell

# Install the Active Directory Domain Services (AD DS) role along with management tools.
Write-Output "Installing AD DS role and management tools..."
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Define parameters for promotion.
$DomainName        = "example.com"      # Change this to your desired domain name.
$NetBIOSName       = "EXAMPLE"          # Change this to your desired NetBIOS name.
# Convert a plain text password to a secure string for the Directory Services Restore Mode (DSRM) account.
$SafeModePassword  = ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force

# Confirm the settings (optional)
Write-Output "Preparing to promote the server to Domain Controller for a new forest."
Write-Output "Domain Name       : $DomainName"
Write-Output "NetBIOS Name      : $NetBIOSName"
Write-Output "DSRM Password     : (hidden for security)"
Write-Output "Press Enter to continue, or Ctrl+C to cancel..."
[void][System.Console]::ReadLine()

# Promote the server to Domain Controller by creating a new forest.
Write-Output "Promoting the server to Domain Controller..."
Install-ADDSForest `
    -DomainName $DomainName `
    -DomainNetbiosName $NetBIOSName `
    -ForestMode "Win2016" `            # Set appropriate ForestFunctionalLevel, e.g., "Win2012R2", "Win2016" or "Win2019"
    -DomainMode "Win2016" `             # Set appropriate DomainFunctionalLevel
    -SafeModeAdministratorPassword $SafeModePassword `
    -InstallDns `
    -Force:$true `
    -Confirm:$false

# Note: After the promotion, the server will automatically reboot.
