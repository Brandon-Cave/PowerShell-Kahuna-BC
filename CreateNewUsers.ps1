# Import the Active Directory module
Import-Module ActiveDirectory

# Path to the CSV file
$csvPath = 'C:\newusers.csv'

# Import the CSV file
$userList = Import-Csv -Path $csvPath

# Loop through each user in the CSV file
foreach ($user in $userList) {
    # Create the new user
    try {
        New-ADUser -Name $user.Name 
                   -SamAccountName $user.SamAccountName 
                   -GivenName $user.GivenName 
                   -Surname $user.Surname 
                   -UserPrincipalName $user.UserPrincipalName 
                   -Path $user.OU 
                   -AccountPassword (if (![string]::IsNullOrEmpty($user.Password)) { (ConvertTo-SecureString $user.Password -AsPlainText -Force) } else { throw "Password cannot be null or empty" }) `
                   -Enabled $true 
                   -EmailAddress $user.EmailAddress 
                   -DisplayName $user.DisplayName 
                   -Description $user.Description
        Write-Host "User $($user.SamAccountName) created successfully."
    }
    catch {
        Write-Host "Failed to create user $($user.SamAccountName). Error: $_"
    }
}

Write-Host "User creation process completed."
