param(
    [Parameter(Mandatory=$true)]
    [string]$node,

    [Parameter(Mandatory=$true)]
    [int]$vmid,

    [Parameter(Mandatory=$true)]
    [string]$FQDNorIP,

    [Parameter(Mandatory=$true)]
    [hashtable]$body

)

# Find Root Path
$rootPath = Split-Path -Path $PSScriptRoot -Parent

# Import Function -force is required to run multiple times in a row.
Import-Module "$rootPath\functions\Invoke-ProxmoxApiPUT.ps1" -Force -DisableNameChecking


# Load the configuration file
$secrets = Get-Content -Path "$rootPath\env\secrets.json" | ConvertFrom-Json

# Define the body parameters as a hashtable

# Convert the body to JSON

$Endpoint = "nodes/$node/lxc/$vmid/config"

# Invoke the function with the hashtable directly
try {
    Invoke-ProxmoxApiPUT -Endpoint $Endpoint -Body $body -Token_Name $secrets.Token_Name -API_Token $secrets.API_Token -FQDNorIP $FQDNorIP
} catch {
    Write-Error "An error occurred while creating the LXC container: $_"
}
