# Set the source and destination directories
param (
    $sourceDir,
    $destDir 
)

# Get the latest zip file based on the date in the filename
$latestZip = Get-ChildItem -Path $sourceDir -Filter "*.zip" |
    Sort-Object -Property { 
        $match = [regex]::Match($_.Name, '\d{8}_\d{6}').Value
        [DateTime]::ParseExact($match, 'yyyyMMdd_HHmmss', $null)
    } -Descending |
    Select-Object -First 1

# Check if a zip file was found
if ($latestZip) {
    # Extract the zip file to the destination directory
    Expand-Archive -Path $latestZip.FullName -DestinationPath $destDir -Force
    Write-Host "Extracted $($latestZip.Name) to $destDir"
} else {
    Write-Host "No zip files found in $sourceDir"
}
