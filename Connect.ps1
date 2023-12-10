param(
    [ValidateSet("192.168.100.80","192.168.100.81","192.168.100.82")]
    [string]$node
)

$secrets = Get-Content -Path "$PSScriptRoot\secrets.json" | ConvertFrom-Json

$login = $secrets.Username + "!" + $secrets.Token_Name + "=" + $secrets.API_Token

Connect-PveCluster -HostsAndPorts $node -SkipCertificateCheck -ApiToken $login








