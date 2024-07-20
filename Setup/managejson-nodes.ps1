# Path to the JSON file
$rootPath = Split-Path -Path $PSScriptRoot -Parent
$jsonFilePath = "$rootPath\env\nodes.json"

# Function to load the JSON file
function Load-Json {
    param (
        [string]$filePath
    )
    if (Test-Path -Path $filePath) {
        $jsonContent = Get-Content -Path $filePath -Raw | ConvertFrom-Json
    } else {
        $jsonContent = @{ Nodes = @() } | ConvertTo-Json | ConvertFrom-Json
    }
    return $jsonContent
}

# Function to save the JSON file
function Save-Json {
    param (
        [string]$filePath,
        [PSCustomObject]$jsonContent
    )
    $jsonContent | ConvertTo-Json -Depth 10 | Set-Content -Path $filePath
}

# Function to add a node
function Add-Node {
    param (
        [string]$fqdn,
        [string]$ip,
        [string]$serverName
    )
    $jsonContent = Load-Json -filePath $jsonFilePath
    $newNode = [PSCustomObject]@{
        FQDN       = $fqdn
        IP         = $ip
        ServerName = $serverName
    }
    $jsonContent.Nodes += $newNode
    Save-Json -filePath $jsonFilePath -jsonContent $jsonContent
    Write-Host "Node added: $serverName"
}

# Function to remove a node by ServerName
function Remove-Node {
    param (
        [string]$serverName
    )
    $jsonContent = Load-Json -filePath $jsonFilePath
    $jsonContent.Nodes = $jsonContent.Nodes | Where-Object { $_.ServerName -ne $serverName }
    Save-Json -filePath $jsonFilePath -jsonContent $jsonContent
    Write-Host "Node removed: $serverName"
}

# Function to view all nodes
function View-Nodes {
    $jsonContent = Load-Json -filePath $jsonFilePath
    $jsonContent.Nodes | ForEach-Object {
        Write-Host "FQDN: $($_.FQDN), IP: $($_.IP), ServerName: $($_.ServerName)"
    }
}

# Main menu
function Show-Menu {
    Clear-Host
    Write-Host "Proxmox Setup"
    Write-Host "1. Add a node"
    Write-Host "2. Remove a node"
    Write-Host "3. View all nodes"
    Write-Host "4. Exit"
}

# Main script loop
do {
    Show-Menu
    $choice = Read-Host "Enter your choice (1-4)"
    switch ($choice) {
        1 {
            $fqdn = Read-Host "Enter FQDN"
            $ip = Read-Host "Enter IP"
            $serverName = Read-Host "Enter Server Name"
            Add-Node -fqdn $fqdn -ip $ip -serverName $serverName
        }
        2 {
            $serverName = Read-Host "Enter Server Name to remove"
            Remove-Node -serverName $serverName
        }
        3 {
            View-Nodes
        }
        4 {
            Write-Host "Exiting..."
        }
        default {
            Write-Host "Invalid choice, please try again."
        }
    }
    if ($choice -ne 4) {
        Write-Host "Press any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
} while ($choice -ne 4)
