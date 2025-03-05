$PSVersionTable

$cred = Get-Credential -Message "Enter an admin username and password for the operating system"

$vmParams = @{
            ResourceGroupName = 'ResourceGroup1'
            Name = 'TestVM1'
            Size = 'Standard_D2s_v3'
            Location = 'eastus'
            ImageName = 'Win2019Datacenter'
            PublicIpAddressName = 'TestPublicIp'
            Credential = $cred
            OpenPorts = 3389
             }

$newVM1 = New-AzVM @vmParams

$NewVM1

$newVM1.OSProfile | Select-Object ComputerName,AdminUsername
       
$newVM1 | Get-AzNetworkInterface | Select-Object -ExpandProperty IpConfigurations | Select-Object Name,PrivateIpAddress
    
 $rgName = $NewVM1.ResourceGroupName 

 $publicIp = Get-AzPublicIpAddress -Name TestPublicIp -ResourceGroupName $rgName

 $publicIp | Select-Object Name,IpAddress,@{label='FQDN';expression={$_.DnsSettings.Fqdn}}

 mstsc.exe /v $publicIp.IpAddress

 $VirtualMachine = Get-AzVM -ResourceGroupName "ResourceGroup1" -Name "TestVM1"

 Add-AzVMDataDisk -VM $VirtualMachine -Name "disk1" -LUN 0 -Caching ReadOnly -DiskSizeinGB 1 -CreateOption Empty

 Update-AzVM -ResourceGroupName "ResourceGroup1" -VM $VirtualMachine

 Remove-AzResourceGroup -Name $rgName -Force