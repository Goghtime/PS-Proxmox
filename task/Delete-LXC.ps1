param(
    [Parameter(Mandatory=$true)]
    [string]$node,

    [Parameter(Mandatory=$true)]
    [int]$vmid,

    [Parameter(Mandatory=$true)]
    [string]$FQDNorIP,

    [Parameter(Mandatory=$false)]
    [switch]$purge,

    [Parameter(Mandatory=$false)]
    [switch]$destroyUnreferencedDisks
)

# Find Root Path
$rootPath = Split-Path -Path $PSScriptRoot -Parent

# Import Function -force is required to run multiple times in a row.
Import-Module "$rootPath\functions\Invoke-ProxmoxApiDELETE.ps1" -Force -DisableNameChecking

# Load the configuration file
$secrets = Get-Content -Path "$rootPath\env\secrets.json" | ConvertFrom-Json

# Build the endpoint URL with optional parameters
$Endpoint = "nodes/$node/lxc/$vmid"

# Add query parameters
$queryParams = @()
if ($purge) {
    $queryParams += "purge=1"
}
if ($destroyUnreferencedDisks) {
    $queryParams += "destroy-unreferenced-disks=1"
}

# Combine the query parameters with the endpoint URL
if ($queryParams.Count -gt 0) {
    $Endpoint += "?" + ($queryParams -join "&")
}

Write-Host "Final Endpoint URL: $Endpoint"

# Invoke the function with the hashtable directly
try {
    Invoke-ProxmoxApiDELETE -Endpoint $Endpoint -Token_Name $secrets.Token_Name -API_Token $secrets.API_Token -FQDNorIP $FQDNorIP
} catch {
    Write-Error "An error occurred while deleting the LXC container: $_"
}
