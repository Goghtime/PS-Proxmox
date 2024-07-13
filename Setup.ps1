
Write-Host "PS-Proxmox Setup"

$moduleName = 'Corsinvest.ProxmoxVE.Api'
$jsonPath = "$PSScriptRoot\configs\env.json"



# Required Module to work with Proxmox API via PS
# Project : https://github.com/Corsinvest/cv4pve-api-powershell

if (-not (Get-Module -ListAvailable -Name $moduleName)) {
    Install-Module -Name $moduleName -Verbose
    
} else {
    Write-Host "$moduleName is already installed"
}
