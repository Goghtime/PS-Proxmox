param(
    [Parameter(Mandatory=$true)]
    [string]$node,

    [Parameter(Mandatory=$true)]
    [int]$vmid,

    [Parameter(Mandatory=$true)]
    [string]$FQDNorIP
)

# Find Root Path
$rootPath = Split-Path -Path $PSScriptRoot -Parent

# Import Function -force is required to run multiple times in a row.
Import-Module "$rootPath\functions\Invoke-ProxmoxApiGET.ps1" -Force -DisableNameChecking

# Load the configuration file
$secrets = Get-Content -Path "$rootPath\env\secrets.json" | ConvertFrom-Json

$Endpoint = "nodes/$node/lxc/$vmid/status/current"

# Invoke the function with the hashtable directly
try {
    Invoke-ProxmoxApiGET -Endpoint $Endpoint -Token_Name $secrets.Token_Name -API_Token $secrets.API_Token -FQDNorIP $FQDNorIP
} catch {
    Write-Host "An error occurred while retrieving the LXC container status for node '$node' and VMID '$vmid' on '$FQDNorIP'."
    Write-Host "Error Details: $_"
    if ($_.Exception.Response -ne $null -and $_.Exception.Response.Content -ne $null) {
        try {
            $responseContent = $_.Exception.Response.Content.ReadAsStringAsync().Result
            Write-Host "Response Content: $responseContent"
        } catch {
            Write-Host "Unable to read response content"
        }
    }
}
