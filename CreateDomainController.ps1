# Ensure the script is run with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
{
    Write-Error "This script must be run as an administrator."
    exit
}

# Import necessary modules required for the script to function correctly from Windows PowerShell session for compatibility.
# The ServerManager module provides Install-WindowsFeature, and ActiveDirectory module contains Install-ADDSForest.
Import-Module ServerManager 
# Check if the ActiveDirectory module is available before importing it.
if (Get-Module -ListAvailable -Name ActiveDirectory) {
    Import-Module ActiveDirectory
} else {
    Write-Error "The ActiveDirectory module is not available on this system."
    exit
}

# Define the name of the new domain controller.
$newdcs = Read-Host "Please enter the name of the new domain controller"

# Install the Active Directory Domain Services (AD DS) role along with management tools.
Write-Output "Installing AD DS role and management tools..."
Install-WindowsFeature -ComputerName $newdcs AD-Domain-Services -IncludeManagementTools

# Ask the user to define parameters for promotion.
$DomainName        = Read-Host "Please enter the desired domain name"
$NetBIOSName       = Read-Host "Please enter the desired NetBIOS name"

# Ask the user to input the password for the Directory Services Restore Mode (DSRM) account and convert to a secure string.
$PlainPassword = Read-Host "Please enter the DSRM password" -AsSecureString
$SafeModePassword = $PlainPassword

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
