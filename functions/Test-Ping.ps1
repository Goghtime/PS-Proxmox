# Function to ping the IP address
function Test-Ping {
    param (
        [string]$ip,
        [int]$maxAttempts = 10
    )
    $attempts = 0
    $pingSuccess = $false

    while (-not $pingSuccess -and $attempts -lt $maxAttempts) {
        try {
            $pingResult = Test-Connection -ComputerName $ip -Count 1 -ErrorAction Stop
            $attempts++
            if ($pingResult.Status -eq "Success") {
                $pingSuccess = $true
                Write-Host "Ping to $ip successful."
            } else {
                Write-Host "Ping attempt $attempts to $ip failed. Retrying..."
                Start-Sleep -Seconds 1
            }
        } catch {
            Write-Host "Ping attempt $attempts to $ip failed with error: $_. Retrying..."
            Start-Sleep -Seconds 1
            $attempts++
        }
    }

    return $pingSuccess
}