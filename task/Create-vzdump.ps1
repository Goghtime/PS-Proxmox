param(
    [Parameter(Mandatory=$true)]
    [string]$FQDNorIP,
    [Parameter(Mandatory=$true)]
    [string]$node,
    [Parameter(Mandatory=$true)]
    [string]$vmid,
    [Parameter(Mandatory=$true)]
    [string]$ConfigFile

)

$rootPath = Split-Path -Path $PSScriptRoot -Parent

# Import Function -force is required to run multiple times in a row.
Import-Module "$rootPath\functions\Invoke-ProxmoxApiPOST.ps1" -Force -DisableNameChecking
Import-Module "$rootPath\functions\Wait-ForTaskCompletion.ps1" -Force -DisableNameChecking
$secrets = Get-Content -Path "$rootPath\env\secrets.json" | ConvertFrom-Json
$ConfigPath = Get-Content -Path "$rootPath\configs\$ConfigFile.json" | ConvertFrom-Json

# Define the body for the vzdump command
$body = @{
    vmid = $vmid
    mode = $ConfigPath.BackupMode  
    storage = $ConfigPath.storage 
    compress = $ConfigPath.compress
    remove = 0         # Don't remove the backup after completion
}
# Endpoint for vzdump
$Endpoint = "nodes/$($ConfigPath.node)/vzdump"

# Invoke the function to take the backup
Invoke-ProxmoxApiPOST -Endpoint $Endpoint -Body $body -Token_Name $secrets.Token_Name -API_Token $secrets.API_Token -FQDNorIP $FQDNorIP


