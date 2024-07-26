param(
    [Parameter(Mandatory=$true)]
    [string]$ConfigFile,
    $FQDNorIP,
    $node
)

# Find Root Path
$rootPath = Split-Path -Path $PSScriptRoot -Parent

# Import Function -force is required to run multiple times in a row.
Import-Module "$rootPath\functions\Invoke-ProxmoxApiPOST.ps1" -Force -DisableNameChecking

# Load the configuration file
$BuildConfig = Get-Content -Path "$rootPath\configs\$ConfigFile.json" | ConvertFrom-Json
$secrets = Get-Content -Path "$rootPath\env\secrets.json" | ConvertFrom-Json

# Define the body parameters as a hashtable
$body = @{
    newid      = [int]$BuildConfig.newid
    node       = $node #This represents what node the clone/template is on.
    vmid       = [int]$BuildConfig.vmid
    full       = $BuildConfig.full
    format     = $BuildConfig.format
    name       = $ConfigFile
    storage    = $BuildConfig.storage
    description= $BuildConfig.description
    #bwlimit    = $BuildConfig.bwlimit
    #pool       = $BuildConfig.pool
    #snapname   = $BuildConfig.snapname
    target     = $BuildConfig.node # This is the node you want to build the newid on.
}


$Endpoint = "nodes/$node/qemu/$($BuildConfig.vmid)/clone"

# Invoke the function with the hashtable directly
try {
    Invoke-ProxmoxApiPOST -Endpoint $Endpoint -Body $body -Token_Name $secrets.Token_Name -API_Token $secrets.API_Token -FQDNorIP $FQDNorIP
} catch {
    Write-Error "An error occurred while creating the qemu clone: $_"
}
