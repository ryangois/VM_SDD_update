
# Authenticate using Service Principal
$clientId = $env:AZURE_CLIENT_ID
$clientSecret = $env:AZURE_SECRET
$tenantId = $env:AZURE_TENANT_ID

$securePassword = ConvertTo-SecureString -String $clientSecret -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $clientId, $securePassword

Connect-AzAccount -ServicePrincipal -Credential $cred -Tenant $tenantId

# Get all subscriptions
$subscriptions = Get-AzSubscription

foreach ($sub in $subscriptions) {
    Set-AzContext -SubscriptionId $sub.Id

    Write-Output "Processing subscription: $($sub.Name)"

    $vms = Get-AzVM
    foreach ($vm in $vms) {
        try {
            $vmName = $vm.Name
            $resourceGroup = $vm.ResourceGroupName

            # OS Disk
            $osDisk = $vm.StorageProfile.OSDisk
            Write-Output "VM: $vmName | OS Disk: $($osDisk.Name) | Type: $($osDisk.ManagedDisk.StorageAccountType)"

            # Data Disks
            foreach ($dataDisk in $vm.StorageProfile.DataDisks) {
                Write-Output "VM: $vmName | Data Disk: $($dataDisk.Name) | Type: $($dataDisk.ManagedDisk.StorageAccountType)"
            }
        }
        catch {
            Write-Warning "Erro ao processar VM $($vm.Name): $_"
        }
    }
}
