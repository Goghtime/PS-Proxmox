param(
    [Parameter(Mandatory=$true)]
    [string]$FQDNorIP,
    [Parameter(Mandatory=$true)]
    [string]$node,
    [Parameter(Mandatory=$true)]
    [string]$vmid

)
# Find Root Path
$rootPath = Split-Path -Path $PSScriptRoot -Parent

# Import Function -force is required to run multiple times in a row.
Import-Module "$rootPath\functions\Invoke-ProxmoxApiGET.ps1" -Force -DisableNameChecking


$secrets = Get-Content -Path "$rootPath\env\secrets.json" | ConvertFrom-Json

$Endpoint = "nodes/$node/lxc/$vmid/config"

Invoke-ProxmoxApiGET -Endpoint $Endpoint -Token_Name $secrets.Token_Name -API_Token $secrets.API_Token -FQDNorIP $FQDNorIP
