param (
    $VMID,
    $IPAddress = "192.168.206.3",
    $DefaultGateway = "192.168.206.1", 
    $Node = "pve01",    # This is my Lab Node
    
)

####
# Define the network adapter name and the static IP configuration
$NetworkAdapterName = "Ethernet"  
$SubnetMask = "255.255.255.0" # Replace with the subnet mask for your network
$DefaultGateway = "192.168.206.1"  

$ChangeIP = New-PveNodesQemuAgentExec -Command "powershell.exe" -InputData "New-NetIPAddress -InterfaceAlias $NetworkAdapterName -IPAddress $IPAddress -PrefixLength 24 -DefaultGateway $DefaultGateway" -Vmid $VMID -Node $Node


$processid = ($Changeip.Response.data).pid

$ChangeIPStatus = get-pveNodesQemuAgentExecStatus -Vmid $VMID -Node $Node -Pid_ $processid
$ChangeIPStatus.Response.data.'out-data'

###

$DNSAddresses = "192.168.206.2"  # Replace with the desired DNS server addresses

# Set the DNS server addresses
$ChangeDNS = New-PveNodesQemuAgentExec -Command "powershell.exe" -InputData "Set-DnsClientServerAddress -InterfaceAlias $NetworkAdapterName -ServerAddresses $DNSAddresses" -Vmid $VMID -Node $Node
$ChangeDNS.StatusCode = 200

$processid = ($ChangeDNS.Response.data).pid

$ChangeDNSStatus = get-pveNodesQemuAgentExecStatus -Vmid $VMID -Node $Node -Pid_ $processid
$ChangeDNSStatus.Response.data.'out-data'
