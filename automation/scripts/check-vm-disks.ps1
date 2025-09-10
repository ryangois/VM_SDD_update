
param (
    [string]$OutputPath = "output.csv",
    [switch]$DryRun
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

            # OS Disk
            $osDisk = $vm.StorageProfile.OSDisk
            $results += [PSCustomObject]@{
                SubscriptionId = $_.Id
                ResourceGroup  = $resourceGroup
                VMName         = $vmName
                DiskType       = "OSDisk"
                DiskName       = $osDisk.Name
                StorageType    = $osDisk.ManagedDisk.StorageAccountType
            }
            Update-DiskType -SubscriptionId $_.Id -ResourceGroup $resourceGroup -VMName $vmName -DiskName $osDisk.Name -CurrentType $osDisk.ManagedDisk.StorageAccountType @DryRun

            # Data Disks
            foreach ($dataDisk in $vm.StorageProfile.DataDisks) {
                $results += [PSCustomObject]@{
                    SubscriptionId = $_.Id
                    ResourceGroup  = $resourceGroup
                    VMName         = $vmName
                    DiskType       = "DataDisk"
                    DiskName       = $dataDisk.Name
                    StorageType    = $dataDisk.ManagedDisk.StorageAccountType
                }
                Update-DiskType -SubscriptionId $_.Id -ResourceGroup $resourceGroup -VMName $vmName -DiskName $dataDisk.Name -CurrentType $dataDisk.ManagedDisk.StorageAccountType @DryRun
            }
        } catch {
            Write-Warning "[ERROR] Failed to process VM $($vm.Name): $_"
        }
    }
}

$results | Export-Csv -Path $OutputPath -NoTypeInformation
Write-Output "[INFO] Disk report exported to $OutputPath"
