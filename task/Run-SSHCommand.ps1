param(
    $remoteHost = "root@192.168.112.2",
    $scriptFile = "lxc-template-setup.sh"
)


$rootPath = Split-Path -Path $PSScriptRoot -Parent
$scriptFilePath = "$rootPath\configs\$scriptFile"

# Replace Windows-style line endings with Unix-style line endings
$scriptContent = $scriptContent -replace "`r`n", "`n"

# Write the updated content back to the script file
Set-Content -Path $scriptFilePath -Value $scriptContent

$sshCommand = @"
$scriptContent
"@

# Define the path to the log files
$logFileStdOut = "$rootPath\logs\remote_setup_stdout.log"
$logFileStdErr = "$rootPath\logs\remote_setup_stderr.log"
$combinedLogFile = "$rootPath\logs\remote_setup.log"

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