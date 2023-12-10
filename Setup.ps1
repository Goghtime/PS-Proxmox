
Write-Host "PS-Proxmox Setup"

$moduleName = 'Corsinvest.ProxmoxVE.Api'
$sourcePath = "$PSScriptRoot\env.template.json"
$jsonPath = "$PSScriptRoot\env.json"



# Required Module to work with Proxmox API via PS
# Project : https://github.com/Corsinvest/cv4pve-api-powershell

if (-not (Get-Module -ListAvailable -Name $moduleName)) {
    Install-Module -Name $moduleName -Verbose
    
} else {
    Write-Host "$moduleName is already installed"
}

# Update Connect.ps1 with relevant Node information.

# Copy the env.template.json to env.json if it doesn't already exist
if (-not (Test-Path -Path $jsonPath)) {
    Copy-Item -Path $sourcePath -Destination $jsonPath -Verbose
} else {
    Write-Host "$jsonPath Already exists"
}

# Read and parse the JSON file
$jsonContent = Get-Content -Path $jsonPath | ConvertFrom-Json
$jsonValues = $jsonContent.Nodes.PSObject.Properties.Value.IP

# Construct the new ValidateSet string
$validateSetString = '[ValidateSet("' + ($jsonValues -join '","') + '")]'

# Read the Connect.ps1 script content
$scriptContent = Get-Content -Path $connectScriptPath -Raw

# Regex to find the existing ValidateSet attribute
$validateSetPattern = '\[ValidateSet\((.*)\)\]'
$hasValidateSet = $scriptContent -match $validateSetPattern

# Update the ValidateSet in the script
if ($hasValidateSet) {
    $updatedScriptContent = $scriptContent -replace $validateSetPattern, $validateSetString
} else {
    # If no ValidateSet exists, prepend the new ValidateSet to the script
    $updatedScriptContent = $validateSetString + "`n" + $scriptContent
}

# Write the updated content back to Connect.ps1
Set-Content -Path $connectScriptPath -Value $updatedScriptContent -Verbose

