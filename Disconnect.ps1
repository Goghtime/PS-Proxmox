# Check if the global variable exists and has a non-null value
if ($Global:PveTicketLast -and $Global:PveTicketLast.ApiToken) {

    # Remove the variable
    Remove-Variable -Name PveTicketLast -Scope Global

    Write-Host "Disconnected and cleared session information."
    
} else {
    Write-Host "No active session to disconnect."
}
