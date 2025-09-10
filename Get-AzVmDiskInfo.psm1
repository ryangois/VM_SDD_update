function Get-AzVmDiskInfo {
    [CmdletBinding()]
    param (
        [string]$OutputPath = "output.csv"
    )

    Connect-AzAccount

    $results = @()

    Get-AzSubscription | ForEach-Object {
        Set-AzContext -SubscriptionId $_.Id

        $vms = Get-AzVM
        foreach ($vm in $vms) {
            try {
                $vmName = $vm.Name
                $resourceGroup = $vm.ResourceGroupName

                # OS
                $osDisk = $vm.StorageProfile.OSDisk
                $results += [PSCustomObject]@{
                    SubscriptionId = $_.Id
                    ResourceGroup  = $resourceGroup
                    VMName         = $vmName
                    DiskType       = "OSDisk"
                    DiskName       = $osDisk.Name
                    StorageType    = $osDisk.ManagedDisk.StorageAccountType
                }

                # Data
                foreach ($dataDisk in $vm.StorageProfile.DataDisks) {
                    $results += [PSCustomObject]@{
                        SubscriptionId = $_.Id
                        ResourceGroup  = $resourceGroup
                        VMName         = $vmName
                        DiskType       = "DataDisk"
                        DiskName       = $dataDisk.Name
                        StorageType    = $dataDisk.ManagedDisk.StorageAccountType
                    }
                }
            }
            catch {
                Write-Warning "Erro ao processar VM $($vm.Name): $_"
            }
        }
    }

    $results | Export-Csv -Path $OutputPath -NoTypeInformation
    Write-Output "Dados exportados para $OutputPath"
}