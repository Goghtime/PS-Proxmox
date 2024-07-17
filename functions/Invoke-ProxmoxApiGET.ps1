function Invoke-ProxmoxApiGET {
    param (
        [string]$FQDNorIP,
        [string]$Port = "8006",
        [string]$Endpoint = "version",
        $Username = "root@pam",
        $Token_Name,
        $API_Token

    )

    # Define the variables
    $apiUrl = "https://$FQDNorIP`:$port/api2/json/$Endpoint"

    $apiToken = $Username + "!" + $Token_Name + "=" + $API_Token

    # Create the headers
    $headers = @{
        "Authorization" = "PVEAPIToken=$apiToken"
    }

    # Bypass SSL certificate validation
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

    # Send the request using Invoke-RestMethod
    try {
        Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get -SkipCertificateCheck -SkipHeaderValidation
        #$response | ConvertTo-Json -Depth 10
    } catch {
        Write-Error "Failed to authenticate with API token. Error: $_"
        Write-Output "Error Details: $($_.Exception | Format-List -Force | Out-String)"
    }
}
