# Required Module to work with Proxmox API via PS
# Project : https://github.com/Corsinvest/cv4pve-api-powershell
Install-Module -Name Corsinvest.ProxmoxVE.Api

# Copy env template
Copy-Item -Path "$PSScriptRoot\env.template.json" -Destination "$PSScriptRoot\env.json"

# Generate API Key
