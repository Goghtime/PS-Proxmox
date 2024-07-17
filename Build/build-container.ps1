param(
    [Parameter(Mandatory=$true)]
    [string]$ConfigFile
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
    ostemplate = $BuildConfig.ostemplate
    vmid = [int]$BuildConfig.vmid
    hostname = $ConfigFile
    node = $BuildConfig.node
    storage = $BuildConfig.storage
    features = $BuildConfig.features
    unprivileged = [bool]$BuildConfig.unprivileged 
    arch = $BuildConfig.arch
    ostype = $BuildConfig.ostype
    cores = [int]$BuildConfig.cores
    memory = [int]$BuildConfig.memory
    swap = [int]$BuildConfig.swap
    nameserver = $BuildConfig.nameserver
    searchdomain = $BuildConfig.searchdomain
    net0 = $BuildConfig.net0
    'ssh-public-keys' = $BuildConfig.sshpub
    rootfs = $BuildConfig.rootfs
}


$Endpoint = "nodes/$($BuildConfig.node)/lxc"

# Invoke the function with the hashtable directly
try {
    Invoke-ProxmoxApiPOST -Endpoint $Endpoint -Body $body -Token_Name $secrets.Token_Name -API_Token $secrets.API_Token
} catch {
    Write-Error "An error occurred while creating the LXC container: $_"
}
