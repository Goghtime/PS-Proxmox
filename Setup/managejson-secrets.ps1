$rootPath = Split-Path -Path $PSScriptRoot -Parent
# Path to the secrets.json file
$secretsPath = "$rootPath\env\secrets.json"

# Function to load the JSON file
function Load-Secrets {
    param (
        [string]$filePath
    )
    if (Test-Path -Path $filePath) {
        $jsonContent = Get-Content -Path $filePath -Raw | ConvertFrom-Json
    } else {
        $jsonContent = @{ Username = ""; Token_Name = ""; API_Token = "" } | ConvertTo-Json | ConvertFrom-Json
    }
    return $jsonContent
}

# Function to save the JSON file
function Save-Secrets {
    param (
        [string]$filePath,
        [PSCustomObject]$jsonContent
    )
    $jsonContent | ConvertTo-Json -Depth 10 | Set-Content -Path $filePath
}

# Function to add or update secrets
function AddOrUpdate-Secrets {
    param (
        [bool]$update = $false
    )
    $secrets = Load-Secrets -filePath $secretsPath

    if ($update) {
        # Prompt the user for new values, defaulting to existing values if nothing is entered
        $Username = Read-Host -Prompt "Enter your Username (current: $($secrets.Username))"
        if ($Username -eq '') { $Username = $secrets.Username }

        $TokenName = Read-Host -Prompt "Enter your Token Name (current: $($secrets.Token_Name))"
        if ($TokenName -eq '') { $TokenName = $secrets.Token_Name }

        $APIToken = Read-Host -Prompt "Enter your API Token (current: $($secrets.API_Token))"
        if ($APIToken -eq '') { $APIToken = $secrets.API_Token }
    } else {
        # Prompt the user for the values
        $Username = Read-Host -Prompt "Enter your Username"
        $TokenName = Read-Host -Prompt "Enter your Token Name"
        $APIToken = Read-Host -Prompt "Enter your API Token"
    }

    # Update the secrets object
    $secrets.Username = $Username
    $secrets.Token_Name = $TokenName
    $secrets.API_Token = $APIToken

    Save-Secrets -filePath $secretsPath -jsonContent $secrets
    Write-Host "Secrets saved to $secretsPath"
}

# Function to view the secrets
function View-Secrets {
    $secrets = Load-Secrets -filePath $secretsPath
    Write-Host "Username: $($secrets.Username)"
    Write-Host "Token Name: $($secrets.Token_Name)"
    Write-Host "API Token: $($secrets.API_Token)"
}

# Main menu
function Show-Menu {
    Clear-Host
    Write-Host "Secrets Management"
    Write-Host "1. Add or Update Secrets"
    Write-Host "2. View Secrets"
    Write-Host "3. Exit"
}

# Main script loop
do {
    Show-Menu
    $choice = Read-Host "Enter your choice (1-3)"
    switch ($choice) {
        1 {
            $update = $false
            if (Test-Path -Path $secretsPath) {
                $updateChoice = Read-Host "Do you want to update existing secrets? (y/n)"
                if ($updateChoice -eq 'y') { $update = $true }
            }
            AddOrUpdate-Secrets -update $update
        }
        2 {
            View-Secrets
        }
        3 {
            Write-Host "Exiting..."
        }
        default {
            Write-Host "Invalid choice, please try again."
        }
    }
    if ($choice -ne 3) {
        Write-Host "Press any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
} while ($choice -ne 3)
