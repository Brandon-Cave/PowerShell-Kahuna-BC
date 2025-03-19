# Ensure the script is run with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
{
    Write-Error "This script must be run as an administrator."
    exit
}

# Import necessary modules required for the script to function correctly from Windows PowerShell session for compatibility.
# The ServerManager module provides Install-WindowsFeature, and ActiveDirectory module contains Install-ADDSForest.

# Check if the ServerManager module is available before importing it.
if (Get-Module -ListAvailable -Name ServerManager) {
    Import-Module ServerManager
    Write-Output "ServerManager module imported successfully."
} else {
    Write-Error "The ServerManager module is not available on this system."
    exit
}
 
# Check if the ActiveDirectory module is available before importing it.
if (Get-Module -ListAvailable -Name ActiveDirectory) {
    Import-Module ActiveDirectory
    Write-Output "ActiveDirectory module imported successfully."
} else {
    Write-Error "The ActiveDirectory module is not available on this system."
    exit
}

# Determine the servers available in the existing forest.
Write-Output "Here are the existing servers in the forest:"
Get-ADComputer -Filter {OperatingSystem -like "*Server*"} -Properties OperatingSystem | Format-Table Name, OperatingSystem -AutoSize

# Define the name of the new domain controller.
$newdcs = Read-Host "Please enter the name of the server you want to use as the new domain controller"

# Install the Active Directory Domain Services (AD DS) role along with management tools on the remote server.
Write-Output "Installing AD DS role and management tools on $newdcs..."
Invoke-Command -ComputerName $newdcs -ScriptBlock {
    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
}

# Ask the user whether the domain controller is in a new or existing forest.
$ForestType = Read-Host "Is this domain controller for a new forest or an existing forest? (Enter '1' for new or '2' for existing)"

if ($ForestType -eq '1') {
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
    Invoke-Command -ComputerName $newdcs -ScriptBlock {
        param (
            $DomainName,
            $NetBIOSName,
            $SafeModePassword
        )
        Install-ADDSForest `
            -DomainName $DomainName `
            -DomainNetbiosName $NetBIOSName `
            -ForestMode "Win2016" `            # Set appropriate ForestFunctionalLevel, e.g., "Win2012R2", "Win2016", "Win2019", or "Win2022"
            -DomainMode "Win2016" `             # Set appropriate DomainFunctionalLevel
            -SafeModeAdministratorPassword $SafeModePassword `
            -InstallDns `
            -Force:$true `
            -Confirm:$false
    } -ArgumentList $DomainName, $NetBIOSName, $SafeModePassword
} 
elseif ($ForestType -eq '2') {
        
    # Ask the user to define parameters for promotion.
    $DomainName        = Read-Host "Please enter the domain name of the existing forest"
    $NetBIOSName       = Read-Host "Please enter the NetBIOS name of the existing forest"

    # Ask the user to input the password for the Directory Services Restore Mode (DSRM) account and convert to a secure string.
    $PlainPassword = Read-Host "Please enter the DSRM password" -AsSecureString
    $SafeModePassword = $PlainPassword

    # Confirm the settings (optional)
    Write-Output "Preparing to promote the server to Domain Controller for an existing forest."
    Write-Output "Domain Name       : $DomainName"
    Write-Output "NetBIOS Name      : $NetBIOSName"
    Write-Output "DSRM Password     : (hidden for security)"
    Write-Output "Press Enter to continue, or Ctrl+C to cancel..."
    [void][System.Console]::ReadLine()

    # Promote the server to Domain Controller by adding it to an existing forest.
    Write-Output "Promoting the server to Domain Controller..."
    Invoke-Command -ComputerName $newdcs -ScriptBlock {
        param (
            $DomainName,
            $SafeModePassword
        )
        Install-ADDSDomainController `
            -DomainName $DomainName `
            -SafeModeAdministratorPassword $SafeModePassword `
            -InstallDns `
            -Force:$true `
            -Confirm:$false
    } -ArgumentList $DomainName, $SafeModePassword
} 
else {
    Write-Error "Invalid input. Please enter '1' for new or '2' for existing."
    exit
}

# Note: After the promotion, the server will automatically reboot.
