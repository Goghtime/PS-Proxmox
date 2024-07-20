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
    $apiUrl = "https://192.168.100.81:8006/api2/json/nodes/pve05/tasks/UPID:pve05:0001193C:00178135:669ABC94:vzdump:5000:root@pam!gogh:/log"

    $apiToken = "root@pam" + "!" + "gogh" + "=" + "7480d09c-09da-490f-bf89-85ddb42b34da"

    # Create the headers
    $headers = @{
        "Authorization" = "PVEAPIToken=$apiToken"
    }

    # Bypass SSL certificate validation
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

    # Send the request using Invoke-RestMethod
$data = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get -SkipCertificateCheck -SkipHeaderValidation
    

# Assuming $data.data contains the array of tasks
$filteredData = $data.data | Where-Object { $_.upid -eq "UPID:pve05:000191A4:00280616:66999775:vzdestroy:5000:root@pam!gogh:" }

# Print the filtered data
$filteredData
