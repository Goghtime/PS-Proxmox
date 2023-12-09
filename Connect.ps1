#$env = Get-Content -Path "C:\Projects\PS-Proxmox\env.json" | ConvertFrom-Json
$env = Get-Content -Path "$PSScriptRoot\env.json" | ConvertFrom-Json

$secrets = Get-Content -Path "C:\Projects\PS-Proxmox\secrets.json" | ConvertFrom-Json
$secrets = Get-Content -Path "$PSScriptRoot\secrets.json" | ConvertFrom-Json

$login = $secrets.Username + "!" + $secrets.Token_Name + "=" + $secrets.API_Token


Connect-PveCluster -HostsAndPorts $env.Nodes.pve01.IP,$env.Nodes.pve02.IP,$env.Nodes.pve03.IP -SkipCertificateCheck -ApiToken $login

