# Setting the OU name, Domain, new Group Name, Group Type, and Group Scope.
$OUName = Read-Host -Prompt "Please enter the OU Name"
$DomainDN = Read-Host -Prompt "Please enter the Domain Distinguished Name (e.g., DC=Example,DC=com)"
$OUPath = "OU=$OUName,$DomainDN"
$GroupName = Read-Host -Prompt "Please enter the Group Name"
$GroupType = Read-Host -Prompt "Please enter the Group Type (Security or Distribution)"
$GroupScope = Read-Host -Prompt "Please enter the Group Scope (Global, DomainLocal, Universal)"

# Check if the OU exists
$ExistingOU = Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$OUPath'"
if ($ExistingOU) {
  Write-Host "The OU '$OUName' already exists." -ForegroundColor Green
} 
else {
  # Create the OU if it does not exist
  Write-Host "The OU '$OUName' does not exist. Creating the OU." -ForegroundColor Yellow
  New-ADOrganizationalUnit -Name $OUName -Path $DomainDN
  Write-Host "The OU '$OUName' has been created in the domain '$DomainDN'."
}

# Check if the group already exists
$ExistingGroup = Get-ADGroup -Filter "Name -eq '$GroupName'"
if ($ExistingGroup) {
  Write-Host "A group with the name '$GroupName' already exists." -ForegroundColor Green
} 
else {
  # Create the group if it does not exist
  Write-Host "No group with the name '$GroupName' currently exists." -ForegroundColor Yellow
  New-ADGroup -Name $GroupName -GroupScope $GroupScope -GroupCategory $GroupType -Path $OUPath
  Write-Host "The group '$GroupName' has been created in the OU '$OUName' with type '$GroupType' and scope '$GroupScope'."
}
