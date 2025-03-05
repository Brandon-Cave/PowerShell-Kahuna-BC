# Global Security Group Creation Script # 
$OUName="London" # OU Name
$DomainDN="DC=Adatum,DC=com" # Domain DN
$OUPath="OU=$OUName,$DomainDN" # OU Path
$GroupName="London Users" # Group Name
$SamAccountName="LondonUsers" # SAM account name 
$existingGroup=Get-ADGroup -Filter "Name -eq '$GroupName'" -SearchBase $OUPath -ErrorAction SilentlyContinueif(-not $existingGroup)
    {
    try{
        New-ADGroup -Name $GroupName -SamAccountName $SamAccountName -Path $OUPath -GroupCategory Security -GroupScope Global -Description "Global Security Group for London Users" -ErrorAction Stop
        Write-Host "Group '$GroupName' created in '$OUPath'."}
    catch{Write-Error "Error creating group '$GroupName': $_"}
    }
    else{Write-Host "Group '$GroupName' exists in '$OUPath'."}
