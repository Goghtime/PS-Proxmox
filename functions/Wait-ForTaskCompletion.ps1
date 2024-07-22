function Wait-ForTaskCompletion {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FQDNorIP,

        [Parameter(Mandatory=$true)]
        [string]$upid,

        [Parameter(Mandatory=$false)]
        [int]$timeoutMinutes = 10,  # Default timeout is 10 minutes

        [Parameter(Mandatory=$false)]
        [int]$sleepIntervalSeconds = 5  # Default sleep interval is 5 seconds
    )
    $rootPath = Split-Path -Path $PSScriptRoot -Parent

    # Initialize the stopwatch
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    $status = $null
    $filteredData = $null

    do {
        Start-Sleep -Seconds $sleepIntervalSeconds

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
            return $false
        }

        if ($status -and $status -ne "OK") {
            Write-Error "Task failed with status: $status"
            return $false
        }
    } while (-not $status -or $status -ne "OK")

    # Stop the stopwatch
    $stopwatch.Stop()

    # Return success if status is OK
    if ($status -eq "OK") {
        return $true
    } else {
        return $false
    }
}
