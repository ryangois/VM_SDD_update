
function Update-DiskType {
    [CmdletBinding()]
    param (
        [string]$SubscriptionId,
        [string]$ResourceGroup,
        [string]$VMName,
        [string]$DiskName,
        [string]$CurrentType,
        [switch]$DryRun
    )

    if ($CurrentType -eq "StandardHDD_LRS") {
        Write-Output "[INFO] VM: $VMName | Disk: $DiskName | Current Type: $CurrentType"

        if ($DryRun) {
            Write-Output "[DRY RUN] Would stop VM, update disk to StandardSSD_LRS, and restart VM."
        } else {
            try {
                Write-Output "Stopping VM '$VMName'..."
                Stop-AzVM -Name $VMName -ResourceGroupName $ResourceGroup -Force

                Write-Output "Updating disk '$DiskName' to StandardSSD_LRS..."
                Update-AzDisk -ResourceGroupName $ResourceGroup -DiskName $DiskName -SkuName StandardSSD_LRS

                Write-Output "Starting VM '$VMName'..."
                Start-AzVM -Name $VMName -ResourceGroupName $ResourceGroup

                # Tag VM
                Set-AzResource -ResourceId (Get-AzVM -Name $VMName -ResourceGroupName $ResourceGroup).Id -Tag @{DiskUpgraded="True"} -Force

                Write-Output "[SUCCESS] Disk '$DiskName' upgraded and VM restarted."
            } catch {
                Write-Warning "[ERROR] Failed to update disk '$DiskName' on VM '$VMName': $_"
            }
        }
    } else {
        Write-Output "[SKIP] VM: $VMName | Disk: $DiskName already uses $CurrentType."
    }
}
