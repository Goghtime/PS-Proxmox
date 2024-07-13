param (
    [bool]$update = $false
)

# Define the path to the env.json file
$envPath = ".\configs\env.json"

# Function to prompt for node details
function Prompt-NodeDetails {
    param (
        [string]$nodeName,
        [hashtable]$existingValues
    )

    $ServerName = Read-Host -Prompt "Enter ServerName for $nodeName (current: $($existingValues.ServerName))"
    if ($ServerName -eq '') { $ServerName = $existingValues.ServerName }

    $FQDN = Read-Host -Prompt "Enter FQDN for $nodeName (current: $($existingValues.FQDN))"
    if ($FQDN -eq '') { $FQDN = $existingValues.FQDN }

    $IP = Read-Host -Prompt "Enter IP for $nodeName (current: $($existingValues.IP))"
    if ($IP -eq '') { $IP = $existingValues.IP }

    return @{
        ServerName = $ServerName
        FQDN = $FQDN
        IP = $IP
    }
}

# Initialize an empty hashtable for nodes
$nodes = @{}

# Check if the file exists and $update is set to true
if ((Test-Path -Path $envPath) -and $update) {
    # Load existing values
    $env = Get-Content -Path $envPath | ConvertFrom-Json
    $nodes = $env.Nodes

    # Prompt the user for new values for each existing node, defaulting to existing values if nothing is entered
    foreach ($node in $nodes.Keys) {
        $nodes[$node] = Prompt-NodeDetails -nodeName $node -existingValues $nodes[$node]
    }

    # Ask if the user wants to add more nodes
    do {
        $addMore = Read-Host "Do you want to add another node? (yes/no)"
        if ($addMore -eq 'yes') {
            $nodeName = Read-Host "Enter the new node name"
            $nodes[$nodeName] = Prompt-NodeDetails -nodeName $nodeName -existingValues @{ServerName=''; FQDN=''; IP=''}
        }
    } while ($addMore -eq 'yes')
} else {
    # Prompt the user for the values for the first node
    $nodeName = Read-Host "Enter the first node name"
    $nodes[$nodeName] = Prompt-NodeDetails -nodeName $nodeName -existingValues @{ServerName=''; FQDN=''; IP=''}

    # Ask if the user wants to add more nodes
    do {
        $addMore = Read-Host "Do you want to add another node? (yes/no)"
        if ($addMore -eq 'yes') {
            $nodeName = Read-Host "Enter the new node name"
            $nodes[$nodeName] = Prompt-NodeDetails -nodeName $nodeName -existingValues @{ServerName=''; FQDN=''; IP=''}
        }
    } while ($addMore -eq 'yes')
}

# Create the final hashtable
$env = @{
    Nodes = $nodes
}

# Convert the hashtable to a JSON string (pretty-printed)
$envJson = $env | ConvertTo-Json -Depth 4

# Write the JSON string to the env.json file
Set-Content -Path $envPath -Value $envJson

Write-Host "Environment configuration saved to $envPath"
