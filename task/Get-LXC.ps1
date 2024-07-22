param(
    [Parameter(Mandatory=$true)]
    [string]$FQDNorIP
)
# Find Root Path
$rootPath = Split-Path -Path $PSScriptRoot -Parent

# Import Function -force is required to run multiple times in a row.
Import-Module "$rootPath\functions\Invoke-ProxmoxApiGET.ps1" -Force -DisableNameChecking


# Load required env configs
$env = Get-Content -Path "$rootPath\env\nodes.json" | ConvertFrom-Json
$secrets = Get-Content -Path "$rootPath\env\secrets.json" | ConvertFrom-Json

# Initialize an array to store the aggregated data
$aggregatedData = @()

# Extract and iterate over ServerNames
foreach ($node in $env.Nodes) {
    $serverName = $node.ServerName
    $ipAddress = $node.IP

    # Invoke the API to get LXC container data for the node
    $data = Invoke-ProxmoxApiGET -Endpoint "nodes/$serverName/lxc" -Token_Name $secrets.Token_Name -API_Token $secrets.API_Token -FQDNorIP $FQDNorIP

    # Check if data is retrieved
    if ($data) {
        # Add ServerName to each data item and aggregate the results
        foreach ($item in $data.data) {
            # Ensure $item is a PSCustomObject
            $item = [PSCustomObject]$item
            $item | Add-Member -MemberType NoteProperty -Name "ServerName" -Value $serverName
            $aggregatedData += $item
        }
    }
}

# Output the aggregated data
$aggregatedData
