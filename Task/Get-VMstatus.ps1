param(
    [ValidateSet("stopped","running")]
    [string]$status = "running"
)

 Get-PveVm -VmIdOrName * | Where-Object {$_.Status -eq $status} | Select-Object vmID, name, type, status, node | Sort-Object node | Format-Table


