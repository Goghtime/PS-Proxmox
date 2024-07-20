Write-Host "PS-Proxmox Setup"

$rootPath = Split-Path -Path $PSScriptRoot -Parent
$folderPath = "$rootPath/env"

if (-Not (Test-Path -Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath
    Write-Host "Folder created: $folderPath"
} else {
    Write-Host "Folder already exists: $folderPath"
}

& "$rootPath\setup\managejson-secrets.ps1"

& "$rootPath\setup\managejson-nodes.ps1"