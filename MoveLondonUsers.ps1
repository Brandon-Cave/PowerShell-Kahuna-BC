$OUName     = "London"
$DomainDN   = "DC=Adatum,DC=com"
$OUPath     = "OU=$OUName,$DomainDN"
$GroupName  = "London Users"
$LondonUsers = Get-ADUser -Filter {City -eq $OUName} -Properties City 

foreach ($user in $LondonUsers)
{
    Move-ADObject -Identity $user -TargetPath $OUPath
    Add-ADGroupMember -Identity $GroupName -Members $user
}
Write-Host "All users in the '$OUName' OU have been moved to the '$OUName' OU and added to the $GroupName security group."
