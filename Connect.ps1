param(
    [ValidateSet("192.168.100.81","192.168.100.84","192.168.100.85")]
    [string]$node
)

$secrets = Get-Content -Path "$PSScriptRoot\configs\secrets.json" | ConvertFrom-Json

$login = $secrets.Username + "!" + $secrets.Token_Name + "=" + $secrets.API_Token

Connect-PveCluster -HostsAndPorts $node -SkipCertificateCheck -ApiToken $login








