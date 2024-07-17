param(
    [Parameter(Mandatory=$true)]
    [string]$node,

    [Parameter(Mandatory=$true)]
    [int]$vmid,

    [Parameter(Mandatory=$true)]
    [ValidateSet("start", "stop", "reboot", "shutdown", "stop", "suspend", "resume")]
    [string]$action
)

# Find Root Path
$rootPath = Split-Path -Path $PSScriptRoot -Parent

# Import Function -force is required to run multiple times in a row.
Import-Module "$rootPath\functions\Invoke-ProxmoxApiPOST.ps1" -Force -DisableNameChecking

# Load the configuration file
$secrets = Get-Content -Path "$rootPath\env\secrets.json" | ConvertFrom-Json

# Define the body parameters as a hashtable
$body = @{

}


$Endpoint = "nodes/$node/lxc/$vmid/status/$action"

# Invoke the function with the hashtable directly
try {
    Invoke-ProxmoxApiPOST -Endpoint $Endpoint -Body $body -Token_Name $secrets.Token_Name -API_Token $secrets.API_Token
} catch {
    Write-Error "An error occurred while creating the LXC container: $_"
}
