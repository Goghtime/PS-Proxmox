param(
    [Parameter(Mandatory=$true)]
    [string]$FQDNorIP,
    [Parameter(Mandatory=$true)]
    [string]$node,
    [Parameter(Mandatory=$true)]
    [string]$vmid

)

$rootPath = Split-Path -Path $PSScriptRoot -Parent

# Import Function -force is required to run multiple times in a row.
Import-Module "$rootPath\functions\Invoke-ProxmoxApiPOST.ps1" -Force -DisableNameChecking
$secrets = Get-Content -Path "$rootPath\PS-Proxmox\env\secrets.json" | ConvertFrom-Json
$ConfigPath = Get-Content -Path "$rootPath\PS-Proxmox\configs\$ConfigFile.json" | ConvertFrom-Json

# Define the body for the vzdump command
$body = @{
    vmid = $vmid
    mode = $configpath.BackupMode  
    storage = $configpath.storage 
    compress = $configpath.compress
    remove = 0         # Don't remove the backup after completion
}

# Endpoint for vzdump
$Endpoint = "nodes/$($configpath.node)/vzdump"

# Invoke the function to take the backup
Invoke-ProxmoxApiPOST -Endpoint $Endpoint -Body $body -Token_Name $secrets.Token_Name -API_Token $secrets.API_Token -FQDNorIP $FQDNorIP


