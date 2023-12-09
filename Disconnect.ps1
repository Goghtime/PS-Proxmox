# Check if the global variable exists and has a non-null value
if ($Global:PveTicketLast -and $Global:PveTicketLast.Ticket) {
    # Clear the contents of the variable
    $Global:PveTicketLast.Ticket = $null
    $Global:PveTicketLast.CSRFPreventionToken = $null
    $Global:PveTicketLast.ApiToken = $null

    # Optionally, you can completely remove the variable
    Remove-Variable -Name PveTicketLast -Scope Global

    Write-Host "Disconnected and cleared session information."
} else {
    Write-Host "No active session to disconnect."
}
