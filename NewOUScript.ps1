$OUName     = "Paris"
$DomainDN   = "DC=Adatum,DC=COM"
$OUPath     = "OU=$OUName,$DomainDN"

#check to see if the OU already exists
if (-not (Get-ADOrganizationalUnit -Filter {Name -eq $OUName} -SearchBase $DomainDN)) 
    { 
    #create the new OU if it doesn't exist
    New-ADOrganizationalUnit -Name $OUName -Path $DomainDN
    Write-Host "OU $OUName created succesfully"    
    }
else {
    # Action when all if and elseif conditions are false
    Write-Host "OU $OUName already exists"
}