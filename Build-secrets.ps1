param (
    [bool]$update = $false
)

# Define the path to the secrets.json file
$secretsPath = ".\configs\secrets.json"

# Check if the file exists and $update is set to true
if ((Test-Path -Path $secretsPath) -and $update) {
    # Load existing values
    $secrets = Get-Content -Path $secretsPath | ConvertFrom-Json

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

# Create a hashtable with the values
$secrets = @{
    Username = $Username
    Token_Name = $TokenName
    API_Token = $APIToken
}

# Convert the hashtable to a JSON string (pretty-printed)
$secretsJson = $secrets | ConvertTo-Json

# Write the JSON string to the secrets.json file
Set-Content -Path $secretsPath -Value $secretsJson

Write-Host "Secrets saved to $secretsPath"
