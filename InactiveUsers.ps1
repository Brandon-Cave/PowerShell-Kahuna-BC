# Import the Active Directory module
Import-Module ActiveDirectory

# Define the number of days of inactivity
$daysInactive = 30

# Calculate the date to compare against
$inactiveDate = (Get-Date).AddDays(-$daysInactive)

# Get all users who haven't logged in since the inactive date
$inactiveUsers = Get-ADUser -Filter {LastLogonDate -lt $inactiveDate} -Properties LastLogonDate

# Loop through each inactive user and disable their account
foreach ($user in $inactiveUsers) {
    Disable-ADAccount -Identity $user.SamAccountName
    Write-Output "Disabled account for user: $($user.SamAccountName)"
}

#Second attempt using a conversion to Windows File Time format

# Calculate the date to compare against
$inactiveDate = (Get-Date).AddDays(-$daysInactive)

# Convert the date to Windows File Time format for use in comparison against lastLogonTimestamp
$windowstimeformat = $inactiveDate.ToFileTimeUtc()