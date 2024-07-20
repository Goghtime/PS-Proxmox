param(
    [string]$ConfigFile = "lxc-template",

    [Parameter(Mandatory=$true)]
    [string]$FQDNorIP
)

# Find Root Path
$rootPath = Split-Path -Path $PSScriptRoot -Parent

# Load the environment configuration
$ConfigPath = Get-Content -Path "D:\Projects\PS-Proxmox\configs\$ConfigFile.json" | ConvertFrom-Json
$ConfigPath = Get-Content -Path "$rootPath\configs\$ConfigFile.json" | ConvertFrom-Json

# Create a new LXC container and capture the UPID
Write-host "Building LXC Container"
$upidResponse = & "$rootPath\build\New-lxc.ps1" -ConfigFile $ConfigFile -FQDNorIP $FQDNorIP
$upid = $upidResponse.data

# Initialize the timeout and stopwatch
$timeoutMinutes = 10
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

$status = $null
do {
    Start-Sleep -Seconds 5

    # Get the task details
    $taskData = & "$rootPath\task\get-tasks.ps1" -FQDNorIP $FQDNorIP

    # Filter the task data to find the task with the specified UPID
    $filteredData = $taskData.data | Where-Object { $_.upid -eq $upid }

    # Check if the status exists
    if ($filteredData -and $filteredData.status) {
        $status = $filteredData.status
    }

    # Check if the timeout has been reached
    if ($stopwatch.Elapsed.TotalMinutes -ge $timeoutMinutes) {
        Write-Error "Timeout reached while waiting for task completion."
        break
    }

    if ($status -and $status -ne "OK") {
        Write-Error "Task failed with status: $status"
        break
    }
} while (-not $status -or $status -ne "OK")

# Stop the stopwatch
$stopwatch.Stop()

# Output the final task data
if ($filteredData.status -eq "ok") {
    & "$rootPath\task\Manage-LXCStatus.ps1" -node $ConfigPath.node -vmid $ConfigPath.vmid -action start -FQDNorIP $FQDNorIP
    write-host "VM has been started"
} else {
    Write-host "unable to start"
    Exit
}


# Extract the IP address 
$components = ($ConfigPath.net0).Split(",")
$ipComponent = $components | Where-Object { $_ -like "ip=*" }

if ($ipComponent) {
    $ip = (($ipComponent -split "=")[1] -split "/")[0]
} else {
    Write-Error "IP component not found in the input string."
}

$maxAttempts = 10
$attempts = 0
$pingSuccess = $false

do {
    $pingResult = Test-Connection -Ping $ip -Count 1 -ErrorAction SilentlyContinue
    $attempts++
    
    if ($pingResult.Status -eq "Success") {
        $pingSuccess = $true
        Write-Host "Ping to $ConfigFile successful."
    } else {
        Write-Host "Ping attempt $attempts to $ConfigFile failed. Retrying..."
        Start-Sleep -Seconds 1
    }

} while (-not $pingSuccess -and $attempts -lt $maxAttempts)

if (-not $pingSuccess) {
    Write-Host "Ping to $ConfigFile failed after $maxAttempts attempts."
    Exit
}

write-host "configure container"
$container_config = & "$rootPath\task\Run-SSHCommand.ps1" -remoteHost "root@$ip" -scriptFile $ConfigFile

# Check if the script completed successfully
$logContent = Get-Content -Path "$rootPath\logs\remote_setup.log"
if ($logContent -contains "All tasks completed.") {
    Write-Output "Remote setup completed successfully." | Tee-Object -FilePath "$rootPath\logs\remote_setup.log" -Append
    
} else {
    Write-Output "Remote setup failed." | Tee-Object -FilePath "$rootPath\logs\remote_setup.log" -Append
    EXIT
}

# Initial check
$data = & "$rootPath\task\get-LXC-config.ps1" -node $node -vmid $vmid -FQDNorIP $FQDNorIP
Write-Output "Initial LXC config:"
$data.data

Write-host "Removing net0 and hostname"
$body = @{
    delete = "net0"
    delete = "hostname"
}

& "$rootPath\task\Modify-LXC-config.ps1" -node $ConfigPath.node -vmid $ConfigPath.vmid -FQDNorIP $FQDNorIP -body $body


# Final check
$data = & "$rootPath\task\get-LXC-config.ps1" -node $node -vmid $vmid -FQDNorIP $FQDNorIP
Write-Output "Final LXC config:"
$data.data

# Check for presence of hostname and net0
if ($data.data.hostname -or $data.data.net0) {
    Write-Error "Failed to remove hostname and/or net0 from the LXC config."
} else {
    Write-Output "Hostname and net0 have been successfully removed."
    $status = & "$rootPath\task\Get-LXC.ps1" -FQDNorIP $FQDNorIP | Where-Object { $_.vmid -eq 5000 } | select status
    if($status.status -eq "stopped"){
        write-host "$ConfigFile has been powered down"
    } else {
         write-host "unable to power down $ConfigFile"
         EXIT
    }
    
}




