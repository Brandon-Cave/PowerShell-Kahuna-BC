$OUName     = Read-Host "Enter the name of the OU"
$DomainDN   = Read-Host "Enter the Domain Distinguished Name (e.g., DC=Adatum,DC=com)"
$OUPath     = "OU=$OUName,$DomainDN"
$GroupName  = Read-Host "Enter the name of the group"
$MovingUsers = (Get-ADUser -Filter {City -eq $OUName} -Properties City)
$UserCount = $MovingUsers.Count
foreach ($user in $MovingUsers)
{
    Move-ADObject -Identity $user -TargetPath $OUPath
    Add-ADGroupMember -Identity $GroupName -Members $user
}
Write-Host "All '$UserCount' users with '$OUName' as their city have been moved to the '$OUName' OU and added to the $GroupName security group."
