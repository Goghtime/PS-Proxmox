Write-Host "PS-Proxmox Setup"

$moduleName = 'Corsinvest.ProxmoxVE.Api'

# Required Module to work with Proxmox API via PS
# Project : https://github.com/Corsinvest/cv4pve-api-powershell

if (-not (Get-Module -ListAvailable -Name $moduleName)) {
    Install-Module -Name $moduleName -Verbose -Force
} else {
    Write-Host "$moduleName is already installed"
}

# Env Setup

if (-not (Test-Path "./config/env.json")) {
    # Your code here will run only if ./config/env.json does not exist
    Write-Output "The file ./config/env.json does not exist."
    . ./Setup/Build-env.ps1
} else {
    Write-Output "The file ./config/env.json already exists."
}

# Secrets Setup

if (-not (Test-Path "./config/secrets.json")) {
    # Your code here will run only if ./config/secrets.json does not exist
    Write-Output "The file ./config/secrets.json does not exist."
    . ./Setup/Build-secrets.ps1
} else {
    Write-Output "The file ./config/secrets.json already exists."
}
