param(
    [Parameter(Mandatory=$true)]
    [string]$ConfigFile,
    $ticket
)

try {
    # Load the configuration file
    $config = Get-Content -Path $ConfigFile | ConvertFrom-Json

    # Extract values from the configuration file
    $Arch = $config.Arch
    $Hostname = $config.Hostname
    $Nameserver = $config.Nameserver
    $NetN = $config.NetN
    $Node = $config.Node
    $Ostemplate = $config.Ostemplate
    $Storage = $config.Storage
    $Vmid = $config.Vmid
    $Password = (ConvertTo-SecureString $config.Password -AsPlainText -Force)
    $ticket = $config.PveTicket

    # Convert NetN string to hashtable if necessary
    if (-not ($NetN -is [hashtable])) {
        $NetN = Invoke-Expression $NetN
    }

    # Ensure ticket is provided
    if (-not $ticket) {
        throw "PveTicket is required in the configuration file."
    }

    # Create the LXC container
    New-PveNodesLxc -PveTicket $ticket -Arch $Arch -Cores 1 -Memory 2048 -Hostname $Hostname -Nameserver $Nameserver -NetN $NetN -Node $Node -Ostemplate $Ostemplate -Password $Password -Storage $Storage -Vmid $Vmid -Start

    Write-Host "Container created successfully."
} catch {
    Write-Host "An error occurred: $_"
}
