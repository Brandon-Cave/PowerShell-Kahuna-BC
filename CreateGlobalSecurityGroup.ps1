$OUName     = "London"
$DomainDN   = "DC=Adatum,DC=com"
$OUPath     = "OU=$OUName,$DomainDN"
$GroupName  = "London Users"

# Check if the group already exists
if (Get-ADGroup -Filter {Name -eq $GroupName} -SearchBase $OUPath) 
   {
    Write-Host "The group '$GroupName' already exists in the OU '$OUName'."
  } 
else 
   {
    # Create the group if it does not exist
    New-ADGroup -Name $GroupName -GroupScope Global -GroupCategory Security -Path $OUPath
    Write-Host "The group '$GroupName' has been created in the OU '$OUName'."
   }
