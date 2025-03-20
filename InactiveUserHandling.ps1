function Get-InactiveUsers {
    # Import the Active Directory module
    Import-Module ActiveDirectory

    # Prompt the user to enter the number of days of inactivity
    $daysInactive = Read-Host "Enter the number of days of inactivity"

    # Calculate the date to compare against
    $inactiveDate = (Get-Date).AddDays(-$daysInactive)

    # Convert the date to Windows File Time format for use in comparison against lastLogonTimestamp
    $windowstimeformat = [Math]::Floor(($inactiveDate.ToFileTimeUtc() - 116444736000000000) / 10000000)

    # Ask the user if they want to query a specific Domain Controller
    $queryDC = Read-Host "Do you want to query a specific Domain Controller? (Y/N)"
    if ($queryDC -eq 'Y') {
        $domainController = Read-Host "Enter the Domain Controller to query"
    } 
    else {
        $domainController = $null
    }

    # Get all users who haven't logged in since the inactive date using LDAP filter
    $ldapFilter = "(&(objectCategory=person)(objectClass=user)(|(lastLogonTimestamp<=$windowstimeformat)(!lastLogonTimestamp=*)))"
    if ($domainController) {
        $inactiveUsers = Get-ADUser -LDAPFilter $ldapFilter -Properties lastLogonTimestamp -Server $domainController
    } 
    else {
        $inactiveUsers = Get-ADUser -LDAPFilter $ldapFilter -Properties lastLogonTimestamp
    }

    # Output the inactive users
    Write-Host "There are a total of '$($inactiveUsers.Count)' inactive users."

    # Optionally, you can display the list of inactive users based on user prompt
    $display = Read-Host "Do you want to display the list of inactive users? (Y/N)"
    if ($display -eq 'Y') {
        $inactiveUsers | Select-Object SamAccountName, Name, lastLogonTimestamp | Format-Table -AutoSize
    }

    # Optionally, you can prompt the user to confirm before disabling accounts 
    $confirm = Read-Host "Do you want to disable these accounts? (Y/N)"
    if ($confirm -eq 'Y') {
        foreach ($user in $inactiveUsers) {
            Disable-ADAccount -Identity $user.SamAccountName 
            Write-Host "Disabled user account: $($user.SamAccountName)"
        }
    } 
    else {
        Write-Host "No accounts were disabled."
    }

    # Optionally, prompt the user if they want to export the list of inactive users to a CSV file
    $export = Read-Host "Do you want to export the list of inactive users to a CSV file? (Y/N)"
    if ($export -eq 'Y') {
        $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
        $filePath = "C:\InactiveUsers_$timestamp.csv"
        $inactiveUsers | Select-Object SamAccountName, Name, lastLogonTimestamp, @{Name="Date Deactivated";Expression={(Get-Date)}} | Export-Csv -Path $filePath -NoTypeInformation
        Write-Host "The list of inactive users has been exported to $filePath"
    } 
    else {
        Write-Host "The list of inactive users was not exported."
    }
}