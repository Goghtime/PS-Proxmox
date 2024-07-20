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
    $apiUrl = "https://$FQDNorIP`:$Port/api2/json/$Endpoint"

    $apiToken = $Username + "!" + $Token_Name + "=" + $API_Token

    # Create the headers
    $headers = @{
        "Authorization" = "PVEAPIToken=$apiToken"
    }

    # Bypass SSL certificate validation
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

    # Send the request using Invoke-RestMethod
    try {
        return Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get -SkipCertificateCheck -SkipHeaderValidation
    } catch {
        $exception = $_.Exception
        $responseContent = ""
        if ($exception.Response -ne $null -and $exception.Response.Content -ne $null) {
            try {
                $responseContent = $exception.Response.Content.ReadAsStringAsync().Result
            } catch {
                $responseContent = "Unable to read response content"
            }
        }
        return [pscustomobject]@{
            StatusCode = $exception.Response.StatusCode
            ReasonPhrase = $exception.Response.ReasonPhrase
            ResponseContent = $responseContent
            ErrorDetails = $exception | Format-List -Force | Out-String
        }
    }
}
