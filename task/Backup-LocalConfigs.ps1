param (
    [string]$backupsDir
)

$rootPath = Split-Path -Path $PSScriptRoot -Parent

# Define the directories to be copied
$directories = @("configs", "env", "scripts")

# Define the output zip file with a timestamp
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$zipFilePath = "$backupsDir\backup_$timestamp.zip"

# Create the backups directory if it doesn't exist
if (-Not (Test-Path -Path $backupsDir)) {
    New-Item -ItemType Directory -Path $backupsDir
}

# Initialize the zip file
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zipArchive = [System.IO.Compression.ZipFile]::Open($zipFilePath, [System.IO.Compression.ZipArchiveMode]::Create)

# Add directories to the zip file
foreach ($directory in $directories) {
    $fullPath = Join-Path $rootPath $directory
    if (Test-Path -Path $fullPath) {
        $files = Get-ChildItem -Path $fullPath -Recurse -File
        foreach ($file in $files) {
            $relativePath = $file.FullName.Substring($rootPath.Length + 1)
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipArchive, $file.FullName, $relativePath)
        }
    } else {
        Write-Host "Directory not found: $fullPath"
    }
}

# Close the zip file
$zipArchive.Dispose()

Write-Host "Backup completed successfully. The zip file is saved at $zipFilePath."
