param(
    [string]$ConfigFile = "lxc-template",
    [Parameter(Mandatory=$true)]
    [string]$FQDNorIP
)

# Find Root Path
$rootPath = Split-Path -Path $PSScriptRoot -Parent
Import-Module "$rootPath\functions\Wait-ForTaskCompletion.ps1" -Force -DisableNameChecking
Import-Module "$rootPath\functions\Extract-IP.ps1" -Force -DisableNameChecking
Import-Module "$rootPath\functions\Test-Ping.ps1" -Force -DisableNameChecking

# Load the environment configuration
$NodePath = Get-Content -Path "$rootPath\env\nodes.json" | ConvertFrom-Json
$ConfigPath = Get-Content -Path "$rootPath\configs\$ConfigFile.json" | ConvertFrom-Json

# Create a log file with a timestamp
$logFilePath = "$rootPath\logs\$ConfigFile`_$(Get-Date -Format 'yyyyMMdd_HHmmss')_setup.log"

# Function to write log entries
function Write-Log {
    param (
        [string]$message,
        [switch]$isError
    )
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $entryType = if ($isError) { "ERROR" } else { "INFO" }
    $logEntry = "$timestamp [$entryType] $message"
    Write-Output $logEntry | Tee-Object -FilePath $logFilePath -Append
}

#######################################################

Write-Log "Building LXC Container"

# Create a new LXC container and capture the UPID
$upidResponse = & "$rootPath\build\New-lxc.ps1" -ConfigFile $ConfigFile -FQDNorIP $FQDNorIP
$upid = $upidResponse.data

if (-not $upid) {
    Write-Log "Failed to retrieve UPID. Exiting." -isError
    exit 1
}

$BuildStatus = Wait-ForTaskCompletion -FQDNorIP $FQDNorIP -upid $upid

# Output the final task data
if ($BuildStatus -eq $true) {
    try {
        $startlxc = & "$rootPath\task\Manage-LXCStatus.ps1" -node $ConfigPath.node -vmid $ConfigPath.vmid -action start -FQDNorIP $FQDNorIP
        Write-Log "VM has been started"
    } catch {
        Write-Log "Failed to start the VM: $_" -isError
        exit 1
    }
} else {
    Write-Log "Unable to start the VM" -isError
    exit 1
}

#######################################################

# Extract the IP address
try {
    $ip = Extract-IP -netConfig $ConfigPath.net0
    Write-Log "Extracted IP address: $ip"
} catch {
    Write-Log "Failed to extract IP address: $_" -isError
    exit 1
}

# Test IP reachability
if (-not (Test-Ping -ip $ip)) {
    Write-Log "Ping to $ip failed after multiple attempts." -isError
    exit 1
}

#######################################################
<#
Write-Log "Configuring container"

try {
    # Run the SSH command to configure the container
    $containerConfig = & "$rootPath\task\Run-SSHCommand.ps1" -remoteHost "root@$ip" -scriptFile "scripts/$($ConfigPath.ScriptFile)"

    # Check if the script completed successfully
    $logfile = $($ConfigPath.ScriptFile).TrimEnd('.sh')
    
    $logFilePathConfig = "$rootPath\logs\$logfile.log"
    if (Test-Path -Path $logFilePathConfig) {
        $logContent = Get-Content -Path $logFilePathConfig

        if ($logContent -contains "All tasks completed.") {
            Write-Log "Remote setup completed successfully."
        } else {
            Write-Log "Remote setup failed." -isError
            exit 1
        }
    } else {
        Write-Log "Log file not found: $logFilePathConfig" -isError
        exit 1
    }
} catch {
    Write-Log "An error occurred while configuring the container: $_" -isError
    exit 1
}
#>
#######################################################

# Initial check
$data = & "$rootPath\task\get-LXC-config.ps1" -node $ConfigPath.node -vmid $ConfigPath.vmid -FQDNorIP $FQDNorIP
Write-Log "Initial LXC config: $($data.data | Out-String)"

# LXC Edit
Write-Log "Removing net0 and hostname"
$body = @{
    delete = "net0,hostname"
}

& "$rootPath\task\Modify-LXC-config.ps1" -node $ConfigPath.node -vmid $ConfigPath.vmid -FQDNorIP $FQDNorIP -body $body

# Final check
$data = & "$rootPath\task\get-LXC-config.ps1" -node $ConfigPath.node -vmid $ConfigPath.vmid -FQDNorIP $FQDNorIP
Write-Log "Final LXC config: $($data.data | Out-String)"

# Check for presence of hostname and net0
if ($data.data.hostname -or $data.data.net0) {
    Write-Log "Failed to remove hostname and/or net0 from the LXC config." -isError
    exit 1
} else {
    Write-Log "Hostname and net0 have been successfully removed."
    $upidResponse = & "$rootPath\task\Manage-LXCStatus.ps1" -node $ConfigPath.node -vmid $ConfigPath.vmid -action stop -FQDNorIP $FQDNorIP
    $stopupid = $upidResponse.data

    if (-not $stopupid) {
        Write-Log "Failed to retrieve UPID for stopping. Exiting." -isError
        exit 1
    }

    $ShutdownStatus = Wait-ForTaskCompletion -FQDNorIP $FQDNorIP -upid $stopupid

    if ($ShutdownStatus -ne $true) {
        Write-Log "Unable to shutdown." -isError
        exit 1
    }
}

#######################################################

if ($ShutdownStatus -eq $true) {
    $Backup_status = & "$rootPath\task\Create-vzdump.ps1" -FQDNorIP $FQDNorIP -node $ConfigPath.node -vmid $ConfigPath.vmid

    $BackupTask = Wait-ForTaskCompletion -FQDNorIP $FQDNorIP -upid $Backup_status.data
    if ($BackupTask -eq $true) {
        $archivePathfetch = & "$rootPath\task\Get-TaskLog.ps1" -FQDNorIP $FQDNorIP -upid $Backup_status.data -node $ConfigPath.node
        $archivePathLine = $archivePathfetch.data | Select-String -Pattern "creating vzdump archive"

        if ($archivePathLine -match "'([^']+)'") {
            $archivePath = $matches[1]
            Write-Log "The archive path is: $archivePath"
        } else {
            Write-Log "Archive path not found" -isError
            exit 1
        }
    } else {
        Write-Log "Backup task failed" -isError
        exit 1
    }
} else {
    Write-Log "Unable to shutdown." -isError
    exit 1
}

#######################################################

Write-Log "Add $archivePath to tmp Backup_Script"

# Read the content of the original shell script
$scriptContent = Get-Content -Path "$rootPath\$($ConfigPath.Backup_Script)"

# Replace the BACKUP_PATH line with the new archive path
$modifiedContent = $scriptContent -replace 'BACKUP_PATH=".*"', "BACKUP_PATH=""$archivePath""" -replace 'DESTINATION_PATH="/mnt/pve/NFS/template/cache/[^"]*"', "DESTINATION_PATH='/mnt/pve/NFS/template/cache/$ConfigFile-current.tar.gz'"
$temppath = $ConfigPath.Backup_Script -replace "scripts", "temp"

$logfile = [System.IO.Path]::GetFileNameWithoutExtension($temppath)
# Create a new temporary file to hold the modified content
$tempFilePath = "$rootPath\$temppath"

# Set the content of the new temporary file
Set-Content -Path $tempFilePath -Value $modifiedContent
Write-Log "Created a new temporary file with the modified content: $tempFilePath"


try {
    # Run the SSH command to configure the container
    Write-Log "Moving Backup"
    $temppath
    $containerConfig = & "$rootPath\task\Run-SSHCommand.ps1" -remoteHost "$($ConfigPath.Proxmox_SSH_User)@$FQDNorIP" -scriptFile $temppath

    # Check if the script completed successfully
    $logFilePathMove = "$rootPath\logs\$logfile.log"
    if (Test-Path -Path $logFilePathMove) {
        $logContent = Get-Content -Path $logFilePathMove

        if ($logContent -contains "File moved successfully to /mnt/pve/NFS/template/cache/$ConfigFile-current.tar.gz") {
            Write-Log "File moved successfully" | Tee-Object -FilePath $logFilePathMove -Append
            $deleteupid = & "$rootPath\task\Delete-LXC.ps1" -node $ConfigPath.node -vmid $ConfigPath.vmid -FQDNorIP $FQDNorIP -purge -destroyUnreferencedDisks
            $DeleteStatus = Wait-ForTaskCompletion -FQDNorIP $FQDNorIP -upid $deleteupid.data

            if ($DeleteStatus -eq $true) {
                Write-Log "Cleanup"
                Remove-Item $tempFilePath, $logFilePathMove
                Write-Log "Complete"
            }
        } else {
            Write-Log "File move failed." | Tee-Object -FilePath $logFilePathMove -Append
            exit 1
        }
    } else {
        Write-Log "Log file not found: $logFilePathMove" -isError
        exit 1
    }
} catch {
    Write-Log "An error occurred: $_" -isError
    exit 1
}
