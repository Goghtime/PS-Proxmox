
 param(
    $remoteHost,
    $scriptFile
)  

# Extract the portion of the string between the last backslash and .sh
$fileName = [System.IO.Path]::GetFileNameWithoutExtension($scriptFile)
$parsedValue = $fileName -replace '^.*\\'
$parsedValue

$rootPath = Split-Path -Path $PSScriptRoot -Parent
# Define the script file path
$scriptFilePath = "$rootPath\$scriptFile"

# Read the content of the script file
$scriptContent = Get-Content -Path $scriptFilePath -Raw

# Escape the script content to be safely included in a single SSH command
$escapedScriptContent = $scriptContent -replace "`r`n", "`n"

# Prepare the SSH command
$sshCommand = @"
$escapedScriptContent
"@

# Define the path to the log files
$logFileStdOut = "$rootPath\logs\$parsedValue`_stdout.log"
$logFileStdErr = "$rootPath\logs\$parsedValue`_stderr.log"
$combinedLogFile = "$rootPath\logs\$parsedValue.log"

# Execute the script via SSH and capture the output
$process = Start-Process ssh -ArgumentList "$remoteHost $sshCommand" -NoNewWindow -PassThru -RedirectStandardOutput $logFileStdOut -RedirectStandardError $logFileStdErr -Wait

# Combine standard output and error into a single log file
Get-Content $logFileStdOut, $logFileStdErr | Set-Content -Path $combinedLogFile
Remove-Item $logFileStdOut, $logFileStdErr

# Check the exit code of the SSH process
if ($process.ExitCode -eq 0) {
    Write-Output "Remote setup completed successfully." | Tee-Object -FilePath $combinedLogFile -Append
} else {
    Write-Output "Remote setup failed." | Tee-Object -FilePath $combinedLogFile -Append
}

# Display log file content
Get-Content -Path $combinedLogFile
