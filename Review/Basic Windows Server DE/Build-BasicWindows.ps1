
param (
    $Name,
    $VMID,
    $TemplateID = 110,
    $Node = "pve01",    # This is my Lab Node
    $Storage = "ProxiSCSI"

)

# Function to check if the VM lock is released
function Wait-VMUnlock {
    $timeout = [System.DateTime]::Now.AddMinutes(15)  # Set a 30-minute timeout

    while ($true) {
        $status = (Get-PveVm -VmIdOrName $VMID).lock

        if ($status -ne "clone") {
            Write-Host "VM lock is released. Proceed with further steps."
            return  # Exit the function
        }

        if ([System.DateTime]::Now -ge $timeout) {
            # Timeout reached, throw an error
            throw "Timeout reached while waiting for VM lock to release."
        }

        Write-Host "Cloning in progress..."
        Start-Sleep -Seconds 30  # Adjust the sleep duration as needed
    }
}

$GetLABStatus = Get-PveVm -VmIdOrName $VMID

if ($null -ne $GetLABStatus) {
    Write-Host "$($GetLABStatus.name) exists and is $($GetLABStatus.status)"

} else {

    Write-Host "$Name does not exist."
    New-PveNodesQemuClone -Vmid $TemplateID -Full -Node $Node -Name $Name -Storage $Storage -Newid $VMID
    Start-Sleep -Seconds 30
    Write-host "Building VM - This can take up to 20 minutes"
    Wait-VMUnlock

     }
